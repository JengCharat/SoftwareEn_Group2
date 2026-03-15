<template>
    <div class="border-t border-gray-200 bg-white px-4 py-3">
        <!-- Warning ถ้าไม่สามารถส่งข้อความได้ -->
        <div v-if="disabled" class="mb-2 text-center text-sm text-gray-500">
            <span class="inline-flex items-center gap-1">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                        d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                </svg>
                {{ disabledMessage || 'ไม่สามารถส่งข้อความได้ในขณะนี้' }}
            </span>
        </div>

        <!-- Personal Info Warning (แจ้งเตือนเมื่อตรวจพบข้อมูลส่วนตัวในข้อความที่กำลังพิมพ์) -->
        <div v-if="personalInfoWarning" class="mb-2 px-3 py-2 bg-yellow-50 border border-yellow-200 rounded-lg">
            <div class="flex items-start gap-2">
                <svg class="w-4 h-4 text-yellow-600 mt-0.5 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                        d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                </svg>
                <p class="text-xs text-yellow-700">
                    ตรวจพบข้อมูลที่อาจเป็น<strong>{{ personalInfoWarning }}</strong>ในข้อความ 
                    กรุณาระวังการเปิดเผยข้อมูลส่วนตัว
                </p>
            </div>
        </div>

        <!-- Input Area -->
        <form @submit.prevent="handleSubmit" class="flex items-end gap-2">
            <!-- Text Input -->
            <div class="flex-1 relative">
                <textarea
                    ref="textareaRef"
                    v-model="message"
                    :disabled="disabled || isSending"
                    :placeholder="placeholder"
                    rows="1"
                    class="w-full px-4 py-2.5 pr-12 text-sm border border-gray-300 rounded-2xl resize-none 
                           focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent
                           disabled:bg-gray-100 disabled:cursor-not-allowed
                           max-h-32 overflow-y-auto"
                    @keydown="handleKeydown"
                    @input="adjustHeight"
                ></textarea>

                <!-- Character Count -->
                <span 
                    v-if="message.length > 0"
                    :class="[
                        'absolute right-3 bottom-2.5 text-xs',
                        message.length > maxLength ? 'text-red-500' : 'text-gray-400'
                    ]"
                >
                    {{ message.length }}/{{ maxLength }}
                </span>
            </div>

            <!-- Send Button -->
            <button
                type="submit"
                :disabled="!canSend"
                :class="[
                    'flex-shrink-0 p-2.5 rounded-full transition-colors duration-200',
                    canSend 
                        ? 'bg-blue-600 text-white hover:bg-blue-700' 
                        : 'bg-gray-200 text-gray-400 cursor-not-allowed'
                ]"
            >
                <svg v-if="!isSending" class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                        d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8" />
                </svg>
                <svg v-else class="w-5 h-5 animate-spin" fill="none" viewBox="0 0 24 24">
                    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                    <path class="opacity-75" fill="currentColor" 
                        d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z">
                    </path>
                </svg>
            </button>
        </form>

        <!-- Quick Tips -->
        <p class="mt-2 text-xs text-center text-gray-400">
            กด Enter เพื่อส่ง หรือ Shift+Enter เพื่อขึ้นบรรทัดใหม่
        </p>

        <!-- Personal Info Confirmation Modal -->
        <transition name="modal-fade">
            <div v-if="showPIIConfirm" class="fixed inset-0 z-50 flex items-center justify-center bg-black/50" @click.self="cancelSend">
                <div class="bg-white rounded-xl max-w-sm w-[90%] shadow-xl">
                    <div class="p-5">
                        <div class="flex items-start gap-3">
                            <div class="flex-shrink-0 w-10 h-10 rounded-full bg-yellow-100 flex items-center justify-center">
                                <svg class="w-5 h-5 text-yellow-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                                        d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                                </svg>
                            </div>
                            <div>
                                <h3 class="text-base font-semibold text-gray-900">แจ้งเตือนข้อมูลส่วนตัว</h3>
                                <p class="mt-1 text-sm text-gray-600">
                                    ตรวจพบข้อมูลที่อาจเป็น<strong>{{ piiDetectedTypes }}</strong>ในข้อความของคุณ
                                </p>
                                <p class="mt-2 text-sm text-gray-600">
                                    เพื่อความปลอดภัย ไม่แนะนำให้แชร์ข้อมูลส่วนตัว เช่น เบอร์โทร ที่อยู่ อีเมล หรือบัญชีโซเชียลมีเดียในแชท
                                </p>
                                <p class="mt-2 text-sm text-gray-500">
                                    คุณต้องการส่งข้อความนี้ต่อหรือไม่?
                                </p>
                            </div>
                        </div>
                    </div>
                    <div class="flex border-t border-gray-200 rounded-b-xl overflow-hidden">
                        <button 
                            @click="cancelSend"
                            class="flex-1 px-4 py-3 text-sm font-medium text-gray-700 hover:bg-gray-50 transition-colors border-r border-gray-200"
                        >
                            แก้ไขข้อความ
                        </button>
                        <button 
                            @click="confirmSend"
                            class="flex-1 px-4 py-3 text-sm font-medium text-yellow-700 hover:bg-yellow-50 transition-colors"
                        >
                            ส่งต่อไป
                        </button>
                    </div>
                </div>
            </div>
        </transition>
    </div>
</template>

<script setup>
import { ref, computed, nextTick, watch } from 'vue'
import { detectPersonalInfo } from '~/utils/personalInfoDetector'

const props = defineProps({
    isSending: {
        type: Boolean,
        default: false
    },
    disabled: {
        type: Boolean,
        default: false
    },
    disabledMessage: {
        type: String,
        default: ''
    },
    placeholder: {
        type: String,
        default: 'พิมพ์ข้อความ...'
    },
    maxLength: {
        type: Number,
        default: 1000
    }
})

const emit = defineEmits(['send'])

const message = ref('')
const textareaRef = ref(null)
const showPIIConfirm = ref(false)
const piiDetectedTypes = ref('')

// Real-time personal info detection while typing
const personalInfoWarning = computed(() => {
    if (!message.value.trim()) return null
    const result = detectPersonalInfo(message.value)
    if (!result.detected) return null
    return result.types.join(', ')
})

// สามารถส่งได้หรือไม่
const canSend = computed(() => {
    const trimmed = message.value.trim()
    return (
        trimmed.length > 0 && 
        trimmed.length <= props.maxLength && 
        !props.disabled && 
        !props.isSending
    )
})

// ส่งข้อความ (ตรวจสอบข้อมูลส่วนตัวก่อน)
const handleSubmit = () => {
    if (!canSend.value) return

    // ตรวจจับข้อมูลส่วนตัว
    const piiResult = detectPersonalInfo(message.value)
    if (piiResult.detected) {
        piiDetectedTypes.value = piiResult.types.join(', ')
        showPIIConfirm.value = true
        return
    }
    
    doSend()
}

// ส่งข้อความจริง
const doSend = () => {
    emit('send', message.value.trim())
    message.value = ''
    showPIIConfirm.value = false
    
    // Reset textarea height
    nextTick(() => {
        if (textareaRef.value) {
            textareaRef.value.style.height = 'auto'
        }
    })
}

// ยืนยันส่งแม้มีข้อมูลส่วนตัว
const confirmSend = () => {
    doSend()
}

// ยกเลิกส่ง (กลับไปแก้ไข)
const cancelSend = () => {
    showPIIConfirm.value = false
}

// Handle keyboard
const handleKeydown = (e) => {
    // Enter โดยไม่กด Shift = ส่ง
    if (e.key === 'Enter' && !e.shiftKey) {
        e.preventDefault()
        handleSubmit()
    }
}

// Auto-adjust textarea height
const adjustHeight = () => {
    const textarea = textareaRef.value
    if (!textarea) return
    
    textarea.style.height = 'auto'
    textarea.style.height = Math.min(textarea.scrollHeight, 128) + 'px'
}

// Focus input
const focus = () => {
    textareaRef.value?.focus()
}

defineExpose({ focus })
</script>

<style scoped>
.modal-fade-enter-active,
.modal-fade-leave-active {
    transition: opacity 0.2s ease;
}
.modal-fade-enter-from,
.modal-fade-leave-to {
    opacity: 0;
}
</style>

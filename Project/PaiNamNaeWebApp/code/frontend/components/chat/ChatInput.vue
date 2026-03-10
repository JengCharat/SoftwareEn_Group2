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
    </div>
</template>

<script setup>
import { ref, computed, nextTick } from 'vue'

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

// ส่งข้อความ
const handleSubmit = () => {
    if (!canSend.value) return
    
    emit('send', message.value.trim())
    message.value = ''
    
    // Reset textarea height
    nextTick(() => {
        if (textareaRef.value) {
            textareaRef.value.style.height = 'auto'
        }
    })
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

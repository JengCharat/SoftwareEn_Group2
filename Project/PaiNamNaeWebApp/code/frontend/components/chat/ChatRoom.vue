<template>
    <div class="flex flex-col h-full bg-gray-50">
        <!-- Chat Header -->
        <div class="flex items-center px-4 py-3 bg-white border-b border-gray-200 shadow-sm">
            <!-- Back Button -->
            <button 
                @click="$emit('back')"
                class="p-2 mr-2 text-gray-600 rounded-full hover:bg-gray-100"
            >
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
                </svg>
            </button>

            <!-- Partner Avatar -->
            <div class="flex-shrink-0">
                <div v-if="chatPartner?.profilePicture" class="w-10 h-10 overflow-hidden rounded-full">
                    <img 
                        :src="chatPartner.profilePicture" 
                        :alt="chatPartner.firstName"
                        class="object-cover w-full h-full"
                    />
                </div>
                <div 
                    v-else 
                    class="flex items-center justify-center w-10 h-10 text-white rounded-full"
                    :class="chatPartner?.role === 'DRIVER' ? 'bg-blue-500' : 'bg-green-500'"
                >
                    {{ chatPartner?.firstName?.charAt(0) || '?' }}
                </div>
            </div>

            <!-- Partner Info -->
            <div class="flex-1 min-w-0 ml-3">
                <div class="flex items-center gap-2">
                    <h2 class="text-sm font-semibold text-gray-900 truncate">
                        {{ chatPartner?.firstName || 'ไม่ทราบชื่อ' }}
                    </h2>
                    <!-- Verified Badge -->
                    <span 
                        v-if="chatPartner?.isVerified" 
                        class="inline-flex items-center px-1.5 py-0.5 text-xs font-medium text-blue-700 bg-blue-100 rounded"
                    >
                        <svg class="w-3 h-3 mr-0.5" fill="currentColor" viewBox="0 0 20 20">
                            <path fill-rule="evenodd" d="M6.267 3.455a3.066 3.066 0 001.745-.723 3.066 3.066 0 013.976 0 3.066 3.066 0 001.745.723 3.066 3.066 0 012.812 2.812c.051.643.304 1.254.723 1.745a3.066 3.066 0 010 3.976 3.066 3.066 0 00-.723 1.745 3.066 3.066 0 01-2.812 2.812 3.066 3.066 0 00-1.745.723 3.066 3.066 0 01-3.976 0 3.066 3.066 0 00-1.745-.723 3.066 3.066 0 01-2.812-2.812 3.066 3.066 0 00-.723-1.745 3.066 3.066 0 010-3.976 3.066 3.066 0 00.723-1.745 3.066 3.066 0 012.812-2.812zm7.44 5.252a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
                        </svg>
                        ยืนยันแล้ว
                    </span>
                </div>
                <p class="text-xs text-gray-500">
                    {{ chatPartner?.role === 'DRIVER' ? 'คนขับ' : 'ผู้โดยสาร' }}
                </p>
            </div>

            <!-- Route Info -->
            <div v-if="routeInfo" class="hidden text-right sm:block">
                <p class="text-xs text-gray-500 truncate max-w-48">
                    {{ routeInfo.routeSummary }}
                </p>
                <p class="text-xs text-gray-400">
                    {{ formatDepartureTime(routeInfo.departureTime) }}
                </p>
            </div>
        </div>

        <!-- Messages Container -->
        <div 
            ref="messagesContainer"
            class="flex-1 px-4 py-4 overflow-y-auto"
            @scroll="handleScroll"
        >
            <!-- Loading -->
            <div v-if="isLoading" class="flex items-center justify-center h-full">
                <div class="text-center">
                    <svg class="w-8 h-8 mx-auto text-blue-600 animate-spin" fill="none" viewBox="0 0 24 24">
                        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"></path>
                    </svg>
                    <p class="mt-2 text-sm text-gray-500">กำลังโหลดข้อความ...</p>
                </div>
            </div>

            <!-- Error -->
            <div v-else-if="error" class="flex items-center justify-center h-full">
                <div class="text-center">
                    <svg class="w-12 h-12 mx-auto text-red-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                            d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                    </svg>
                    <p class="mt-2 text-sm text-red-600">{{ error }}</p>
                    <button 
                        @click="$emit('retry')"
                        class="px-4 py-2 mt-3 text-sm text-white bg-blue-600 rounded-md hover:bg-blue-700"
                    >
                        ลองอีกครั้ง
                    </button>
                </div>
            </div>

            <!-- Empty State -->
            <div v-else-if="messages.length === 0" class="flex items-center justify-center h-full">
                <div class="text-center">
                    <svg class="w-16 h-16 mx-auto text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" 
                            d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
                    </svg>
                    <p class="mt-3 text-sm text-gray-500">ยังไม่มีข้อความ</p>
                    <p class="text-xs text-gray-400">เริ่มการสนทนากับ{{ chatPartner?.role === 'DRIVER' ? 'คนขับ' : 'ผู้โดยสาร' }}ของคุณ</p>
                </div>
            </div>

            <!-- Messages List -->
            <div v-else class="space-y-1">
                <!-- Personal Info Safety Reminder Banner (คล้าย Lazada) -->
                <div class="mx-2 my-3 px-4 py-3 bg-yellow-50 border border-yellow-200 rounded-xl">
                    <div class="flex items-start gap-2">
                        <span class="text-yellow-500 text-base mt-0.5">⚠️</span>
                        <p class="text-xs text-yellow-800 leading-relaxed">
                            <strong>แจ้งเตือนจาก PaiNamNae</strong> — ข้อความทั้งหมดต้องเป็นไปตามนโยบายชุมชนของเรา 
                            ผู้ใช้ไม่ควรแชร์ข้อมูลส่วนตัว เช่น เบอร์โทรศัพท์ ที่อยู่ อีเมล บัญชีโซเชียลมีเดีย 
                            หรือเลขบัตรประชาชนในแชท เพื่อปกป้องตัวคุณจากการหลอกลวง
                        </p>
                    </div>
                </div>
                <!-- Date Separator -->
                <template v-for="(group, dateKey) in groupedMessages" :key="dateKey">
                    <div class="flex items-center justify-center my-4">
                        <span class="px-3 py-1 text-xs text-gray-500 bg-gray-200 rounded-full">
                            {{ dateKey }}
                        </span>
                    </div>
                    
                    <ChatMessage
                        v-for="msg in group"
                        :key="msg.id"
                        :message="msg"
                        :my-role="myRole"
                        :show-sender-label="true"
                    />
                </template>
            </div>
        </div>

        <!-- Privacy Notice -->
        <div class="px-4 py-2 text-xs text-center text-gray-400 bg-gray-100 border-t border-gray-200">
            <svg class="inline-block w-3 h-3 mr-1" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M5 9V7a5 5 0 0110 0v2a2 2 0 012 2v5a2 2 0 01-2 2H5a2 2 0 01-2-2v-5a2 2 0 012-2zm8-2v2H7V7a3 3 0 016 0z" clip-rule="evenodd" />
            </svg>
            ข้อความถูกส่งอย่างปลอดภัย โดยไม่เปิดเผยข้อมูลส่วนตัว
        </div>

        <!-- Chat Input -->
        <ChatInput
            :is-sending="isSending"
            :disabled="!canSendMessage"
            :disabled-message="disabledMessage"
            @send="handleSendMessage"
        />
    </div>
</template>

<script setup>
import { ref, computed, watch, nextTick, onMounted, onUnmounted } from 'vue'
import dayjs from 'dayjs'
import 'dayjs/locale/th'
import ChatMessage from './ChatMessage.vue'
import ChatInput from './ChatInput.vue'

dayjs.locale('th')

const props = defineProps({
    chatRoom: {
        type: Object,
        default: null
    },
    messages: {
        type: Array,
        default: () => []
    },
    isLoading: {
        type: Boolean,
        default: false
    },
    isSending: {
        type: Boolean,
        default: false
    },
    error: {
        type: String,
        default: null
    },
    myRole: {
        type: String,
        default: null
    }
})

const emit = defineEmits(['send', 'back', 'retry', 'mark-read'])

const messagesContainer = ref(null)

// Computed
const chatPartner = computed(() => props.chatRoom?.chatPartner)
const routeInfo = computed(() => props.chatRoom?.route)

// สามารถส่งข้อความได้หรือไม่
const canSendMessage = computed(() => {
    const status = props.chatRoom?.status
    return status === 'PENDING' || status === 'CONFIRMED'
})

const disabledMessage = computed(() => {
    const status = props.chatRoom?.status
    if (status === 'REJECTED') return 'การจองถูกปฏิเสธแล้ว'
    if (status === 'CANCELLED') return 'การจองถูกยกเลิกแล้ว'
    return ''
})

// จัดกลุ่มข้อความตามวันที่
const groupedMessages = computed(() => {
    const groups = {}
    const today = dayjs()
    const yesterday = today.subtract(1, 'day')

    props.messages.forEach(msg => {
        const msgDate = dayjs(msg.createdAt)
        let dateKey

        if (msgDate.isSame(today, 'day')) {
            dateKey = 'วันนี้'
        } else if (msgDate.isSame(yesterday, 'day')) {
            dateKey = 'เมื่อวาน'
        } else if (msgDate.isSame(today, 'year')) {
            dateKey = msgDate.format('D MMMM')
        } else {
            dateKey = msgDate.format('D MMMM YYYY')
        }

        if (!groups[dateKey]) {
            groups[dateKey] = []
        }
        groups[dateKey].push(msg)
    })

    return groups
})

// Format departure time
const formatDepartureTime = (time) => {
    if (!time) return ''
    return dayjs(time).format('D MMM YYYY HH:mm')
}

// Scroll to bottom
const scrollToBottom = (smooth = false) => {
    nextTick(() => {
        if (messagesContainer.value) {
            messagesContainer.value.scrollTo({
                top: messagesContainer.value.scrollHeight,
                behavior: smooth ? 'smooth' : 'auto'
            })
        }
    })
}

// Handle scroll (เพื่อ mark as read)
const handleScroll = () => {
    // Could implement read receipt logic here
}

// Handle send
const handleSendMessage = (content) => {
    emit('send', content)
    // Scroll to bottom after sending
    nextTick(() => scrollToBottom(true))
}

// Watch messages to scroll
watch(() => props.messages.length, (newLen, oldLen) => {
    if (newLen > oldLen) {
        scrollToBottom(true)
    }
})

// Auto scroll on mount
onMounted(() => {
    scrollToBottom()
    
    // Mark all as read when entering chat
    emit('mark-read')
})

// Expose scroll method
defineExpose({ scrollToBottom })
</script>

<template>
    <div class="h-screen bg-gray-100">
        <ChatRoom
            :chat-room="chatRoom"
            :messages="messages"
            :is-loading="isLoading"
            :is-sending="isSending"
            :error="error"
            :my-role="myRole"
            @send="handleSendMessage"
            @back="goBack"
            @retry="loadChat"
            @mark-read="markAllAsRead"
        />
    </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useChat } from '~/composables/useChat'
import { useToast } from '~/composables/useToast'
import ChatRoom from '~/components/chat/ChatRoom.vue'

// Middleware - ต้อง login ก่อน
definePageMeta({
    middleware: ['auth']
})

const route = useRoute()
const router = useRouter()
const { toast } = useToast()

const {
    chatRoom,
    messages,
    isLoading,
    isSending,
    error,
    myRole,
    fetchChatRoom,
    fetchMessages,
    sendMessage,
    markAllAsRead,
    refreshMessages,
    reset
} = useChat()

// Booking ID จาก route params
const bookingId = ref(route.params.bookingId)

// Polling interval
let pollingInterval = null
const POLLING_INTERVAL = 5000 // 5 วินาที

// Load chat data
const loadChat = async () => {
    try {
        await Promise.all([
            fetchChatRoom(bookingId.value),
            fetchMessages(bookingId.value)
        ])
    } catch (e) {
        console.error('Failed to load chat:', e)
        toast({
            title: 'เกิดข้อผิดพลาด',
            description: e.statusMessage || 'ไม่สามารถโหลดแชทได้',
            variant: 'error'
        })
    }
}

// Send message handler
const handleSendMessage = async (content) => {
    try {
        await sendMessage(bookingId.value, content)
    } catch (e) {
        toast({
            title: 'ส่งข้อความไม่สำเร็จ',
            description: e.statusMessage || 'กรุณาลองอีกครั้ง',
            variant: 'error'
        })
    }
}

// Mark all messages as read
const handleMarkAllAsRead = async () => {
    try {
        await markAllAsRead(bookingId.value)
    } catch (e) {
        // Silently fail
    }
}

// Go back
const goBack = () => {
    // ถ้ามี history ให้ back ถ้าไม่มีให้ไป myTrip
    if (window.history.length > 2) {
        router.back()
    } else {
        router.push('/myTrip')
    }
}

// Start polling for new messages
const startPolling = () => {
    pollingInterval = setInterval(async () => {
        try {
            await refreshMessages(bookingId.value)
        } catch (e) {
            // Silently fail
        }
    }, POLLING_INTERVAL)
}

// Stop polling
const stopPolling = () => {
    if (pollingInterval) {
        clearInterval(pollingInterval)
        pollingInterval = null
    }
}

// Lifecycle
onMounted(async () => {
    await loadChat()
    startPolling()
})

onUnmounted(() => {
    stopPolling()
    reset()
})
</script>

<style scoped>
/* Full height chat */
</style>

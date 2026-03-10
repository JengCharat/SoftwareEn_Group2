import { ref, computed } from 'vue'

/**
 * Composable สำหรับระบบแชทแบบปลอดภัย
 * สื่อสารระหว่าง Driver และ Passenger โดยไม่เปิดเผยข้อมูลส่วนตัว
 */
export function useChat() {
    const { $api } = useNuxtApp()

    // State
    const chatRoom = ref(null)
    const messages = ref([])
    const isLoading = ref(false)
    const isSending = ref(false)
    const error = ref(null)
    const pagination = ref({
        page: 1,
        limit: 50,
        total: 0,
        totalPages: 0
    })

    /**
     * ดึงข้อมูลห้องแชท
     */
    const fetchChatRoom = async (bookingId) => {
        isLoading.value = true
        error.value = null
        try {
            const data = await $api(`/bookings/${bookingId}/chat`)
            chatRoom.value = data
            return data
        } catch (e) {
            error.value = e.statusMessage || 'ไม่สามารถโหลดข้อมูลห้องแชทได้'
            throw e
        } finally {
            isLoading.value = false
        }
    }

    /**
     * ดึงรายการข้อความทั้งหมด
     */
    const fetchMessages = async (bookingId, opts = {}) => {
        isLoading.value = true
        error.value = null
        try {
            const params = new URLSearchParams({
                page: opts.page || 1,
                limit: opts.limit || 50,
                sortOrder: opts.sortOrder || 'asc'
            })
            const response = await $api(`/bookings/${bookingId}/messages?${params}`)
            
            // Response ถูก transform แล้วจาก plugin เป็น data array
            // แต่เราต้องการ pagination ด้วย ต้องเรียกแบบ raw
            const rawResponse = await $api.raw(`/bookings/${bookingId}/messages?${params}`)
            const body = rawResponse._data
            
            if (Array.isArray(body)) {
                messages.value = body
            } else if (body?.data) {
                messages.value = body.data
                if (body.pagination) {
                    pagination.value = body.pagination
                }
            } else {
                messages.value = response || []
            }
            
            return messages.value
        } catch (e) {
            error.value = e.statusMessage || 'ไม่สามารถโหลดข้อความได้'
            throw e
        } finally {
            isLoading.value = false
        }
    }

    /**
     * ส่งข้อความใหม่
     */
    const sendMessage = async (bookingId, content) => {
        if (!content?.trim()) return null
        
        isSending.value = true
        error.value = null
        try {
            const newMessage = await $api(`/bookings/${bookingId}/messages`, {
                method: 'POST',
                body: { content: content.trim() }
            })
            
            // เพิ่มข้อความใหม่เข้าไปใน list
            messages.value.push(newMessage)
            
            return newMessage
        } catch (e) {
            error.value = e.statusMessage || 'ไม่สามารถส่งข้อความได้'
            throw e
        } finally {
            isSending.value = false
        }
    }

    /**
     * Mark ข้อความว่าอ่านแล้ว
     */
    const markAsRead = async (bookingId, messageId) => {
        try {
            const updated = await $api(`/bookings/${bookingId}/messages/${messageId}/read`, {
                method: 'PATCH'
            })
            
            // อัพเดท message ใน list
            const idx = messages.value.findIndex(m => m.id === messageId)
            if (idx !== -1) {
                messages.value[idx] = updated
            }
            
            return updated
        } catch (e) {
            console.error('Failed to mark message as read:', e)
        }
    }

    /**
     * Mark ข้อความทั้งหมดว่าอ่านแล้ว
     */
    const markAllAsRead = async (bookingId) => {
        try {
            const result = await $api(`/bookings/${bookingId}/messages/read-all`, {
                method: 'PATCH'
            })
            
            // อัพเดทข้อความทั้งหมดใน list ที่ยังไม่ได้อ่าน
            const now = new Date().toISOString()
            messages.value = messages.value.map(m => {
                if (!m.readAt && m.senderRole !== chatRoom.value?.myRole) {
                    return { ...m, readAt: now }
                }
                return m
            })
            
            // อัพเดท unreadCount ใน chatRoom
            if (chatRoom.value) {
                chatRoom.value.unreadCount = 0
            }
            
            return result
        } catch (e) {
            console.error('Failed to mark all messages as read:', e)
        }
    }

    /**
     * นับจำนวนข้อความที่ยังไม่ได้อ่าน
     */
    const fetchUnreadCount = async (bookingId) => {
        try {
            const result = await $api(`/bookings/${bookingId}/messages/unread-count`)
            if (chatRoom.value) {
                chatRoom.value.unreadCount = result.unreadCount
            }
            return result.unreadCount
        } catch (e) {
            console.error('Failed to fetch unread count:', e)
            return 0
        }
    }

    /**
     * Refresh ข้อความ (polling)
     */
    const refreshMessages = async (bookingId) => {
        try {
            await fetchMessages(bookingId)
            await fetchUnreadCount(bookingId)
        } catch (e) {
            // Silently fail for polling
        }
    }

    // Computed
    const hasMessages = computed(() => messages.value.length > 0)
    const unreadCount = computed(() => chatRoom.value?.unreadCount || 0)
    const myRole = computed(() => chatRoom.value?.myRole || null)
    const chatPartner = computed(() => chatRoom.value?.chatPartner || null)

    // Reset state
    const reset = () => {
        chatRoom.value = null
        messages.value = []
        error.value = null
        pagination.value = { page: 1, limit: 50, total: 0, totalPages: 0 }
    }

    return {
        // State
        chatRoom,
        messages,
        isLoading,
        isSending,
        error,
        pagination,
        
        // Computed
        hasMessages,
        unreadCount,
        myRole,
        chatPartner,
        
        // Methods
        fetchChatRoom,
        fetchMessages,
        sendMessage,
        markAsRead,
        markAllAsRead,
        fetchUnreadCount,
        refreshMessages,
        reset
    }
}

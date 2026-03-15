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
     * ดึงรายการข้อความทั้งหมด (โหลดทุกหน้า)
     */
    const fetchMessages = async (bookingId, opts = {}) => {
        const isInitialLoad = messages.value.length === 0
        if (isInitialLoad) {
            isLoading.value = true
        }
        error.value = null
        try {
            const limit = opts.limit || 50
            let allMessages = []
            let page = 1
            let hasMore = true

            // ดึงทุกหน้าจนกว่าจะหมด
            while (hasMore) {
                const params = new URLSearchParams({
                    page,
                    limit,
                    sortOrder: opts.sortOrder || 'asc'
                })
                const response = await $api(`/bookings/${bookingId}/messages?${params}`)
                const batch = Array.isArray(response) ? response : (response || [])
                allMessages = allMessages.concat(batch)

                // ถ้าได้น้อยกว่า limit แสดงว่าหมดแล้ว
                if (batch.length < limit) {
                    hasMore = false
                } else {
                    page++
                }
            }

            messages.value = allMessages
            return messages.value
        } catch (e) {
            if (isInitialLoad) {
                error.value = e.statusMessage || 'ไม่สามารถโหลดข้อความได้'
            }
            throw e
        } finally {
            if (isInitialLoad) {
                isLoading.value = false
            }
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
     * Refresh ข้อความ (polling) - ดึงข้อความล่าสุดและ merge กับข้อความเดิม
     */
    const refreshMessages = async (bookingId) => {
        try {
            // ดึงทุกหน้าเหมือน fetchMessages แต่ไม่ set isLoading
            const limit = 50
            let allFresh = []
            let page = 1
            let hasMore = true

            while (hasMore) {
                const params = new URLSearchParams({ page, limit, sortOrder: 'asc' })
                const response = await $api(`/bookings/${bookingId}/messages?${params}`)
                const batch = Array.isArray(response) ? response : (response || [])
                allFresh = allFresh.concat(batch)
                if (batch.length < limit) {
                    hasMore = false
                } else {
                    page++
                }
            }

            // Merge: เก็บข้อความเดิมที่มีอยู่ และเพิ่มข้อความใหม่
            const existingIds = new Set(messages.value.map(m => m.id))
            const newMessages = allFresh.filter(m => !existingIds.has(m.id))
            
            if (newMessages.length > 0) {
                messages.value = [...messages.value, ...newMessages]
            }
            
            // อัพเดท readAt สำหรับข้อความที่ถูก mark as read แล้ว
            const freshMap = new Map(allFresh.map(m => [m.id, m]))
            messages.value = messages.value.map(m => {
                const fresh = freshMap.get(m.id)
                if (fresh && fresh.readAt && !m.readAt) {
                    return { ...m, readAt: fresh.readAt }
                }
                return m
            })
            
            await fetchUnreadCount(bookingId)
        } catch (e) {
            // Silently fail for polling — ข้อความเดิมยังคงแสดงอยู่
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

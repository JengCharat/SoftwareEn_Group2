/**
 * SC#14 — useLocationSharing composable
 * จัดการ lifecycle การแชร์โลเคชันให้ Emergency Contacts
 * - เปิด/ปิดการแชร์
 * - ส่งพิกัด GPS ไป backend ทุก 30 วินาที (watchPosition)
 * - ดึงสถานะการแชร์ปัจจุบัน
 */
import { ref, onUnmounted } from 'vue'

export const useLocationSharing = () => {
    const { $api } = useNuxtApp()

    const isSharing = ref(false)
    const shareUrl = ref(null)
    const shareToken = ref(null)
    const expiresAt = ref(null)
    const lastUpdatedAt = ref(null)
    const error = ref(null)
    const isLoading = ref(false)
    const geoError = ref(null)

    const isGeoSupported = typeof navigator !== 'undefined' && 'geolocation' in navigator

    let watchId = null

    // ดึงสถานะปัจจุบันจาก backend
    const fetchStatus = async () => {
        try {
            const data = await $api('/location-sharing/status')
            isSharing.value = data.isSharing
            if (data.isSharing) {
                shareUrl.value = data.shareUrl
                shareToken.value = data.shareToken
                expiresAt.value = data.expiresAt
                lastUpdatedAt.value = data.lastUpdatedAt
            }
        } catch (err) {
            console.error('[LocationShare] fetchStatus error:', err)
        }
    }

    // ส่งพิกัด GPS ล่าสุดไป backend
    const sendLocationUpdate = async (lat, lng) => {
        try {
            await $api('/location-sharing/update-location', {
                method: 'PATCH',
                body: { lat, lng },
            })
            lastUpdatedAt.value = new Date().toISOString()
        } catch (err) {
            console.error('[LocationShare] updateLocation error:', err)
        }
    }

    // เริ่ม watchPosition เพื่อส่งพิกัดต่อเนื่อง
    const startWatchingGeo = () => {
        if (!isGeoSupported) {
            geoError.value = 'เบราว์เซอร์ของคุณไม่รองรับ Geolocation'
            return
        }
        geoError.value = null
        watchId = navigator.geolocation.watchPosition(
            (pos) => sendLocationUpdate(pos.coords.latitude, pos.coords.longitude),
            (err) => {
                console.warn('[LocationShare] Geolocation error:', err.message)
                geoError.value = 'ไม่สามารถเข้าถึงโลเคชันได้ กรุณาอนุญาตการเข้าถึงตำแหน่ง'
            },
            { enableHighAccuracy: true, timeout: 15000, maximumAge: 30000 }
        )
    }

    const stopWatchingGeo = () => {
        if (watchId !== null) {
            navigator.geolocation.clearWatch(watchId)
            watchId = null
        }
    }

    // เริ่มแชร์โลเคชัน
    const startSharing = async (bookingId) => {
        isLoading.value = true
        error.value = null
        try {
            const data = await $api('/location-sharing/start', {
                method: 'POST',
                body: bookingId ? { bookingId } : {},
            })
            isSharing.value = true
            shareUrl.value = data.shareUrl
            shareToken.value = data.shareToken
            expiresAt.value = data.expiresAt
            startWatchingGeo()
        } catch (err) {
            error.value = err.statusMessage || 'ไม่สามารถเริ่มแชร์โลเคชันได้'
            throw err
        } finally {
            isLoading.value = false
        }
    }

    // หยุดแชร์โลเคชัน
    const stopSharing = async () => {
        isLoading.value = true
        try {
            await $api('/location-sharing/stop', { method: 'DELETE' })
            isSharing.value = false
            shareUrl.value = null
            shareToken.value = null
            expiresAt.value = null
            lastUpdatedAt.value = null
            stopWatchingGeo()
        } catch (err) {
            console.error('[LocationShare] stopSharing error:', err)
        } finally {
            isLoading.value = false
        }
    }

    // Copy link to clipboard
    const copyShareLink = async () => {
        if (!shareUrl.value) return false
        try {
            await navigator.clipboard.writeText(shareUrl.value)
            return true
        } catch {
            return false
        }
    }

    onUnmounted(stopWatchingGeo)

    return {
        isSharing,
        shareUrl,
        shareToken,
        expiresAt,
        lastUpdatedAt,
        error,
        geoError,
        isLoading,
        isGeoSupported,
        fetchStatus,
        startSharing,
        stopSharing,
        copyShareLink,
    }
}

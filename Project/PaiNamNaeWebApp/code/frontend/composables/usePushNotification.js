import { ref } from 'vue'

const pushSupported = ref(false)
const pushPermission = ref('default')
const pushSubscribed = ref(false)

/**
 * Composable สำหรับจัดการ Web Push Notifications
 */
export function usePushNotification() {
  const config = useRuntimeConfig()
  const apiBase = config.public.apiBase || 'http://localhost:3000/api'

  function getToken() {
    const cookie = useCookie('token')
    return cookie.value || (process.client ? localStorage.getItem('token') : '')
  }

  /** ตรวจสอบว่า browser รองรับ push หรือไม่ */
  function checkSupport() {
    if (process.server) return false
    pushSupported.value = 'serviceWorker' in navigator && 'PushManager' in window
    pushPermission.value = Notification.permission
    return pushSupported.value
  }

  /** ดึง VAPID public key จาก backend */
  async function fetchVapidKey() {
    const res = await $fetch('/push/vapid-public-key', { baseURL: apiBase })
    return res?.vapidPublicKey || res?.data?.vapidPublicKey || null
  }

  /** แปลง VAPID key จาก base64url เป็น Uint8Array */
  function urlBase64ToUint8Array(base64String) {
    const padding = '='.repeat((4 - (base64String.length % 4)) % 4)
    const base64 = (base64String + padding).replace(/-/g, '+').replace(/_/g, '/')
    const rawData = atob(base64)
    const outputArray = new Uint8Array(rawData.length)
    for (let i = 0; i < rawData.length; ++i) {
      outputArray[i] = rawData.charCodeAt(i)
    }
    return outputArray
  }

  /**
   * Register service worker, ขอ permission, subscribe push, และส่ง subscription ไป backend
   * @returns {boolean} สำเร็จหรือไม่
   */
  async function subscribePush() {
    if (!checkSupport()) {
      console.warn('[Push] Browser does not support push notifications')
      return false
    }

    // ขอ permission
    const permission = await Notification.requestPermission()
    pushPermission.value = permission
    if (permission !== 'granted') {
      console.warn('[Push] Permission denied')
      return false
    }

    try {
      // Register service worker
      const registration = await navigator.serviceWorker.register('/sw.js')
      await navigator.serviceWorker.ready

      // ดึง VAPID key
      const vapidKey = await fetchVapidKey()
      if (!vapidKey) {
        console.warn('[Push] VAPID key not available')
        return false
      }

      // Subscribe
      const subscription = await registration.pushManager.subscribe({
        userVisibleOnly: true,
        applicationServerKey: urlBase64ToUint8Array(vapidKey),
      })

      const subJson = subscription.toJSON()

      // ส่งไป backend
      const tk = getToken()
      await $fetch('/push/subscribe', {
        baseURL: apiBase,
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          ...(tk ? { Authorization: `Bearer ${tk}` } : {}),
        },
        body: {
          endpoint: subJson.endpoint,
          keys: {
            p256dh: subJson.keys.p256dh,
            auth: subJson.keys.auth,
          },
        },
      })

      pushSubscribed.value = true
      console.log('[Push] Subscribed successfully')
      return true
    } catch (err) {
      console.error('[Push] Subscribe failed:', err)
      return false
    }
  }

  /** ตรวจสอบว่ามี subscription อยู่แล้วหรือไม่ (สำหรับเรียกตอน onMounted) */
  async function checkExistingSubscription() {
    if (!checkSupport()) return false
    pushPermission.value = Notification.permission

    if (Notification.permission !== 'granted') return false

    try {
      const registration = await navigator.serviceWorker.getRegistration('/sw.js')
      if (!registration) return false

      const subscription = await registration.pushManager.getSubscription()
      pushSubscribed.value = !!subscription
      return !!subscription
    } catch {
      return false
    }
  }

  return {
    pushSupported,
    pushPermission,
    pushSubscribed,
    checkSupport,
    subscribePush,
    checkExistingSubscription,
  }
}

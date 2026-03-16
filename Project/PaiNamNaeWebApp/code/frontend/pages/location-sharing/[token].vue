<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Header -->
    <div class="bg-blue-600 text-white px-6 py-4 flex items-center gap-3 shadow">
      <span class="text-2xl">📍</span>
      <div>
        <h1 class="font-bold text-lg leading-tight">ไปนำแหน่ — โลเคชันฉุกเฉิน</h1>
        <p class="text-sm opacity-80">ระบบติดตามโลเคชัน TripSafe</p>
      </div>
    </div>

    <!-- Loading -->
    <div v-if="loading" class="flex justify-center items-center h-64">
      <p class="text-gray-500">กำลังโหลดข้อมูล...</p>
    </div>

    <!-- Expired / Stopped -->
    <div v-else-if="!shareData?.isActive" class="p-8 text-center max-w-md mx-auto mt-10">
      <div class="text-6xl mb-4">🔒</div>
      <h2 class="text-xl font-bold text-gray-700">ลิงก์นี้ไม่สามารถใช้งานได้อีกต่อไป</h2>
      <p class="text-gray-500 mt-2 text-sm">ผู้โดยสารได้หยุดแชร์โลเคชันแล้ว หรือลิงก์หมดอายุ</p>
    </div>

    <!-- Active Share -->
    <div v-else class="p-4 max-w-xl mx-auto space-y-4 pb-8">

      <!-- Passenger Info Card -->
      <div class="bg-white rounded-2xl shadow p-5 mt-4">
        <p class="text-xs text-gray-400 uppercase tracking-wide mb-1">กำลังติดตามโลเคชันของ</p>
        <h2 class="text-2xl font-bold text-gray-800">{{ shareData.passengerName }}</h2>
        <div class="mt-3 flex items-center gap-2">
          <span
            class="inline-block w-2.5 h-2.5 rounded-full"
            :class="shareData.lastLat ? 'bg-green-500 animate-pulse' : 'bg-orange-400'"
          ></span>
          <p v-if="shareData.lastLat" class="text-sm text-green-600 font-medium">
            กำลังส่งโลเคชัน — อัปเดตล่าสุด {{ formatTime(shareData.lastUpdatedAt) }}
          </p>
          <p v-else class="text-sm text-orange-500 font-medium">
            รอรับโลเคชันจากผู้โดยสาร...
          </p>
        </div>
        <p class="text-xs text-gray-400 mt-1">ลิงก์หมดอายุ: {{ formatExpiry(shareData.expiresAt) }}</p>
      </div>

      <!-- Map Card -->
      <div class="bg-white rounded-2xl shadow overflow-hidden">
        <div v-if="!shareData.lastLat" class="h-72 flex flex-col items-center justify-center bg-gray-100 gap-3">
          <div class="text-4xl">📍</div>
          <p class="text-gray-500 text-sm">รอรับพิกัดจากผู้โดยสาร...</p>
          <p class="text-xs text-gray-400">หน้านี้จะรีเฟรชอัตโนมัติทุก 30 วินาที</p>
        </div>
        <div id="location-map" style="height:288px;width:100%"></div>
      </div>

      <!-- Coordinates + Google Maps Link -->
      <div v-if="shareData.lastLat" class="bg-white rounded-2xl shadow p-4">
        <p class="text-xs text-gray-400 uppercase tracking-wide mb-2">พิกัดปัจจุบัน</p>
        <p class="font-mono text-sm text-gray-700">
          {{ shareData.lastLat.toFixed(6) }}, {{ shareData.lastLng.toFixed(6) }}
        </p>
        <a
          :href="`https://maps.google.com/?q=${shareData.lastLat},${shareData.lastLng}`"
          target="_blank"
          rel="noopener noreferrer"
          class="mt-3 flex items-center gap-2 text-sm text-blue-600 font-medium hover:underline"
        >
          <span>🗺️</span> เปิดใน Google Maps
        </a>
      </div>

      <!-- Auto-refresh Notice -->
      <p class="text-center text-xs text-gray-400">
        หน้านี้รีเฟรชข้อมูลโลเคชันอัตโนมัติทุก 30 วินาที
      </p>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, watch, nextTick } from 'vue'

definePageMeta({ layout: false })
useHead({
  title: 'โลเคชันฉุกเฉิน — ไปนำแหน่',
  link: [{ rel: 'stylesheet', href: 'https://unpkg.com/leaflet@1.9.4/dist/leaflet.css' }],
  script: [{ src: 'https://unpkg.com/leaflet@1.9.4/dist/leaflet.js' }],
})

const route = useRoute()
const config = useRuntimeConfig()
const token = route.params.token

const shareData = ref(null)
const loading = ref(true)

let mapInstance = null
let markerInstance = null
let refreshInterval = null

const apiBase = config.public.apiBase

const fetchData = async () => {
    try {
        const res = await $fetch(`${apiBase}/location-sharing/public/${token}`)
        shareData.value = res?.data ?? res
    } catch {
        shareData.value = { isActive: false }
    } finally {
        loading.value = false
    }
}

const initMap = async () => {
    if (!shareData.value?.lastLat || !shareData.value?.lastLng) return
    if (mapInstance) return
    await nextTick()

    // รอให้ Leaflet CDN โหลดเสร็จ (window.L)
    let attempts = 0
    while (typeof window.L === 'undefined' && attempts < 30) {
        await new Promise(r => setTimeout(r, 100))
        attempts++
    }
    const L = window.L
    if (!L) {
        console.error('[Map] Leaflet CDN failed to load')
        return
    }

    mapInstance = L.map('location-map').setView(
        [shareData.value.lastLat, shareData.value.lastLng], 15
    )
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>',
        maxZoom: 19,
    }).addTo(mapInstance)

    const redDotIcon = L.divIcon({
        html: `<div style="
            background:#dc2626;width:22px;height:22px;border-radius:50%;
            border:3px solid white;box-shadow:0 2px 8px rgba(0,0,0,0.4);">
        </div>`,
        iconSize: [22, 22],
        iconAnchor: [11, 11],
        className: '',
    })

    markerInstance = L.marker([shareData.value.lastLat, shareData.value.lastLng], { icon: redDotIcon })
        .addTo(mapInstance)
        .bindPopup(`📍 ${shareData.value.passengerName}`)
        .openPopup()

    // force Leaflet to recalculate size (element was hidden via v-show)
    setTimeout(() => mapInstance?.invalidateSize(), 150)
}

const updateMarker = () => {
    if (!mapInstance || !markerInstance || !shareData.value?.lastLat) return
    const pos = [shareData.value.lastLat, shareData.value.lastLng]
    markerInstance.setLatLng(pos)
    mapInstance.panTo(pos)
}

// Watch for location data changes after initial load
watch(shareData, async (newData, oldData) => {
    if (!newData?.isActive || !newData?.lastLat) return
    if (!oldData?.lastLat) {
        // Map not yet initialized — wait for DOM then init
        await nextTick()
        await initMap()
    } else {
        updateMarker()
    }
})

const formatTime = (iso) => {
    if (!iso) return ''
    return new Date(iso).toLocaleTimeString('th-TH', {
        hour: '2-digit', minute: '2-digit', second: '2-digit',
    })
}

const formatExpiry = (iso) => {
    if (!iso) return ''
    return new Date(iso).toLocaleString('th-TH', { dateStyle: 'short', timeStyle: 'short' })
}

onMounted(async () => {
    await fetchData()
    if (shareData.value?.isActive && shareData.value?.lastLat) {
        await nextTick()
        await initMap()
    }
    refreshInterval = setInterval(fetchData, 30000)
})

onUnmounted(() => {
    if (refreshInterval) clearInterval(refreshInterval)
    if (mapInstance) { mapInstance.remove(); mapInstance = null }
    markerInstance = null
})
</script>

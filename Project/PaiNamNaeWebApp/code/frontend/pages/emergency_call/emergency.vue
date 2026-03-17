<template>
  <div class="p-6 max-w-4xl mx-auto">
    <h1 class="text-2xl font-bold text-red-600 mb-6 underline">SOS EMERGENCY</h1>

    <div class="grid grid-cols-1 md:grid-cols-2 gap-6 md:gap-10">
      <div class="flex flex-col items-center gap-6">

        <!-- Loading State -->
        <div v-if="isLoading" class="w-full p-3 text-center text-gray-400 border-2 border-gray-200 rounded">
          กำลังโหลด...
        </div>

        <!-- Dropdown -->
        <select v-else v-model="selected" class="w-full p-3 border-2 border-gray-400 rounded">
          <option :value="null">เลือกเบอร์ฉุกเฉิน</option>

          <!-- Hardcoded national emergency numbers -->
          <optgroup label="เบอร์ฉุกเฉินทั่วไป">
            <option v-for="c in defaultContacts" :key="c.phone" :value="c">
              {{ c.name }}
            </option>
          </optgroup>

          <!-- User's personal contacts from the database -->
          <optgroup v-if="personalContacts.length > 0" label="รายชื่อส่วนตัวของฉัน">
            <option v-for="c in personalContacts" :key="c.id" :value="c">
              {{ c.name }} ({{ c.phone }})
            </option>
          </optgroup>
        </select>

        <!-- Selected number display -->
        <div v-if="selected"
          class="text-4xl font-mono font-bold text-red-600 border p-4 w-full max-w-[300px] text-center bg-gray-50">
          {{ selected.phone }}
        </div>

        <!-- Call Button -->
        <NuxtLink
          v-if="selected"
          :to="'tel:' + selected.phone"
          class="w-32 h-32 bg-red-600 rounded-full text-white font-bold text-xl shadow-lg flex items-center justify-center active:bg-red-800 no-underline">
          CALL
        </NuxtLink>

        <!-- Hint to add personal contacts -->
        <p v-if="!isLoading && personalContacts.length === 0" class="text-sm text-gray-400 text-center">
          คุณยังไม่มีรายชื่อส่วนตัว
          <NuxtLink to="/profile/manage_contacts" class="text-blue-500 underline">
            เพิ่มได้ที่นี่
          </NuxtLink>
        </p>

      </div>

      <!-- ======= SC#14: Location Sharing Panel ======= -->
      <div class="flex flex-col gap-4">
        <h2 class="text-lg font-bold text-gray-700 flex items-center gap-2">
          แชร์โลเคชันให้คนที่ไว้ใจ
        </h2>

        <!-- Currently sharing -->
        <div v-if="isSharing" class="bg-green-50 border border-green-300 rounded-xl p-4 flex flex-col gap-3">
          <div class="flex items-center gap-2">
            <span class="w-3 h-3 rounded-full bg-green-500 animate-pulse inline-block"></span>
            <span class="text-green-700 font-semibold text-sm">กำลังแชร์โลเคชันอยู่</span>
          </div>

          <p class="text-xs text-gray-500">
            หมดอายุ:
            <span class="font-medium text-gray-700">{{ formatExpiry(expiresAt) }}</span>
          </p>

          <!-- Share Link -->
          <div class="bg-white border rounded-lg p-3 flex flex-col gap-2">
            <p class="text-xs text-gray-400 mb-1">ลิงก์สำหรับส่งให้คนที่ไว้ใจ (ไม่ต้อง login)</p>
            <p class="text-xs font-mono text-gray-700 break-all bg-gray-50 p-2 rounded">{{ shareUrl }}</p>
            <div class="flex gap-2 mt-1">
              <button
                @click="handleCopy"
                class="flex-1 py-2 text-sm bg-blue-600 text-white rounded-lg font-medium active:bg-blue-800">
                {{ copied ? '✓ คัดลอกแล้ว' : 'คัดลอก' }}
              </button>
              <a
                :href="`https://line.me/R/msg/text/?${encodeURIComponent('📍 ไปนำแหน่: ติดตามโลเคชันของฉันได้ที่ ' + shareUrl)}`"
                target="_blank"
                rel="noopener noreferrer"
                class="flex-1 py-2 text-sm bg-green-500 text-white rounded-lg font-medium text-center active:bg-green-700">
                ส่งผ่าน LINE
              </a>
            </div>
            <!-- SMS to emergency contacts -->
            <a
              v-if="personalContacts.length > 0"
              :href="smsHref"
              class="block w-full py-2 mt-1 text-sm bg-orange-500 text-white rounded-lg font-medium text-center active:bg-orange-700">
              📱 ส่ง SMS ถึงรายชื่อฉุกเฉิน ({{ personalContacts.length }} เบอร์)
            </a>
            <p v-else class="text-xs text-gray-400 mt-1">
              <NuxtLink to="/profile/manage_contacts" class="text-blue-500 underline">เพิ่มรายชื่อฉุกเฉิน</NuxtLink>
              เพื่อส่ง SMS ได้
            </p>
          </div>

          <p v-if="geoError" class="text-xs text-red-500">⚠️ {{ geoError }}</p>
          <p v-else-if="lastUpdatedAt" class="text-xs text-gray-400">
            อัปเดตโลเคชันล่าสุด: {{ formatTime(lastUpdatedAt) }}
          </p>

          <!-- Stop sharing -->
          <button
            @click="handleStop"
            :disabled="locLoading"
            class="w-full py-2.5 text-sm font-semibold text-red-600 border border-red-300 rounded-xl hover:bg-red-50 disabled:opacity-50">
            {{ locLoading ? 'กำลังหยุด...' : 'หยุดแชร์โลเคชัน' }}
          </button>
        </div>

        <!-- Not sharing yet -->
        <div v-else class="bg-gray-50 border border-gray-200 rounded-xl p-4 flex flex-col gap-3">
          <p class="text-sm text-gray-600 leading-relaxed">
            เปิดแชร์โลเคชันเพื่อให้คนที่คุณไว้ใจ ติดตามตำแหน่งของคุณได้แบบ real-time
            ผ่านลิงก์ที่แชร์ไปทาง LINE/SMS (ไม่ต้องมีบัญชี)
          </p>
          <p class="text-xs text-gray-400">ลิงก์มีอายุ 24 ชั่วโมง — สามารถหยุดได้ทุกเวมา</p>

          <p v-if="locationError" class="text-xs text-red-500">⚠️ {{ locationError }}</p>

          <button
            @click="handleStart"
            :disabled="locLoading || !isGeoSupported"
            class="w-full py-3 text-sm font-bold bg-red-600 text-white rounded-xl shadow active:bg-red-800 disabled:opacity-50">
            {{ locLoading ? 'กำลังเริ่ม...' : 'เริ่มแชร์โลเคชัน' }}
          </button>

          <p v-if="!isGeoSupported" class="text-xs text-orange-500 text-center">
            เบราว์เซอร์ของคุณไม่รองรับ Geolocation
          </p>
        </div>
      </div>
      <!-- ======= END SC#14 ======= -->

    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useLocationSharing } from '~/composables/useLocationSharing'

const { $api } = useNuxtApp()

//เบอร์โทรฉุกเฉินเริ่มต้น
const defaultContacts = [
  { name: 'ตำรวจ (191)',         phone: '191' },
  { name: 'รถพยาบาล (1669)',     phone: '1669' },
  { name: 'สายด่วนจราจร (1197)', phone: '1197' },
]

const personalContacts = ref([])
const selected = ref(null)
const isLoading = ref(false)

//ดึงข้อมูลจาก Emergency Contacts ที่บันทึกไว้
const fetchPersonalContacts = async () => {
  isLoading.value = true
  try {
    const res = await $api('/emergency-contacts')
    personalContacts.value = res
  } catch (err) {
    // Non-critical — the page still works with just the default numbers
    console.error('fetchPersonalContacts error:', err)
  } finally {
    isLoading.value = false
  }
}

// SC#14 — Location Sharing
const {
  isSharing,
  shareUrl,
  expiresAt,
  lastUpdatedAt,
  error: locationError,
  geoError,
  isLoading: locLoading,
  isGeoSupported,
  fetchStatus,
  startSharing,
  stopSharing,
  copyShareLink,
} = useLocationSharing()

const copied = ref(false)

const smsHref = computed(() => {
  const phones = personalContacts.value.map(c => c.phone).join(',')
  const msg = encodeURIComponent('📍 ไปนำแหน่: ติดตามโลเคชันของฉันได้ที่ ' + shareUrl.value)
  return `sms:${phones}?&body=${msg}`
})

const handleStart = async () => {
  try {
    await startSharing()
  } catch {
    // error displayed via locationError ref
  }
}

const handleStop = async () => {
  await stopSharing()
}

const handleCopy = async () => {
  const ok = await copyShareLink()
  if (ok) {
    copied.value = true
    setTimeout(() => { copied.value = false }, 2500)
  }
}

const formatExpiry = (iso) => {
  if (!iso) return ''
  return new Date(iso).toLocaleString('th-TH', { dateStyle: 'short', timeStyle: 'short' })
}

const formatTime = (iso) => {
  if (!iso) return ''
  return new Date(iso).toLocaleTimeString('th-TH', { hour: '2-digit', minute: '2-digit', second: '2-digit' })
}

onMounted(async () => {
  await fetchPersonalContacts()
  await fetchStatus()
})
</script>
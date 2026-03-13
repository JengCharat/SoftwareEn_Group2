<template>
    <div class="min-h-screen bg-gray-50">
        <div class="max-w-2xl px-4 py-8 mx-auto sm:px-6 lg:px-8">
            <!-- Header -->
            <div class="mb-6">
                <NuxtLink to="/report"
                    class="inline-flex items-center text-sm text-blue-600 hover:text-blue-800 mb-2">
                    <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
                    </svg>
                    กลับไปรายการรายงาน
                </NuxtLink>
                <h1 class="text-2xl font-bold text-gray-800">รายงานพฤติกรรมคนขับ</h1>
                <p class="mt-1 text-sm text-gray-500">กรุณากรอกรายละเอียดเพื่อแจ้งปัญหาเกี่ยวกับคนขับ</p>
            </div>

            <form @submit.prevent="submitReport" class="space-y-6 bg-white rounded-xl shadow-sm border border-gray-200 p-6">
                <!-- เลือกคนขับ -->
                <div>
                    <label class="block mb-1 text-sm font-medium text-gray-700">คนขับที่ต้องการรายงาน <span class="text-red-500">*</span></label>
                    <select v-model="form.reportedDriverId" required
                        class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500">
                        <option value="" disabled>-- เลือกคนขับ --</option>
                        <option v-for="d in drivers" :key="d.id" :value="d.id">
                            {{ d.firstName }} ({{ d.routeSummary || 'ไม่ระบุเส้นทาง' }})
                        </option>
                    </select>
                </div>

                <!-- เลือก Booking (ถ้ามี) -->
                <div v-if="bookings.length > 0">
                    <label class="block mb-1 text-sm font-medium text-gray-700">การจองที่เกี่ยวข้อง (ไม่บังคับ)</label>
                    <select v-model="form.bookingId"
                        class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500">
                        <option value="">-- ไม่ระบุ --</option>
                        <option v-for="b in bookings" :key="b.id" :value="b.id">
                            {{ b.route?.routeSummary || b.id }} — {{ formatDate(b.route?.departureTime) }}
                        </option>
                    </select>
                </div>

                <!-- เหตุผล -->
                <div>
                    <label class="block mb-1 text-sm font-medium text-gray-700">เหตุผลในการรายงาน <span class="text-red-500">*</span></label>
                    <select v-model="form.reason" required
                        class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500">
                        <option value="" disabled>-- เลือกเหตุผล --</option>
                        <option value="RECKLESS_DRIVING">ขับรถประมาท</option>
                        <option value="HARASSMENT">คุกคาม / ไม่เหมาะสม</option>
                        <option value="FRAUD">ฉ้อโกง / เก็บเงินเกิน</option>
                        <option value="NO_SHOW">ไม่มาตามนัด</option>
                        <option value="VEHICLE_CONDITION">สภาพรถไม่ดี</option>
                        <option value="ROUTE_DEVIATION">แวะเปลี่ยนเส้นทาง</option>
                        <option value="INAPPROPRIATE_BEHAVIOR">พฤติกรรมไม่เหมาะสม</option>
                        <option value="OTHER">อื่นๆ</option>
                    </select>
                </div>

                <!-- รายละเอียด -->
                <div>
                    <label class="block mb-1 text-sm font-medium text-gray-700">รายละเอียด <span class="text-red-500">*</span></label>
                    <textarea v-model="form.description" required rows="4" minlength="10" maxlength="2000"
                        placeholder="กรุณาอธิบายรายละเอียดของปัญหาที่พบ (อย่างน้อย 10 ตัวอักษร)"
                        class="w-full px-3 py-2 border border-gray-300 rounded-lg resize-none focus:outline-none focus:ring-2 focus:ring-blue-500"></textarea>
                    <p class="mt-1 text-xs text-gray-400">{{ form.description.length }}/2000</p>
                </div>

                <!-- อัพโหลดหลักฐาน -->
                <div>
                    <label class="block mb-1 text-sm font-medium text-gray-700">หลักฐาน (รูปภาพ/วิดีโอ)</label>
                    <p class="mb-2 text-xs text-gray-400">รองรับ JPEG, PNG, MP4, MP3 สูงสุด 20MB ต่อไฟล์ (ไม่เกิน 5 ไฟล์)</p>

                    <div class="flex flex-wrap gap-3">
                        <!-- Preview ไฟล์ -->
                        <div v-for="(file, idx) in previewFiles" :key="idx"
                            class="relative w-24 h-24 overflow-hidden border border-gray-200 rounded-lg">
                            <img v-if="file.type === 'image'" :src="file.url" class="object-cover w-full h-full" />
                            <div v-else class="flex flex-col items-center justify-center w-full h-full bg-gray-100">
                                <svg class="w-8 h-8 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z" />
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                                </svg>
                                <span class="mt-1 text-xs text-gray-500">วิดีโอ</span>
                            </div>
                            <button type="button" @click="removeFile(idx)"
                                class="absolute top-0 right-0 flex items-center justify-center w-5 h-5 text-white bg-red-500 rounded-bl-lg hover:bg-red-600">
                                <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                                </svg>
                            </button>
                        </div>

                        <!-- ปุ่มเพิ่มไฟล์ -->
                        <label v-if="selectedFiles.length < 5"
                            class="flex flex-col items-center justify-center w-24 h-24 border-2 border-dashed border-gray-300 rounded-lg cursor-pointer hover:border-blue-400 hover:bg-blue-50 transition-colors">
                            <svg class="w-6 h-6 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
                            </svg>
                            <span class="mt-1 text-xs text-gray-400">เพิ่มไฟล์</span>
                            <input type="file" class="hidden" accept="image/jpeg,image/jpg,image/png,video/mp4,audio/mpeg,audio/mp3"
                                multiple @change="handleFileSelect" />
                        </label>
                    </div>
                </div>

                <!-- ปุ่ม Submit -->
                <div class="flex items-center gap-3 pt-4 border-t border-gray-200">
                    <button type="submit" :disabled="submitting"
                        class="px-6 py-2.5 bg-red-600 text-white rounded-lg font-medium hover:bg-red-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors">
                        <span v-if="submitting" class="flex items-center gap-2">
                            <svg class="w-4 h-4 animate-spin" fill="none" viewBox="0 0 24 24">
                                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" />
                                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v4a4 4 0 00-4 4H4z" />
                            </svg>
                            กำลังส่ง...
                        </span>
                        <span v-else>ส่งรายงาน</span>
                    </button>
                    <NuxtLink to="/report"
                        class="px-6 py-2.5 text-gray-600 bg-gray-100 rounded-lg font-medium hover:bg-gray-200 transition-colors">
                        ยกเลิก
                    </NuxtLink>
                </div>
            </form>
        </div>
    </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useAuth } from '~/composables/useAuth'
import { useToast } from '~/composables/useToast'

definePageMeta({ middleware: 'auth', layout: 'default' })

const router = useRouter()
const route = useRoute()
const { token } = useAuth()
const { toast } = useToast()
const { $api } = useNuxtApp()

const form = reactive({
    reportedDriverId: route.query.driverId || '',
    bookingId: route.query.bookingId || '',
    reason: '',
    description: '',
})

const drivers = ref([])
const bookings = ref([])
const selectedFiles = ref([])
const submitting = ref(false)

const previewFiles = computed(() =>
    selectedFiles.value.map((file) => ({
        type: file.type.startsWith('image/') ? 'image' : 'video',
        url: URL.createObjectURL(file),
    }))
)

onMounted(async () => {
    await loadMyBookings()
})

async function loadMyBookings() {
    try {
        const data = await $api('/bookings/me')
        const myBookings = Array.isArray(data) ? data : []
        bookings.value = myBookings

        // สร้างรายชื่อ driver จาก booking ที่ผ่านมา
        const driverMap = new Map()
        myBookings.forEach((b) => {
            const driverId = b.route?.driverId
            const driverName = b.route?.driver?.firstName
            if (driverId && !driverMap.has(driverId)) {
                driverMap.set(driverId, {
                    id: driverId,
                    firstName: driverName || 'คนขับ',
                    routeSummary: b.route?.routeSummary || '',
                })
            }
        })
        drivers.value = Array.from(driverMap.values())
    } catch (err) {
        console.error('โหลดข้อมูลล้มเหลว:', err)
    }
}

function handleFileSelect(e) {
    const files = Array.from(e.target.files)
    const maxSize = 20 * 1024 * 1024 // 20MB

    for (const file of files) {
        if (selectedFiles.value.length >= 5) {
            toast.warning('จำกัดไฟล์', 'อัพโหลดได้สูงสุด 5 ไฟล์')
            break
        }
        if (file.size > maxSize) {
            toast.error('ไฟล์ใหญ่เกินไป', `${file.name} มีขนาดเกิน 20MB`)
            continue
        }
        selectedFiles.value.push(file)
    }
    e.target.value = ''
}

function removeFile(idx) {
    selectedFiles.value.splice(idx, 1)
}

function formatDate(dateStr) {
    if (!dateStr) return ''
    return new Date(dateStr).toLocaleDateString('th-TH', {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
    })
}

async function submitReport() {
    if (!form.reportedDriverId || !form.reason || form.description.length < 10) {
        toast.warning('กรอกไม่ครบ', 'กรุณากรอกข้อมูลให้ครบถ้วน')
        return
    }

    submitting.value = true
    try {
        const formData = new FormData()
        formData.append('reportedDriverId', form.reportedDriverId)
        if (form.bookingId) formData.append('bookingId', form.bookingId)
        formData.append('reason', form.reason)
        formData.append('description', form.description)
        selectedFiles.value.forEach((file) => formData.append('evidence', file))

        const config = useRuntimeConfig()
        const apiBase = config.public.apiBase
        const res = await fetch(`${apiBase}/reports`, {
            method: 'POST',
            headers: { Authorization: `Bearer ${token.value}` },
            body: formData,
        })

        const json = await res.json()
        if (!res.ok) throw new Error(json.message || 'เกิดข้อผิดพลาด')

        toast.success('สำเร็จ', 'ส่งรายงานเรียบร้อยแล้ว')
        router.push('/report')
    } catch (err) {
        toast.error('ส่งรายงานล้มเหลว', err.message || 'กรุณาลองใหม่อีกครั้ง')
    } finally {
        submitting.value = false
    }
}
</script>

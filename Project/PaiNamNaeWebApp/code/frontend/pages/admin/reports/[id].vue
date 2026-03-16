<template>
    <div>
        <AdminHeader />
        <AdminSidebar />

        <main id="main-content" class="main-content mt-16 ml-0 lg:ml-[280px] p-6">
            <div class="max-w-4xl mx-auto">
                <!-- Back -->
                <NuxtLink to="/admin/reports"
                    class="inline-flex items-center text-sm text-blue-600 hover:text-blue-800 mb-4">
                    <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
                    </svg>
                    กลับไปรายการรายงาน
                </NuxtLink>

                <!-- Loading -->
                <div v-if="isLoading" class="flex items-center justify-center py-20">
                    <svg class="w-8 h-8 text-blue-500 animate-spin" fill="none" viewBox="0 0 24 24">
                        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" />
                        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v4a4 4 0 00-4 4H4z" />
                    </svg>
                </div>

                <template v-else-if="report">
                    <!-- Report Detail Card -->
                    <div class="bg-white border border-gray-200 rounded-xl shadow-sm overflow-hidden">
                        <div class="px-6 py-4 border-b border-gray-200 flex items-center justify-between">
                            <h1 class="text-xl font-bold text-gray-800">รายละเอียดรายงาน #{{ report.id.slice(0, 8) }}</h1>
                            <span :class="statusBadge(report.status)"
                                class="inline-flex items-center px-3 py-1 text-sm font-medium rounded-full">
                                {{ statusLabel(report.status) }}
                            </span>
                        </div>

                        <div class="px-6 py-5 grid grid-cols-1 md:grid-cols-2 gap-6">
                            <!-- ผู้รายงาน -->
                            <div>
                                <label class="text-xs font-medium text-gray-500 uppercase">ผู้รายงาน</label>
                                <p class="mt-1 text-sm text-gray-800">{{ report.reporter?.firstName }} {{ report.reporter?.lastName }}</p>
                            </div>

                            <!-- คนขับ -->
                            <div>
                                <label class="text-xs font-medium text-gray-500 uppercase">คนขับที่ถูกรายงาน</label>
                                <p class="mt-1 text-sm text-gray-800">{{ report.reportedDriver?.firstName }} {{ report.reportedDriver?.lastName }}</p>
                            </div>

                            <!-- เหตุผล -->
                            <div>
                                <label class="text-xs font-medium text-gray-500 uppercase">เหตุผล</label>
                                <p class="mt-1 text-sm font-semibold text-gray-800">{{ reasonLabel(report.reason) }}</p>
                            </div>

                            <!-- Booking -->
                            <div>
                                <label class="text-xs font-medium text-gray-500 uppercase">การจอง</label>
                                <p class="mt-1 text-sm text-gray-700">
                                    <template v-if="report.booking">
                                        {{ report.booking.route?.routeSummary || report.booking.id }}
                                    </template>
                                    <span v-else class="text-gray-400">ไม่ระบุ</span>
                                </p>
                            </div>

                            <!-- รายละเอียด -->
                            <div class="md:col-span-2">
                                <label class="text-xs font-medium text-gray-500 uppercase">รายละเอียด</label>
                                <p class="mt-1 text-sm text-gray-700 whitespace-pre-wrap">{{ report.description }}</p>
                            </div>

                            <!-- หลักฐาน -->
                            <div v-if="report.evidence && report.evidence.length > 0" class="md:col-span-2">
                                <label class="text-xs font-medium text-gray-500 uppercase">หลักฐาน</label>
                                <div class="flex flex-wrap gap-3 mt-2">
                                    <div v-for="(ev, idx) in report.evidence" :key="idx"
                                        class="relative w-32 h-32 rounded-lg overflow-hidden border border-gray-200">
                                        <a v-if="ev.type === 'image'" :href="ev.url" target="_blank">
                                            <img :src="ev.url" class="object-cover w-full h-full hover:opacity-80 transition-opacity" />
                                        </a>
                                        <a v-else :href="ev.url" target="_blank"
                                            class="flex flex-col items-center justify-center w-full h-full bg-gray-100 hover:bg-gray-200 transition-colors">
                                            <svg class="w-10 h-10 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                                    d="M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z" />
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                                    d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                                            </svg>
                                            <span class="mt-1 text-xs text-gray-500">{{ ev.originalName || 'วิดีโอ' }}</span>
                                        </a>
                                    </div>
                                </div>
                            </div>

                            <!-- วันที่ -->
                            <div class="md:col-span-2 flex items-center gap-6 pt-4 border-t border-gray-200 text-xs text-gray-400">
                                <span>สร้างเมื่อ: {{ formatDate(report.createdAt) }}</span>
                                <span v-if="report.resolvedAt">ดำเนินการเมื่อ: {{ formatDate(report.resolvedAt) }}</span>
                            </div>
                        </div>
                    </div>

                    <!-- Admin Action Card -->
                    <div class="mt-6 bg-white border border-gray-200 rounded-xl shadow-sm p-6">
                        <h2 class="text-lg font-semibold text-gray-800 mb-4">จัดการรายงาน</h2>

                        <div class="space-y-4">
                            <!-- เปลี่ยนสถานะ -->
                            <div>
                                <label class="block mb-1 text-sm font-medium text-gray-700">เปลี่ยนสถานะ</label>
                                <select v-model="updateForm.status"
                                    class="w-full max-w-xs px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500">
                                    <option value="PENDING">รอดำเนินการ</option>
                                    <option value="REVIEWING">กำลังตรวจสอบ</option>
                                    <option value="RESOLVED">ดำเนินการแล้ว</option>
                                    <option value="DISMISSED">ยกเลิก / ไม่พบปัญหา</option>
                                </select>
                            </div>

                            <!-- หมายเหตุ -->
                            <div>
                                <label class="block mb-1 text-sm font-medium text-gray-700">หมายเหตุ (ไม่บังคับ)</label>
                                <textarea v-model="updateForm.adminNotes" rows="3" maxlength="2000"
                                    placeholder="หมายเหตุเพิ่มเติมสำหรับรายงานนี้..."
                                    class="w-full px-3 py-2 border border-gray-300 rounded-lg resize-none focus:outline-none focus:ring-2 focus:ring-blue-500"></textarea>
                            </div>

                            <!-- ปุ่ม -->
                            <button @click="handleUpdateStatus" :disabled="updating"
                                class="px-6 py-2.5 bg-blue-600 text-white rounded-lg font-medium hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors">
                                <span v-if="updating">กำลังอัพเดท...</span>
                                <span v-else>อัพเดทสถานะ</span>
                            </button>
                        </div>
                    </div>

                    <!-- Admin Notes History -->
                    <div v-if="report.adminNotes" class="mt-6 bg-blue-50 border border-blue-200 rounded-xl p-6">
                        <h2 class="text-sm font-semibold text-blue-700 mb-2">หมายเหตุแอดมินปัจจุบัน</h2>
                        <p class="text-sm text-blue-800 whitespace-pre-wrap">{{ report.adminNotes }}</p>
                    </div>
                </template>

                <!-- Not Found -->
                <div v-else class="py-20 text-center">
                    <p class="text-gray-500">ไม่พบรายงานนี้</p>
                </div>
            </div>
        </main>
    </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { useAuth } from '~/composables/useAuth'
import { useToast } from '~/composables/useToast'

definePageMeta({ middleware: 'admin-auth' })

const route = useRoute()
const { token } = useAuth()
const { toast } = useToast()

const report = ref(null)
const isLoading = ref(true)
const updating = ref(false)
const updateForm = reactive({ status: 'PENDING', adminNotes: '' })

onMounted(async () => {
    try {
        const config = useRuntimeConfig()
        const res = await fetch(`${config.public.apiBase}/reports/${route.params.id}`, {
            headers: { Authorization: `Bearer ${token.value}` },
        })
        const json = await res.json()
        if (json.success) {
            report.value = json.data
            updateForm.status = json.data.status
            updateForm.adminNotes = json.data.adminNotes || ''
        }
    } catch (err) {
        console.error('โหลดรายงานล้มเหลว:', err)
    } finally {
        isLoading.value = false
    }
})

async function handleUpdateStatus() {
    updating.value = true
    try {
        const config = useRuntimeConfig()
        const res = await fetch(`${config.public.apiBase}/reports/${route.params.id}/status`, {
            method: 'PATCH',
            headers: {
                Authorization: `Bearer ${token.value}`,
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                status: updateForm.status,
                adminNotes: updateForm.adminNotes || undefined,
            }),
        })
        const json = await res.json()
        if (!res.ok) throw new Error(json.message || 'เกิดข้อผิดพลาด')

        report.value = json.data
        toast.success('สำเร็จ', 'อัพเดทสถานะรายงานเรียบร้อยแล้ว')
    } catch (err) {
        toast.error('ล้มเหลว', err.message || 'ไม่สามารถอัพเดทสถานะได้')
    } finally {
        updating.value = false
    }
}

function reasonLabel(reason) {
    const map = {
        RECKLESS_DRIVING: 'ขับรถประมาท', HARASSMENT: 'คุกคาม', FRAUD: 'ฉ้อโกง',
        NO_SHOW: 'ไม่มาตามนัด', VEHICLE_CONDITION: 'สภาพรถไม่ดี',
        ROUTE_DEVIATION: 'เปลี่ยนเส้นทาง', INAPPROPRIATE_BEHAVIOR: 'พฤติกรรมไม่เหมาะสม', OTHER: 'อื่นๆ',
    }
    return map[reason] || reason
}

function statusLabel(status) {
    const map = { PENDING: 'รอดำเนินการ', REVIEWING: 'กำลังตรวจสอบ', RESOLVED: 'ดำเนินการแล้ว', DISMISSED: 'ยกเลิก' }
    return map[status] || status
}

function statusBadge(status) {
    const map = {
        PENDING: 'bg-yellow-100 text-yellow-700', REVIEWING: 'bg-blue-100 text-blue-700',
        RESOLVED: 'bg-green-100 text-green-700', DISMISSED: 'bg-gray-100 text-gray-600',
    }
    return map[status] || 'bg-gray-100 text-gray-600'
}

function formatDate(dateStr) {
    if (!dateStr) return ''
    return new Date(dateStr).toLocaleDateString('th-TH', {
        year: 'numeric', month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit',
    })
}
</script>

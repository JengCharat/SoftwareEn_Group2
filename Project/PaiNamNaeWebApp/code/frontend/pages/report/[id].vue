<template>
    <div class="min-h-screen bg-gray-50">
        <div class="max-w-3xl px-4 py-8 mx-auto sm:px-6 lg:px-8">
            <!-- Back -->
            <NuxtLink to="/report" class="inline-flex items-center text-sm text-blue-600 hover:text-blue-800 mb-4">
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
                <!-- Header Card -->
                <div class="bg-white border border-gray-200 rounded-xl shadow-sm overflow-hidden">
                    <div class="px-6 py-4 border-b border-gray-200 flex items-center justify-between">
                        <h1 class="text-xl font-bold text-gray-800">รายละเอียดรายงาน</h1>
                        <span :class="statusBadge(report.status)"
                            class="inline-flex items-center px-3 py-1 text-sm font-medium rounded-full">
                            {{ statusLabel(report.status) }}
                        </span>
                    </div>

                    <div class="px-6 py-5 space-y-4">
                        <!-- เหตุผล -->
                        <div>
                            <label class="text-xs font-medium text-gray-500 uppercase">เหตุผล</label>
                            <p class="mt-1 text-sm font-semibold text-gray-800">{{ reasonLabel(report.reason) }}</p>
                        </div>

                        <!-- รายละเอียด -->
                        <div>
                            <label class="text-xs font-medium text-gray-500 uppercase">รายละเอียด</label>
                            <p class="mt-1 text-sm text-gray-700 whitespace-pre-wrap">{{ report.description }}</p>
                        </div>

                        <!-- คนขับ -->
                        <div class="flex items-center gap-3">
                            <div>
                                <label class="text-xs font-medium text-gray-500 uppercase">คนขับที่ถูกรายงาน</label>
                                <div class="flex items-center gap-2 mt-1">
                                    <img v-if="report.reportedDriver?.profilePicture"
                                        :src="report.reportedDriver.profilePicture"
                                        class="w-8 h-8 rounded-full object-cover" />
                                    <span class="text-sm text-gray-800">{{ report.reportedDriver?.firstName || '-' }}</span>
                                </div>
                            </div>
                        </div>

                        <!-- Booking -->
                        <div v-if="report.booking">
                            <label class="text-xs font-medium text-gray-500 uppercase">การจองที่เกี่ยวข้อง</label>
                            <p class="mt-1 text-sm text-gray-700">
                                {{ report.booking.route?.routeSummary || report.booking.id }}
                                <span v-if="report.booking.route?.departureTime" class="text-gray-400">
                                    — {{ formatDate(report.booking.route.departureTime) }}
                                </span>
                            </p>
                        </div>

                        <!-- หลักฐาน -->
                        <div v-if="report.evidence && report.evidence.length > 0">
                            <label class="text-xs font-medium text-gray-500 uppercase">หลักฐาน</label>
                            <div class="flex flex-wrap gap-3 mt-2">
                                <div v-for="(ev, idx) in report.evidence" :key="idx"
                                    class="relative w-28 h-28 rounded-lg overflow-hidden border border-gray-200">
                                    <a v-if="ev.type === 'image'" :href="ev.url" target="_blank">
                                        <img :src="ev.url" class="object-cover w-full h-full hover:opacity-80 transition-opacity" />
                                    </a>
                                    <a v-else :href="ev.url" target="_blank"
                                        class="flex flex-col items-center justify-center w-full h-full bg-gray-100 hover:bg-gray-200 transition-colors">
                                        <svg class="w-8 h-8 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                                d="M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z" />
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                                d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                                        </svg>
                                        <span class="mt-1 text-xs text-gray-500">ดูวิดีโอ</span>
                                    </a>
                                </div>
                            </div>
                        </div>

                        <!-- วันที่ -->
                        <div class="flex items-center gap-6 pt-4 border-t border-gray-200 text-xs text-gray-400">
                            <span>สร้างเมื่อ: {{ formatDate(report.createdAt) }}</span>
                            <span v-if="report.resolvedAt">ดำเนินการเมื่อ: {{ formatDate(report.resolvedAt) }}</span>
                        </div>

                        <!-- Admin Notes -->
                        <div v-if="report.adminNotes"
                            class="mt-4 p-4 bg-blue-50 border border-blue-200 rounded-lg">
                            <label class="text-xs font-medium text-blue-600 uppercase">หมายเหตุจากแอดมิน</label>
                            <p class="mt-1 text-sm text-blue-800 whitespace-pre-wrap">{{ report.adminNotes }}</p>
                        </div>
                    </div>
                </div>

                <!-- Timeline -->
                <div class="mt-6 bg-white border border-gray-200 rounded-xl shadow-sm p-6">
                    <h2 class="text-sm font-semibold text-gray-700 mb-4">สถานะรายงาน</h2>
                    <div class="space-y-4">
                        <div class="flex items-start gap-3">
                            <div class="w-3 h-3 mt-1 bg-green-500 rounded-full"></div>
                            <div>
                                <p class="text-sm font-medium text-gray-800">ส่งรายงานแล้ว</p>
                                <p class="text-xs text-gray-400">{{ formatDate(report.createdAt) }}</p>
                            </div>
                        </div>
                        <div v-if="report.status !== 'PENDING'" class="flex items-start gap-3">
                            <div class="w-3 h-3 mt-1 bg-blue-500 rounded-full"></div>
                            <div>
                                <p class="text-sm font-medium text-gray-800">แอดมินกำลังตรวจสอบ</p>
                            </div>
                        </div>
                        <div v-if="report.status === 'RESOLVED' || report.status === 'DISMISSED'"
                            class="flex items-start gap-3">
                            <div class="w-3 h-3 mt-1 rounded-full"
                                :class="report.status === 'RESOLVED' ? 'bg-green-500' : 'bg-gray-400'"></div>
                            <div>
                                <p class="text-sm font-medium text-gray-800">{{ statusLabel(report.status) }}</p>
                                <p v-if="report.resolvedAt" class="text-xs text-gray-400">{{ formatDate(report.resolvedAt) }}</p>
                            </div>
                        </div>
                    </div>
                </div>
            </template>

            <!-- Not Found -->
            <div v-else class="py-20 text-center">
                <p class="text-gray-500">ไม่พบรายงานนี้</p>
            </div>
        </div>
    </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { useAuth } from '~/composables/useAuth'

definePageMeta({ middleware: 'auth', layout: 'default' })

const route = useRoute()
const { token } = useAuth()

const report = ref(null)
const isLoading = ref(true)

onMounted(async () => {
    try {
        const config = useRuntimeConfig()
        const res = await fetch(`${config.public.apiBase}/reports/${route.params.id}`, {
            headers: { Authorization: `Bearer ${token.value}` },
        })
        const json = await res.json()
        if (json.success) report.value = json.data
    } catch (err) {
        console.error('โหลดรายงานล้มเหลว:', err)
    } finally {
        isLoading.value = false
    }
})

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

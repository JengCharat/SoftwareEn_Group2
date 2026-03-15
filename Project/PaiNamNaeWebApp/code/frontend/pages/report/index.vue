<template>
    <div class="min-h-screen bg-gray-50">
        <div class="max-w-4xl px-4 py-8 mx-auto sm:px-6 lg:px-8">
            <!-- Header -->
            <div class="flex items-center justify-between mb-6">
                <div>
                    <h1 class="text-2xl font-bold text-gray-800">รายงานของฉัน</h1>
                    <p class="mt-1 text-sm text-gray-500">ติดตามสถานะรายงานที่คุณส่ง</p>
                </div>
                <NuxtLink to="/report/create"
                    class="inline-flex items-center gap-2 px-4 py-2.5 bg-red-600 text-white rounded-lg font-medium hover:bg-red-700 transition-colors">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
                    </svg>
                    สร้างรายงานใหม่
                </NuxtLink>
            </div>

            <!-- Loading -->
            <div v-if="isLoading" class="flex items-center justify-center py-20">
                <svg class="w-8 h-8 text-blue-500 animate-spin" fill="none" viewBox="0 0 24 24">
                    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" />
                    <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v4a4 4 0 00-4 4H4z" />
                </svg>
            </div>

            <!-- Empty State -->
            <div v-else-if="reports.length === 0" class="py-20 text-center">
                <svg class="w-16 h-16 mx-auto text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
                        d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                </svg>
                <p class="mt-4 text-gray-500">ยังไม่มีรายงาน</p>
                <NuxtLink to="/report/create"
                    class="inline-block px-4 py-2 mt-4 text-white bg-red-600 rounded-lg hover:bg-red-700">
                    สร้างรายงานแรก
                </NuxtLink>
            </div>

            <!-- Report List -->
            <div v-else class="space-y-4">
                <NuxtLink v-for="r in reports" :key="r.id" :to="`/report/${r.id}`"
                    class="block bg-white border border-gray-200 rounded-xl p-5 hover:shadow-md transition-shadow">
                    <div class="flex items-start justify-between">
                        <div class="flex-1 min-w-0">
                            <div class="flex items-center gap-2 mb-1">
                                <span class="text-sm font-semibold text-gray-800">{{ reasonLabel(r.reason) }}</span>
                                <span :class="statusBadge(r.status)"
                                    class="inline-flex items-center px-2 py-0.5 text-xs font-medium rounded-full">
                                    {{ statusLabel(r.status) }}
                                </span>
                            </div>
                            <p class="text-sm text-gray-600 line-clamp-2">{{ r.description }}</p>
                            <div class="flex items-center gap-4 mt-2 text-xs text-gray-400">
                                <span>คนขับ: {{ r.reportedDriver?.firstName || '-' }}</span>
                                <span>{{ formatDate(r.createdAt) }}</span>
                            </div>
                        </div>
                        <svg class="flex-shrink-0 w-5 h-5 text-gray-400" fill="none" stroke="currentColor"
                            viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
                        </svg>
                    </div>
                </NuxtLink>
            </div>

            <!-- Pagination -->
            <div v-if="pagination.totalPages > 1" class="flex items-center justify-center gap-2 mt-6">
                <button @click="changePage(pagination.page - 1)" :disabled="pagination.page <= 1"
                    class="px-3 py-1.5 text-sm bg-white border rounded-lg disabled:opacity-50">ก่อนหน้า</button>
                <span class="text-sm text-gray-600">หน้า {{ pagination.page }} / {{ pagination.totalPages }}</span>
                <button @click="changePage(pagination.page + 1)"
                    :disabled="pagination.page >= pagination.totalPages"
                    class="px-3 py-1.5 text-sm bg-white border rounded-lg disabled:opacity-50">ถัดไป</button>
            </div>
        </div>
    </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useAuth } from '~/composables/useAuth'

definePageMeta({ middleware: 'auth', layout: 'default' })

const { $api } = useNuxtApp()
const { token } = useAuth()

const reports = ref([])
const isLoading = ref(true)
const pagination = ref({ page: 1, totalPages: 1 })

onMounted(() => fetchReports())

async function fetchReports(page = 1) {
    isLoading.value = true
    try {
        const config = useRuntimeConfig()
        const res = await fetch(`${config.public.apiBase}/reports/my?page=${page}&limit=20`, {
            headers: { Authorization: `Bearer ${token.value}` },
        })
        const json = await res.json()
        if (json.success) {
            reports.value = json.data || []
            pagination.value = json.pagination || { page: 1, totalPages: 1 }
        }
    } catch (err) {
        console.error('โหลดรายงานล้มเหลว:', err)
    } finally {
        isLoading.value = false
    }
}

function changePage(p) {
    fetchReports(p)
}

function reasonLabel(reason) {
    const map = {
        RECKLESS_DRIVING: 'ขับรถประมาท',
        HARASSMENT: 'คุกคาม',
        FRAUD: 'ฉ้อโกง',
        NO_SHOW: 'ไม่มาตามนัด',
        VEHICLE_CONDITION: 'สภาพรถไม่ดี',
        ROUTE_DEVIATION: 'เปลี่ยนเส้นทาง',
        INAPPROPRIATE_BEHAVIOR: 'พฤติกรรมไม่เหมาะสม',
        OTHER: 'อื่นๆ',
    }
    return map[reason] || reason
}

function statusLabel(status) {
    const map = { PENDING: 'รอดำเนินการ', REVIEWING: 'กำลังตรวจสอบ', RESOLVED: 'ดำเนินการแล้ว', DISMISSED: 'ยกเลิก' }
    return map[status] || status
}

function statusBadge(status) {
    const map = {
        PENDING: 'bg-yellow-100 text-yellow-700',
        REVIEWING: 'bg-blue-100 text-blue-700',
        RESOLVED: 'bg-green-100 text-green-700',
        DISMISSED: 'bg-gray-100 text-gray-600',
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

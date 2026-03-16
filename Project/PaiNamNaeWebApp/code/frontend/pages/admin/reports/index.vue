<template>
    <div>
        <AdminHeader />
        <AdminSidebar />

        <main id="main-content" class="main-content mt-16 ml-0 lg:ml-[280px] p-6">
            <div class="mx-auto max-w-8xl">
                <!-- Title -->
                <div class="flex flex-col gap-3 mb-6 sm:flex-row sm:items-center sm:justify-between">
                    <h1 class="text-2xl font-semibold text-gray-800">Report Management</h1>
                    <div class="flex items-center gap-2">
                        <select v-model="filters.status"
                            class="px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
                            <option value="">ทุกสถานะ</option>
                            <option value="PENDING">รอดำเนินการ</option>
                            <option value="REVIEWING">กำลังตรวจสอบ</option>
                            <option value="RESOLVED">ดำเนินการแล้ว</option>
                            <option value="DISMISSED">ยกเลิก</option>
                        </select>
                        <button @click="fetchReports"
                            class="px-4 py-2 text-white bg-blue-600 rounded-md cursor-pointer hover:bg-blue-700">
                            กรอง
                        </button>
                    </div>
                </div>

                <!-- Loading -->
                <div v-if="isLoading" class="flex items-center justify-center py-20">
                    <svg class="w-8 h-8 text-blue-500 animate-spin" fill="none" viewBox="0 0 24 24">
                        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" />
                        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v4a4 4 0 00-4 4H4z" />
                    </svg>
                </div>

                <!-- Table -->
                <div v-else class="overflow-x-auto bg-white border border-gray-200 rounded-lg shadow-sm">
                    <table class="min-w-full divide-y divide-gray-200">
                        <thead class="bg-gray-50">
                            <tr>
                                <th class="px-4 py-3 text-xs font-medium tracking-wider text-left text-gray-500 uppercase">ผู้รายงาน</th>
                                <th class="px-4 py-3 text-xs font-medium tracking-wider text-left text-gray-500 uppercase">คนขับ</th>
                                <th class="px-4 py-3 text-xs font-medium tracking-wider text-left text-gray-500 uppercase">เหตุผล</th>
                                <th class="px-4 py-3 text-xs font-medium tracking-wider text-left text-gray-500 uppercase">สถานะ</th>
                                <th class="px-4 py-3 text-xs font-medium tracking-wider text-left text-gray-500 uppercase">วันที่</th>
                                <th class="px-4 py-3 text-xs font-medium tracking-wider text-center text-gray-500 uppercase">จัดการ</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-200">
                            <tr v-if="reports.length === 0">
                                <td colspan="6" class="px-4 py-8 text-sm text-center text-gray-500">ไม่พบรายงาน</td>
                            </tr>
                            <tr v-for="r in reports" :key="r.id" class="hover:bg-gray-50">
                                <td class="px-4 py-3 text-sm text-gray-800">
                                    <div>{{ r.reporter?.firstName }} {{ r.reporter?.lastName }}</div>
                                    <div class="text-xs text-gray-400">{{ r.reporter?.email }}</div>
                                </td>
                                <td class="px-4 py-3 text-sm text-gray-800">
                                    <div>{{ r.reportedDriver?.firstName }} {{ r.reportedDriver?.lastName }}</div>
                                    <div class="text-xs text-gray-400">{{ r.reportedDriver?.email }}</div>
                                </td>
                                <td class="px-4 py-3 text-sm text-gray-700">{{ reasonLabel(r.reason) }}</td>
                                <td class="px-4 py-3">
                                    <span :class="statusBadge(r.status)"
                                        class="inline-flex items-center px-2 py-0.5 text-xs font-medium rounded-full">
                                        {{ statusLabel(r.status) }}
                                    </span>
                                </td>
                                <td class="px-4 py-3 text-xs text-gray-500">{{ formatDate(r.createdAt) }}</td>
                                <td class="px-4 py-3 text-center">
                                    <NuxtLink :to="`/admin/reports/${r.id}`"
                                        class="inline-flex items-center gap-1 px-3 py-1.5 text-xs font-medium text-blue-600 bg-blue-50 rounded-md hover:bg-blue-100">
                                        <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                                d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                                d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                                        </svg>
                                        ดู
                                    </NuxtLink>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>

                <!-- Pagination -->
                <div v-if="pagination.totalPages > 1" class="flex items-center justify-between mt-4">
                    <span class="text-sm text-gray-500">ทั้งหมด {{ pagination.total }} รายการ</span>
                    <div class="flex items-center gap-2">
                        <button @click="changePage(pagination.page - 1)" :disabled="pagination.page <= 1"
                            class="px-3 py-1.5 text-sm bg-white border rounded-md disabled:opacity-50 hover:bg-gray-50">
                            ก่อนหน้า
                        </button>
                        <span class="text-sm text-gray-600">{{ pagination.page }} / {{ pagination.totalPages }}</span>
                        <button @click="changePage(pagination.page + 1)"
                            :disabled="pagination.page >= pagination.totalPages"
                            class="px-3 py-1.5 text-sm bg-white border rounded-md disabled:opacity-50 hover:bg-gray-50">
                            ถัดไป
                        </button>
                    </div>
                </div>
            </div>
        </main>
    </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useAuth } from '~/composables/useAuth'

definePageMeta({ middleware: 'admin-auth' })

const { token } = useAuth()

const reports = ref([])
const isLoading = ref(true)
const pagination = ref({ page: 1, totalPages: 1, total: 0 })
const filters = reactive({ status: '' })

onMounted(() => fetchReports())

async function fetchReports(page = 1) {
    isLoading.value = true
    try {
        const config = useRuntimeConfig()
        const params = new URLSearchParams({ page, limit: 20 })
        if (filters.status) params.set('status', filters.status)

        const res = await fetch(`${config.public.apiBase}/reports/admin?${params}`, {
            headers: { Authorization: `Bearer ${token.value}` },
        })
        const json = await res.json()
        if (json.success) {
            reports.value = json.data || []
            pagination.value = json.pagination || { page: 1, totalPages: 1, total: 0 }
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

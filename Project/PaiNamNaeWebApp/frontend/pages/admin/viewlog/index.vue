
<template>
    <div>
        <AdminHeader />
        <AdminSidebar />

        <!-- Main Content -->
        <main id="main-content" class="main-content mt-16 ml-0 lg:ml-[280px] p-6">
            <h1>this is viewlog page create by Jeng</h1>
        </main>

        <!-- Mobile Overlay -->
        <div id="overlay" class="fixed inset-0 z-40 hidden bg-black bg-opacity-50 lg:hidden"
            @click="closeMobileSidebar"></div>

        <!-- Confirm Delete Modal -->
        <ConfirmModal :show="showDelete" :title="`ลบการจอง${deletingBooking?.id ? ' : ' + deletingBooking.id : ''}`"
            message="การลบนี้เป็นการลบถาวร ข้อมูลทั้งหมดจะถูกลบและไม่สามารถกู้คืนได้ คุณต้องการดำเนินการต่อหรือไม่?"
            confirmText="ลบถาวร" cancelText="ยกเลิก" variant="danger" @confirm="confirmDelete" @cancel="cancelDelete" />
    </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, onUnmounted } from 'vue'
import { useCookie } from '#app'
import dayjs from 'dayjs'
import 'dayjs/locale/th'
import buddhistEra from 'dayjs/plugin/buddhistEra'
import AdminHeader from '~/components/admin/AdminHeader.vue'
import AdminSidebar from '~/components/admin/AdminSidebar.vue'
import { useToast } from '~/composables/useToast'
import ConfirmModal from '~/components/ConfirmModal.vue'


dayjs.locale('th')
dayjs.extend(buddhistEra)

definePageMeta({ middleware: ['admin-auth'] })

const { toast } = useToast()

const isLoading = ref(false)
const loadError = ref('')

/** raw list from API */
const bookingsAll = ref([])

/** UI state (same pattern as routes index) */
const pagination = reactive({
    page: 1,
    limit: 20,
    total: 0,
    totalPages: 1
})

const filters = reactive({
    q: '',
    pickupName: '',
    dropoffName: '',
    status: '',
    departureFrom: '',
    departureTo: '',
    sort: ''
})

/* ---------- helpers to mirror routes index look&feel ---------- */
function statusBadge(s) {
    if (s === 'CONFIRMED') return 'bg-green-100 text-green-700'
    if (s === 'PENDING') return 'bg-amber-100 text-amber-700'
    if (s === 'REJECTED') return 'bg-red-100 text-red-700'
    if (s === 'CANCELLED') return 'bg-gray-200 text-gray-700'
    return 'bg-gray-100 text-gray-700'
}
function statusIcon(s) {
    if (s === 'CONFIRMED') return 'fa-circle-check'
    if (s === 'PENDING') return 'fa-hourglass-half'
    if (s === 'REJECTED') return 'fa-circle-xmark'
    if (s === 'CANCELLED') return 'fa-ban'
    return 'fa-circle'
}
function formatDate(iso) {
    if (!iso) return '-'
    return dayjs(iso).format('D MMMM BBBB HH:mm')
}
function formatKm(meters) {
    if (!meters && meters !== 0) return '-'
    const km = meters / 1000
    return `${km.toFixed(km < 10 ? 1 : 0)} กม.`
}
function formatDuration(sec) {
    if (!sec && sec !== 0) return '-'
    const h = Math.floor(sec / 3600)
    const m = Math.round((sec % 3600) / 60)
    return h ? `${h} ชม. ${m} นาที` : `${m} นาที`
}
function parseSort(s) {
    const [by, order] = (s || '').split(':')
    if (!by || !['asc', 'desc'].includes(order)) return { by: undefined, order: undefined }
    return { by, order }
}

/* ---------- client-side filtering/sorting to ensure identical UI ---------- */
const filteredSorted = computed(() => {
    let list = [...(bookingsAll.value || [])]

    // text search
    const q = (filters.q || '').toLowerCase().trim()
    if (q) {
        list = list.filter(b => {
            const fields = [
                b?.passenger?.firstName, b?.passenger?.lastName, b?.passenger?.email, b?.passenger?.username,
                b?.route?.driver?.firstName, b?.route?.driver?.lastName,
                b?.route?.vehicle?.vehicleModel, b?.route?.vehicle?.vehicleType,
                b?.route?.startLocation?.name, b?.route?.endLocation?.name,
                b?.pickupLocation?.name, b?.dropoffLocation?.name
            ]
            return fields.some(v => (v || '').toString().toLowerCase().includes(q))
        })
    }

    // pickup/dropoff name
    const pName = (filters.pickupName || '').toLowerCase().trim()
    if (pName) {
        list = list.filter(b => (b?.pickupLocation?.name || '').toLowerCase().includes(pName))
    }
    const dName = (filters.dropoffName || '').toLowerCase().trim()
    if (dName) {
        list = list.filter(b => (b?.dropoffLocation?.name || '').toLowerCase().includes(dName))
    }

    // status
    if (filters.status) {
        list = list.filter(b => (b?.status || '').toUpperCase() === filters.status.toUpperCase())
    }

    // departure date range (route.departureTime)
    if (filters.departureFrom) {
        const from = dayjs(filters.departureFrom).startOf('day')
        list = list.filter(b => b?.route?.departureTime && dayjs(b.route.departureTime).isAfter(from.subtract(1, 'ms')))
    }
    if (filters.departureTo) {
        const to = dayjs(filters.departureTo).endOf('day')
        list = list.filter(b => b?.route?.departureTime && dayjs(b.route.departureTime).isBefore(to.add(1, 'ms')))
    }

    // sorting
    const { by, order } = parseSort(filters.sort)
    if (by) {
        const path = by.split('.')
        list.sort((a, b) => {
            const va = path.reduce((o, k) => (o ? o[k] : undefined), a)
            const vb = path.reduce((o, k) => (o ? o[k] : undefined), b)
            // date or number or string compare
            const A = typeof va === 'string' && dayjs(va).isValid() ? +dayjs(va) : va
            const B = typeof vb === 'string' && dayjs(vb).isValid() ? +dayjs(vb) : vb
            if (A == null && B == null) return 0
            if (A == null) return order === 'asc' ? 1 : -1
            if (B == null) return order === 'asc' ? -1 : 1
            if (A < B) return order === 'asc' ? -1 : 1
            if (A > B) return order === 'asc' ? 1 : -1
            return 0
        })
    }

    return list
})

/* ---------- pagination identical to routes page ---------- */
const totalPages = computed(() =>
    Math.max(1, Math.ceil((filteredSorted.value.length || 0) / (pagination.limit || 20)))
)

const pageButtons = computed(() => {
    const total = totalPages.value
    const current = pagination.page
    if (!total || total < 1) return []
    if (total <= 5) return Array.from({ length: total }, (_, i) => i + 1)
    const set = new Set([1, total, current])
    if (current - 1 > 1) set.add(current - 1)
    if (current + 1 < total) set.add(current + 1)
    const pages = Array.from(set).sort((a, b) => a - b)
    const out = []
    for (let i = 0; i < pages.length; i++) {
        if (i > 0 && pages[i] - pages[i - 1] > 1) out.push('…')
        out.push(pages[i])
    }
    return out
})

const pagedBookings = computed(() => {
    const start = (pagination.page - 1) * pagination.limit
    const end = start + pagination.limit
    const slice = filteredSorted.value.slice(start, end)
    pagination.total = filteredSorted.value.length
    pagination.totalPages = totalPages.value
    return slice
})

/* ---------- fetch API (token) ---------- */
async function fetchBookings() {
    isLoading.value = true
    loadError.value = ''
    try {
        const token = useCookie('token').value || (process.client ? localStorage.getItem('token') : '')
        const res = await fetch('http://localhost:3000/api/bookings/admin', {
            headers: {
                Accept: 'application/json',
                ...(token ? { Authorization: `Bearer ${token}` } : {})
            },
            credentials: 'include'
        })
        const body = await res.json()
        if (!res.ok) throw new Error(body?.message || `Request failed: ${res.status}`)
        bookingsAll.value = Array.isArray(body?.data) ? body.data : []
        // reset pagination when new data arrives
        pagination.page = 1
        applyFilters()
    } catch (err) {
        console.error(err)
        loadError.value = err?.message || 'ไม่สามารถโหลดข้อมูลได้'
        toast.error('เกิดข้อผิดพลาด', loadError.value)
        bookingsAll.value = []
    } finally {
        isLoading.value = false
    }
}

function changePage(next) {
    if (next < 1 || next > totalPages.value) return
    pagination.page = next
}
function applyFilters() {
    pagination.page = 1
}
function clearFilters() {
    filters.q = ''
    filters.pickupName = ''
    filters.dropoffName = ''
    filters.status = ''
    filters.departureFrom = ''
    filters.departureTo = ''
    filters.sort = ''
    pagination.page = 1
}

function onViewBooking(b) {
    navigateTo(`/admin/bookings/${b.id}/edit`).catch(() => {
        toast.info('ยังไม่รองรับ', `ดูรายละเอียด Booking: ${b.id}`)
    })
    // ไว้เชื่อมหน้ารายละเอียดภายหลังหากต้องการ
    // toast.info('ยังไม่รองรับ', `ดูรายละเอียด Booking: ${b.id}`)
}
function onEditBooking(b) {
    navigateTo(`/admin/bookings/${b.id}/edit`).catch(() => {
        toast.info('ยังไม่รองรับ', `ดูรายละเอียด Booking: ${b.id}`)
    })
}
function onCreateBooking(b) {
    navigateTo('/admin/bookings/create').catch(() => {
        toast.info('ยังไม่รองรับ', `ดูรายละเอียด Booking: ${b.id}`)
    })
}

const showDelete = ref(false)
const deletingBooking = ref(null)
function askDelete(b) { deletingBooking.value = b; showDelete.value = true }
function cancelDelete() { showDelete.value = false; deletingBooking.value = null }

async function confirmDelete() {
    if (!deletingBooking.value) return
    const b = deletingBooking.value
    try {
        await deleteBooking(b.id)

        // ข้อความสำเร็จให้ตรงกับ booking (อิง route ภายใน booking)
        const fromName = b?.route?.startLocation?.name || '-'
        const toName = b?.route?.endLocation?.name || '-'
        toast.success('ลบการจองเรียบร้อย', `${fromName} → ${toName} ถูกลบถาวรแล้ว`)

        // ปิด modal
        cancelDelete()

        // รีเฟรชรายการ แล้วคงหน้าเพจปัจจุบันให้เหมาะสม
        const currentPage = pagination.page
        await fetchBookings()
        // ถ้าหลังลบแล้วหน้าเกินจำนวนหน้าทั้งหมด ให้เด้งกลับไปหน้าสุดท้าย
        if (currentPage > totalPages.value) {
            changePage(totalPages.value)
        } else {
            changePage(currentPage)
        }
    } catch (err) {
        console.error(err)
        const mapped = normalizeDeleteError(err)
        toast.error(mapped.title, mapped.body)
    }
}
async function deleteBooking(id) {
    const config = useRuntimeConfig()
    const token = useCookie('token').value || (process.client ? localStorage.getItem('token') : '')
    const res = await fetch(`${config.public.apiBase}/bookings/admin/${id}`, {
        method: 'DELETE',
        headers: { Accept: 'application/json', ...(token ? { Authorization: `Bearer ${token}` } : {}) },
        credentials: 'include',
    })
    let body
    try { body = await res.json() } catch {
        const text = await res.text(); const err = new Error(text || 'Unexpected response from server'); err.status = res.status; throw err
    }
    if (!res.ok) { const err = new Error(body?.message || `Request failed with status ${res.status}`); err.status = res.status; err.payload = body; throw err }
    return body
}

function normalizeDeleteError(err) {
    const status = err?.status || err?.response?.status || err?.data?.statusCode
    const raw = err?.message || err?.data?.message || ''
    let title = 'ลบไม่สำเร็จ'
    let body = raw || 'ไม่สามารถลบการจองได้'

    if (status === 404 || /not found/i.test(raw)) {
        title = 'ไม่พบการจอง'
        body = 'รายการนี้อาจถูกลบไปแล้ว หรือไม่พบในระบบ'
    } else if (status === 401 || status === 403) {
        title = 'ไม่ได้รับอนุญาต'
        body = 'สิทธิ์ไม่เพียงพอสำหรับการลบ'
    } else if (status === 409 || /conflict|cannot delete/i.test(raw)) {
        title = 'ไม่สามารถลบได้'
        body = raw || 'มีเงื่อนไขบางอย่างที่ทำให้ลบไม่ได้'
    }

    return { title, body, status, raw }
}

useHead({
    title: 'TailAdmin Dashboard',
    link: [{ rel: 'stylesheet', href: 'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css' }]
})
function closeMobileSidebar() {
    const sidebar = document.getElementById('sidebar')
    const overlay = document.getElementById('overlay')
    if (!sidebar || !overlay) return
    sidebar.classList.remove('mobile-open')
    overlay.classList.add('hidden')
}
function defineGlobalScripts() {
    window.toggleSidebar = function () {
        const sidebar = document.getElementById('sidebar')
        const mainContent = document.getElementById('main-content')
        const toggleIcon = document.getElementById('toggle-icon')
        if (!sidebar || !mainContent || !toggleIcon) return
        sidebar.classList.toggle('collapsed')
        if (sidebar.classList.contains('collapsed')) {
            mainContent.style.marginLeft = '80px'
            toggleIcon.classList.replace('fa-chevron-left', 'fa-chevron-right')
        } else {
            mainContent.style.marginLeft = '280px'
            toggleIcon.classList.replace('fa-chevron-right', 'fa-chevron-left')
        }
    }
    window.toggleMobileSidebar = function () {
        const sidebar = document.getElementById('sidebar')
        const overlay = document.getElementById('overlay')
        if (!sidebar || !overlay) return
        sidebar.classList.toggle('mobile-open')
        overlay.classList.toggle('hidden')
    }
    window.toggleSubmenu = function (menuId) {
        const menu = document.getElementById(menuId)
        const icon = document.getElementById(menuId + '-icon')
        if (!menu || !icon) return
        menu.classList.toggle('hidden')
        if (menu.classList.contains('hidden')) {
            icon.classList.replace('fa-chevron-up', 'fa-chevron-down')
        } else {
            icon.classList.replace('fa-chevron-down', 'fa-chevron-up')
        }
    }
    window.__adminResizeHandler__ = function () {
        const sidebar = document.getElementById('sidebar')
        const mainContent = document.getElementById('main-content')
        const overlay = document.getElementById('overlay')
        if (!sidebar || !mainContent || !overlay) return
        if (window.innerWidth >= 1024) {
            sidebar.classList.remove('mobile-open')
            overlay.classList.add('hidden')
            if (sidebar.classList.contains('collapsed')) {
                mainContent.style.marginLeft = '80px'
            } else {
                mainContent.style.marginLeft = '280px'
            }
        } else {
            mainContent.style.marginLeft = '0'
        }
    }
    window.addEventListener('resize', window.__adminResizeHandler__)
}
function cleanupGlobalScripts() {
    window.removeEventListener('resize', window.__adminResizeHandler__ || (() => { }))
    delete window.toggleSidebar
    delete window.toggleMobileSidebar
    delete window.closeMobileSidebar
    delete window.toggleSubmenu
    delete window.__adminResizeHandler__
}

onMounted(() => {
    defineGlobalScripts()
    if (typeof window.__adminResizeHandler__ === 'function') window.__adminResizeHandler__()
    fetchBookings()
})
onUnmounted(() => { cleanupGlobalScripts() })
</script>

<style>
.sidebar {
    transition: width 0.3s ease;
}

.sidebar.collapsed {
    width: 80px;
}

.sidebar:not(.collapsed) {
    width: 280px;
}

.sidebar-item {
    transition: all 0.3s ease;
}

.sidebar-item:hover {
    background-color: rgba(59, 130, 246, 0.05);
}

.sidebar.collapsed .sidebar-text {
    display: none;
}

.sidebar.collapsed .sidebar-item {
    justify-content: center;
}

.main-content {
    transition: margin-left 0.3s ease;
}

@media (max-width: 768px) {
    .sidebar {
        position: fixed;
        z-index: 1000;
        transform: translateX(-100%);
    }

    .sidebar.mobile-open {
        transform: translateX(0);
    }

    .main-content {
        margin-left: 0 !important;
    }
}
</style>

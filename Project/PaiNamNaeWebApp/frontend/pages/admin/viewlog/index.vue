<template>
  <div>
    <AdminHeader />
    <AdminSidebar />  

    <!-- <!-- Main Content --> -->
    <main id="main-content" class="main-content mt-16 ml-0 lg:ml-70 p-6">

      <h1 class="text-2xl font-semibold mb-6">Activity Logs</h1>

      <div class="bg-white rounded-lg shadow p-4 overflow-x-auto">

        <div v-if="isLoading" class="text-center py-10">
          Loading...
        </div>

        <div v-else-if="loadError" class="text-red-500">
          {{ loadError }}
        </div>

        <table v-else class="min-w-full text-sm">
          <thead>
            <tr class="border-b bg-gray-50">
              <th class="text-left p-2">User</th>
              <th class="text-left p-2">Method</th>
              <th class="text-left p-2">Endpoint</th>
              <th class="text-left p-2">Status</th>
              <th class="text-left p-2">IP</th>
              <th class="text-left p-2">UserAgent</th>

              <th class="text-left p-2">Time</th>
            </tr>
          </thead>

          <tbody>
            <tr
              v-for="log in logsAll"
              :key="log.id"
              class="border-b hover:bg-gray-50"
            >
              <td class="p-2">
                {{ log.user?.email || '-' }}
              </td>

              <td class="p-2 font-medium">
                <span
                  :class="methodColor(log.method)"
                  class="px-2 py-1 rounded text-xs font-semibold"
                >
                  {{ log.method }}
                </span>
              </td>

              <td class="p-2 max-w-xs truncate">
                {{ log.endpoint }}
              </td>

              <td class="p-2">
                <span
                  :class="statusColor(log.statusCode)"
                  class="px-2 py-1 rounded text-xs font-semibold"
                >
                  {{ log.statusCode || '-' }}
                </span>
              </td>

              <td class="p-2">
                {{ log.ipAddress || '-' }}
              </td>

              <td class="p-2">
                {{ log.userAgent || '-' }}
              </td>

              <td class="p-2 whitespace-nowrap">
                {{ formatDate(log.createdAt) }}
              </td>


            </tr>

            <tr v-if="logsAll.length === 0">
              <td colspan="6" class="text-center py-6 text-gray-400">
                No logs found
              </td>
            </tr>
          </tbody>
        </table>

      </div>

    </main>

    <!-- Mobile Overlay -->
  <!--   <div -->
  <!--     id="overlay" -->
  <!--     class="fixed inset-0 z-40 hidden bg-black bg-opacity-50 lg:hidden" -->
  <!--     @click="closeMobileSidebar" -->
  <!--   ></div> -->
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, onUnmounted } from 'vue'
import { useRuntimeConfig, useCookie } from '#app'
import dayjs from 'dayjs'
import 'dayjs/locale/th'
import buddhistEra from 'dayjs/plugin/buddhistEra'
import AdminHeader from '~/components/admin/AdminHeader.vue'
import AdminSidebar from '~/components/admin/AdminSidebar.vue'
import ConfirmModal from '~/components/ConfirmModal.vue'
import { useToast } from '~/composables/useToast'




dayjs.locale('th')
dayjs.extend(buddhistEra)

definePageMeta({ middleware: ['admin-auth'] })

const { toast } = useToast()

const isLoading = ref(false)
const loadError = ref('')
const logsAll = ref([])

function formatDate(iso) {
  if (!iso) return '-'
  return dayjs(iso).format('D MMMM BBBB HH:mm')
}

function methodColor(method) {
  if (!method) return 'bg-gray-100 text-gray-600'

  const map = {
    GET: 'bg-blue-100 text-blue-700',
    POST: 'bg-green-100 text-green-700',
    PUT: 'bg-yellow-100 text-yellow-700',
    PATCH: 'bg-purple-100 text-purple-700',
    DELETE: 'bg-red-100 text-red-700'
  }

  return map[method] || 'bg-gray-100 text-gray-600'
}

function statusColor(code) {
  if (!code) return 'bg-gray-100 text-gray-600'

  if (code >= 200 && code < 300) return 'bg-green-100 text-green-700'
  if (code >= 400 && code < 500) return 'bg-yellow-100 text-yellow-700'
  if (code >= 500) return 'bg-red-100 text-red-700'

  return 'bg-gray-100 text-gray-600'
}

async function fetchLogs() {
  isLoading.value = true
  loadError.value = ''

  try {
    const config = useRuntimeConfig()

    const token =
      useCookie('token').value ||
      (process.client ? localStorage.getItem('token') : '')

    const res = await fetch(`${config.public.apiBase}/users/admin/logs`, {
      headers: {
        Accept: 'application/json',
        ...(token ? { Authorization: `Bearer ${token}` } : {})
      },
      credentials: 'include'
    })

    const body = await res.json()

    if (!res.ok) {
      throw new Error(body?.message || `Request failed: ${res.status}`)
    }

    logsAll.value = Array.isArray(body?.data) ? body.data : []

  } catch (err) {
    console.error(err)
    loadError.value = err?.message || 'ไม่สามารถโหลด logs ได้'
    toast.error('เกิดข้อผิดพลาด', loadError.value)
    logsAll.value = []
  } finally {
    isLoading.value = false
  }
}

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
useHead({
  title: 'TailAdmin Dashboard',
  link: [
    { 
      rel: 'stylesheet', 
      href: 'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css' 
    }
  ]
})

function cleanupGlobalScripts() {
  window.removeEventListener('resize', window.__adminResizeHandler__ || (() => {}))
  delete window.toggleSidebar
  delete window.toggleMobileSidebar
  delete window.__adminResizeHandler__
}

onMounted(() => {
  defineGlobalScripts()

  if (typeof window.__adminResizeHandler__ === 'function') {
    window.__adminResizeHandler__()
  }

  fetchLogs()
})

onUnmounted(() => {
  cleanupGlobalScripts()
})
</script>

<style>
.main-content {
  transition: margin-left 0.3s ease;
}
</style>

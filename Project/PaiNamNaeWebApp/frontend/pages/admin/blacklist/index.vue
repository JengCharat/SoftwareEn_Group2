<template>
  <div>
    <AdminHeader />
    <AdminSidebar />

    <main id="main-content" class="main-content mt-16 ml-0 lg:ml-[280px] p-6">

      <h1 class="mb-6 text-2xl font-bold">Blacklist Management</h1>

      <!-- ======================
           ADD FORM
      ====================== -->

      <div class="p-6 bg-white border border-gray-300 rounded-lg shadow-sm">
        <h2 class="mb-4 text-lg font-semibold">เพิ่มผู้ใช้เข้าสู่ Blacklist</h2>

        <div class="grid grid-cols-1 gap-4 md:grid-cols-3">

          <div>
            <label class="block mb-1 text-sm font-medium text-gray-700">
              เลขบัตรประชาชน *
            </label>
            <input
              v-model="blacklistForm.nationalIdNumber"
              type="text"
              class="w-full px-3 py-2 border rounded-md"
              placeholder="1234567890123"
            />
          </div>

          <div>
            <label class="block mb-1 text-sm font-medium text-gray-700">
              เหตุผล
            </label>
            <input
              v-model="blacklistForm.reason"
              type="text"
              class="w-full px-3 py-2 border rounded-md"
              placeholder="Fraud / Abuse"
            />
          </div>

          <div>
            <label class="block mb-1 text-sm font-medium text-gray-700">
              วันหมดอายุ
            </label>
            <input
              v-model="blacklistForm.expiresAt"
              type="date"
              class="w-full px-3 py-2 border rounded-md"
            />
          </div>

        </div>

        <div class="mt-6">
          <button
            @click="submitBlacklist"
            :disabled="isSubmitting"
            class="px-5 py-2 text-white bg-red-600 rounded-md hover:bg-red-700 disabled:opacity-50"
          >
            {{ isSubmitting ? 'กำลังบันทึก...' : 'เพิ่ม Blacklist' }}
          </button>
        </div>
      </div>



      <!-- ======================
           TABLE
      ====================== -->

      <div class="bg-white rounded-lg shadow p-4 overflow-x-auto mt-6">

        <div v-if="isLoading" class="text-center py-10">
          Loading...
        </div>

        <div v-else-if="loadError" class="text-red-500">
          {{ loadError }}
        </div>

        <table v-else class="min-w-full text-sm border-collapse">

          <thead class="bg-gray-100">
            <tr>
              <th class="p-2 border">#</th>
              <th class="p-2 border">National ID</th>
              <th class="p-2 border">User</th>
              <th class="p-2 border">Reason</th>
              <th class="p-2 border">Expire</th>
              <th class="p-2 border">Created</th>
            </tr>
          </thead>

          <tbody>

            <tr v-for="(item, index) in blacklistAll" :key="item.id">
              <td class="p-2 border">{{ index + 1 }}</td>

              <td class="p-2 border">
                {{ item.nationalIdNumber }}
              </td>

              <td class="p-2 border">
                {{ item.user?.email || '-' }}
              </td>

              <td class="p-2 border">
                {{ item.reason || '-' }}
              </td>

              <td class="p-2 border">
                {{ item.expiresAt
                  ? new Date(item.expiresAt).toLocaleDateString()
                  : '-' }}
              </td>

              <td class="p-2 border">
                {{ new Date(item.createdAt).toLocaleString() }}
              </td>
            </tr>

            <tr v-if="blacklistAll.length === 0">
              <td colspan="6" class="p-4 text-center text-gray-400">
                ไม่มีข้อมูล
              </td>
            </tr>

          </tbody>

        </table>

      </div>

    </main>

    <!-- Mobile Overlay -->
    <div
      id="overlay"
      class="fixed inset-0 z-40 hidden bg-black bg-opacity-50 lg:hidden"
      @click="closeMobileSidebar"
    ></div>

  </div>
</template>

<script setup>
import { reactive, ref, onMounted, onUnmounted } from 'vue'
import { useRuntimeConfig, useCookie } from '#app'
import AdminHeader from '~/components/admin/AdminHeader.vue'
import AdminSidebar from '~/components/admin/AdminSidebar.vue'
import { useToast } from '~/composables/useToast'

definePageMeta({ middleware: ['admin-auth'] })

const { toast } = useToast()

/* ======================
   STATE
====================== */

const blacklistAll = ref([])
const isLoading = ref(false)
const loadError = ref('')

const blacklistForm = reactive({
  nationalIdNumber: '',
  reason: '',
  expiresAt: ''
})

const isSubmitting = ref(false)



/* ======================
   FETCH LIST
====================== */

async function fetchBlacklistUser() {
  isLoading.value = true
  loadError.value = ''

  try {
    const config = useRuntimeConfig()

    const token =
      useCookie('token').value ||
      (process.client ? localStorage.getItem('token') : '')

    const res = await fetch(
      `${config.public.apiBase}/users/admin/blacklistUserlist`,
      {
        headers: {
          Accept: 'application/json',
          ...(token ? { Authorization: `Bearer ${token}` } : {})
        },
        credentials: 'include'
      }
    )

    const body = await res.json()

    if (!res.ok) {
      throw new Error(body?.message || `Request failed: ${res.status}`)
    }

    blacklistAll.value = Array.isArray(body?.data) ? body.data : []

  } catch (err) {
    console.error(err)
    loadError.value = err?.message || 'ไม่สามารถโหลดข้อมูลได้'
    blacklistAll.value = []
    toast.error('Error', loadError.value)
  } finally {
    isLoading.value = false
  }
}



/* ======================
   SUBMIT
====================== */

async function submitBlacklist() {

  if (!blacklistForm.nationalIdNumber) {
    toast.error('กรอกข้อมูลไม่ครบ', 'กรุณาใส่เลขบัตรประชาชน')
    return
  }

  isSubmitting.value = true

  try {
    const config = useRuntimeConfig()

    const token =
      useCookie('token').value ||
      (process.client ? localStorage.getItem('token') : '')

     await fetch(`${config.public.apiBase}/users/blacklist`, {
      method: 'POST',
      baseURL: config.public.apiBase,
      headers: {
        Accept: 'application/json',
         'Content-Type': 'application/json',
        ...(token ? { Authorization: `Bearer ${token}` } : {})
      },
       body: JSON.stringify({
        nationalIdNumber: blacklistForm.nationalIdNumber,
        reason: blacklistForm.reason || undefined,
        expiresAt: blacklistForm.expiresAt || undefined
      })
    })

    toast.success('สำเร็จ', 'เพิ่ม Blacklist เรียบร้อย')

    blacklistForm.nationalIdNumber = ''
    blacklistForm.reason = ''
    blacklistForm.expiresAt = ''

    await fetchBlacklistUser()

  } catch (err) {
    console.error(err)
    toast.error(
      'เกิดข้อผิดพลาด',
      err?.data?.message || err?.message || 'ไม่สามารถเพิ่ม blacklist ได้'
    )
  } finally {
    isSubmitting.value = false
  }
}



/* ======================
   SIDEBAR
====================== */

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

    if (!sidebar || !mainContent) return

    sidebar.classList.toggle('collapsed')

    mainContent.style.marginLeft =
      sidebar.classList.contains('collapsed') ? '80px' : '280px'
  }

  window.toggleMobileSidebar = function () {
    const sidebar = document.getElementById('sidebar')
    const overlay = document.getElementById('overlay')

    if (!sidebar || !overlay) return

    sidebar.classList.toggle('mobile-open')
    overlay.classList.toggle('hidden')
  }

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
onMounted(() => {
  defineGlobalScripts()
  fetchBlacklistUser()
})

onUnmounted(() => {})

</script>

<style>
.main-content {
  transition: margin-left 0.3s ease;
}
</style>

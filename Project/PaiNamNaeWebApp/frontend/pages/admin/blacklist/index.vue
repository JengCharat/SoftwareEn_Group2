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

          <!-- National ID -->
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

          <!-- Reason -->
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

          <!-- Expire -->
          <div>
            <label class="block mb-1 text-sm font-medium text-gray-700">
              วันหมดอายุ *
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
              <th class="p-2 border">Action</th>
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

              <td class="p-2 border text-center">
                <button
                  @click="deleteBlacklist(item.id)"
                  class="px-3 py-1 text-white bg-red-500 rounded hover:bg-red-600"
                >
                  ลบ
                </button>
              </td>
            </tr>

            <tr v-if="blacklistAll.length === 0">
              <td colspan="7" class="p-4 text-center text-gray-400">
                ไม่มีข้อมูล
              </td>
            </tr>

          </tbody>

        </table>

      </div>

    </main>

    <div
      id="overlay"
      class="fixed inset-0 z-40 hidden bg-black bg-opacity-50 lg:hidden"
      @click="closeMobileSidebar"
    ></div>

  </div>
</template>

<script setup>
import { reactive, ref, onMounted } from 'vue'
import { useRuntimeConfig, useCookie } from '#app'
import AdminHeader from '~/components/admin/AdminHeader.vue'
import AdminSidebar from '~/components/admin/AdminSidebar.vue'
import { useToast } from '~/composables/useToast'

definePageMeta({ middleware: ['admin-auth'] })

const { toast } = useToast()

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
   FETCH
====================== */

async function fetchBlacklistUser() {
  isLoading.value = true

  try {
    const config = useRuntimeConfig()
    const token =
      useCookie('token').value ||
      localStorage.getItem('token')

    const res = await fetch(
      `${config.public.apiBase}/users/admin/blacklistUserlist`,
      {
        headers: {
          Accept: 'application/json',
          Authorization: `Bearer ${token}`
        }
      }
    )

    const body = await res.json()

    if (!res.ok) throw new Error(body.message)

    blacklistAll.value = body.data || []

  } catch (err) {
    loadError.value = err.message
    toast.error('Error', err.message)
  } finally {
    isLoading.value = false
  }
}


/* ======================
   ADD
====================== */

async function submitBlacklist() {

  if (!blacklistForm.nationalIdNumber || !blacklistForm.expiresAt) {
    toast.error('กรอกข้อมูลไม่ครบ', 'กรุณากรอก National ID และ Expire Date')
    return
  }

  isSubmitting.value = true

  try {
    const config = useRuntimeConfig()
    const token =
      useCookie('token').value ||
      localStorage.getItem('token')

    const res = await fetch(`${config.public.apiBase}/users/blacklist`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${token}`
      },
      body: JSON.stringify(blacklistForm)
    })

    const body = await res.json()

    if (!res.ok) throw new Error(body.message)

    toast.success('สำเร็จ', 'เพิ่ม Blacklist เรียบร้อย')

    blacklistForm.nationalIdNumber = ''
    blacklistForm.reason = ''
    blacklistForm.expiresAt = ''

    fetchBlacklistUser()

  } catch (err) {
    toast.error('Error', err.message)
  } finally {
    isSubmitting.value = false
  }
}


/* ======================
   DELETE
====================== */

async function deleteBlacklist(id) {

  if (!confirm('ต้องการลบ blacklist นี้ใช่หรือไม่ ?')) return

  try {
    const config = useRuntimeConfig()

    const token =
      useCookie('token').value ||
      localStorage.getItem('token')

    const res = await fetch(
      `${config.public.apiBase}/blacklist/${id}`,   
      {
        method: 'DELETE',
        headers: {
          Accept: 'application/json',
          Authorization: `Bearer ${token}`
        }
      }
    )

    const body = await res.json()

    if (!res.ok) throw new Error(body.message)

    toast.success('สำเร็จ', 'ลบเรียบร้อย')

    fetchBlacklistUser()

  } catch (err) {
    console.error(err)
    toast.error('Error', err.message)
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

useHead({
    title: 'TailAdmin Dashboard',
    link: [{ rel: 'stylesheet', href: 'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css' }]
})
onMounted(() => {
  fetchBlacklistUser()
})
</script>

<style>
.main-content {
  transition: margin-left 0.3s ease;
}
</style>

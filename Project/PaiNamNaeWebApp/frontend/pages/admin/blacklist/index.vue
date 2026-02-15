<template>
    <div>
        <AdminHeader />
        <AdminSidebar />

        <main id="main-content" class="main-content mt-16 ml-0 lg:ml-[280px] p-6">

            <h1 class="mb-6 text-2xl font-bold">Blacklist Management</h1>

            <!-- Add Blacklist Card -->
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
                            วันหมดอายุ (ถ้ามี)
                        </label>
                        <input
                            v-model="blacklistForm.expiresAt"
                            type="date"
                            class="w-full px-3 py-2 border rounded-md"
                        />
                    </div>

                </div>

                <!-- Button -->
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
   FORM STATE
====================== */

const blacklistForm = reactive({
    nationalIdNumber: '',
    reason: '',
    expiresAt: ''
})

const isSubmitting = ref(false)

/* ======================
   SUBMIT FUNCTION
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

        await $fetch('/users/blacklist', {
            method: 'POST',
            baseURL: config.public.apiBase,
            headers: {
                Accept: 'application/json',
                ...(token ? { Authorization: `Bearer ${token}` } : {})
            },
            body: {
                nationalIdNumber: blacklistForm.nationalIdNumber,
                reason: blacklistForm.reason || undefined,
                expiresAt: blacklistForm.expiresAt || undefined
            }
        })

        toast.success('สำเร็จ', 'เพิ่ม Blacklist เรียบร้อย')

        // reset form
        blacklistForm.nationalIdNumber = ''
        blacklistForm.reason = ''
        blacklistForm.expiresAt = ''

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
   SIDEBAR SCRIPT
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

function cleanupGlobalScripts() {
    window.removeEventListener(
        'resize',
        window.__adminResizeHandler__ || (() => {})
    )
}

onMounted(() => {
    defineGlobalScripts()
    if (typeof window.__adminResizeHandler__ === 'function') {
        window.__adminResizeHandler__()
    }
})

onUnmounted(() => {
    cleanupGlobalScripts()
})
useHead({
  title: 'TailAdmin Dashboard',
  link: [
    { 
      rel: 'stylesheet', 
      href: 'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css' 
    }
  ]
})
</script>

<style>
.main-content {
    transition: margin-left 0.3s ease;
}

@media (max-width: 768px) {
    .main-content {
        margin-left: 0 !important;
    }
}
</style>

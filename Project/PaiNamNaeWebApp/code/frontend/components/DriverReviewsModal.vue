<template>
    <div v-if="show" class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 px-4"
        @click.self="$emit('close')">
        <div class="w-full max-w-lg bg-white rounded-2xl shadow-2xl overflow-hidden flex flex-col"
            style="max-height: 85vh;">
            <!-- Header -->
            <div class="bg-gradient-to-r from-blue-500 to-blue-700 px-6 py-4 flex items-center justify-between flex-shrink-0">
                <div class="flex items-center gap-3">
                    <img :src="driverImage || fallbackAvatar(driverName)"
                        :alt="driverName"
                        class="w-10 h-10 rounded-full object-cover border-2 border-white/40" />
                    <div>
                        <h2 class="text-base font-bold text-white">{{ driverName }}</h2>
                        <p class="text-xs text-blue-100">รีวิวจากผู้โดยสาร</p>
                    </div>
                </div>
                <button @click="$emit('close')"
                    class="text-white/80 hover:text-white text-2xl leading-none w-8 h-8 flex items-center justify-center rounded-full hover:bg-black/10 transition-colors"
                    aria-label="ปิด">
                    ×
                </button>
            </div>

            <!-- Summary Bar -->
            <div v-if="!isLoading && reviewData" class="px-6 py-3 bg-blue-50 border-b border-blue-100 flex items-center gap-4 flex-shrink-0">
                <div class="text-center min-w-[56px]">
                    <div class="text-2xl font-bold text-blue-700">
                        {{ avgRating != null ? avgRating.toFixed(1) : '–' }}
                    </div>
                    <div class="flex justify-center text-yellow-400 text-sm leading-none mt-0.5">
                        <span v-for="i in 5" :key="i">
                            {{ i <= Math.round(avgRating ?? 0) ? '★' : '☆' }}
                        </span>
                    </div>
                </div>
                <div class="text-sm text-gray-600">
                    จาก <span class="font-semibold text-gray-800">{{ totalReviews }}</span> รีวิว
                </div>
            </div>

            <!-- Content -->
            <div class="overflow-y-auto flex-1 p-5 space-y-4">
                <!-- Loading -->
                <div v-if="isLoading" class="flex flex-col items-center justify-center py-12 text-gray-400">
                    <svg class="animate-spin h-8 w-8 text-blue-400 mb-3" xmlns="http://www.w3.org/2000/svg" fill="none"
                        viewBox="0 0 24 24">
                        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" />
                        <path class="opacity-75" fill="currentColor"
                            d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
                    </svg>
                    <span class="text-sm">กำลังโหลดรีวิว...</span>
                </div>

                <!-- Error -->
                <div v-else-if="error" class="flex flex-col items-center justify-center py-12 text-red-400">
                    <span class="text-4xl mb-2">⚠️</span>
                    <p class="text-sm text-center">{{ error }}</p>
                </div>

                <!-- Empty -->
                <div v-else-if="reviewData && !reviews.length"
                    class="flex flex-col items-center justify-center py-12 text-gray-400">
                    <span class="text-4xl mb-2">💬</span>
                    <p class="text-sm">ยังไม่มีรีวิวสำหรับคนขับคนนี้</p>
                </div>

                <!-- Review List -->
                <template v-else-if="reviewData">
                    <div v-for="r in reviews" :key="r.id"
                        class="flex gap-3 pb-4 border-b border-gray-100 last:border-0 last:pb-0">
                        <img :src="r.passenger?.profilePicture || fallbackAvatar(passengerName(r.passenger))"
                            :alt="passengerName(r.passenger)"
                            class="w-9 h-9 rounded-full object-cover flex-shrink-0 mt-0.5" />
                        <div class="flex-1 min-w-0">
                            <div class="flex items-center justify-between gap-2">
                                <p class="text-sm font-semibold text-gray-800 truncate">
                                    {{ passengerName(r.passenger) }}
                                </p>
                                <span class="text-xs text-gray-400 flex-shrink-0">{{ formatDate(r.createdAt) }}</span>
                            </div>
                            <div class="text-yellow-400 text-sm leading-none my-1">
                                <span v-for="i in 5" :key="i">{{ i <= r.rating ? '★' : '☆' }}</span>
                                <span class="text-gray-500 text-xs ml-1">{{ r.rating }}/5</span>
                            </div>
                            <p v-if="r.comment" class="text-sm text-gray-600 break-words">{{ r.comment }}</p>
                            <p v-else class="text-xs text-gray-400 italic">ไม่มีความคิดเห็น</p>
                        </div>
                    </div>
                </template>
            </div>

            <!-- Footer close -->
            <div class="px-5 py-4 border-t bg-gray-50 flex-shrink-0">
                <button @click="$emit('close')"
                    class="w-full px-4 py-2.5 text-sm font-medium text-gray-600 bg-white border border-gray-300 rounded-xl hover:bg-gray-100 transition-colors">
                    ปิด
                </button>
            </div>
        </div>
    </div>
</template>

<script setup>
const props = defineProps({
    show: { type: Boolean, default: false },
    driverId: { type: String, default: null },
    driverName: { type: String, default: 'คนขับ' },
    driverImage: { type: String, default: null },
})
defineEmits(['close'])

const { $api } = useNuxtApp()

const isLoading = ref(false)
const error = ref(null)
const reviewData = ref(null)

// computed helpers — safe regardless of what shape the API returns
const reviews = computed(() => reviewData.value?.data ?? (Array.isArray(reviewData.value) ? reviewData.value : []))
const avgRating = computed(() => reviewData.value?.avgRating ?? null)
const totalReviews = computed(() => reviewData.value?.totalReviews ?? reviews.value.length)

watch(() => props.show, async (val) => {
    if (val && props.driverId) {
        await fetchReviews()
    } else if (!val) {
        reviewData.value = null
        error.value = null
    }
})

const fetchReviews = async () => {
    isLoading.value = true
    error.value = null
    try {
        const res = await $api(`/reviews/driver/${props.driverId}`)
        // $api onResponse already unwraps { success, data } → res is { data: [...], avgRating, totalReviews, pagination }
        reviewData.value = res
    } catch (err) {
        error.value = err?.data?.message || err?.message || 'ไม่สามารถโหลดรีวิวได้'
    } finally {
        isLoading.value = false
    }
}

const passengerName = (p) =>
    p ? `${p.firstName || ''} ${p.lastName || ''}`.trim() || 'ผู้ใช้' : 'ผู้ใช้'

const fallbackAvatar = (name) =>
    `https://ui-avatars.com/api/?name=${encodeURIComponent(name || 'U')}&background=random&size=64`

const formatDate = (iso) => {
    if (!iso) return ''
    const d = new Date(iso)
    return d.toLocaleDateString('th-TH', { day: 'numeric', month: 'short', year: 'numeric' })
}
</script>

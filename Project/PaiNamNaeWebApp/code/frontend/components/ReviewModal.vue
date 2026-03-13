<template>
    <div v-if="show" class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 px-4"
        @click.self="$emit('close')">
        <div class="w-full max-w-md bg-white rounded-2xl shadow-2xl overflow-hidden">
            <!-- Header -->
            <div class="bg-gradient-to-r from-yellow-400 to-orange-400 px-6 py-4">
                <h2 class="text-lg font-bold text-white">⭐ ให้คะแนนการเดินทาง</h2>
                <p class="text-sm text-yellow-50 mt-0.5 truncate">
                    {{ trip?.origin }} → {{ trip?.destination }}
                </p>
            </div>

            <!-- Body -->
            <div class="p-6 space-y-5">
                <!-- Driver Info -->
                <div class="flex items-center gap-3">
                    <img :src="trip?.driver?.image" :alt="trip?.driver?.name"
                        class="w-12 h-12 rounded-full object-cover border-2 border-gray-100" />
                    <div>
                        <p class="font-semibold text-gray-800">{{ trip?.driver?.name }}</p>
                        <p class="text-xs text-gray-500">คนขับ</p>
                    </div>
                </div>

                <!-- Star Rating -->
                <div>
                    <p class="text-sm font-medium text-gray-700 mb-2">คะแนนความพึงพอใจ <span
                            class="text-red-500">*</span></p>
                    <div class="flex gap-2">
                        <button v-for="star in 5" :key="star" type="button" @click="rating = star"
                            @mouseenter="hoverRating = star" @mouseleave="hoverRating = 0"
                            class="text-3xl transition-transform hover:scale-110 focus:outline-none"
                            :aria-label="`${star} ดาว`">
                            <span :class="(hoverRating || rating) >= star ? 'text-yellow-400' : 'text-gray-300'">
                                ★
                            </span>
                        </button>
                    </div>
                    <p class="mt-1 text-xs text-gray-500 h-4">{{ ratingLabel }}</p>
                    <p v-if="ratingError" class="mt-1 text-xs text-red-500">{{ ratingError }}</p>
                </div>

                <!-- Comment -->
                <div>
                    <label class="text-sm font-medium text-gray-700">ความคิดเห็น
                        <span class="text-gray-400 font-normal">(ไม่บังคับ)</span>
                    </label>
                    <textarea v-model="comment" rows="3" maxlength="500"
                        placeholder="บอกเล่าประสบการณ์การเดินทางของคุณ..."
                        class="mt-1 w-full px-3 py-2 border border-gray-300 rounded-lg text-sm resize-none focus:outline-none focus:ring-2 focus:ring-yellow-400 focus:border-transparent" />
                    <p class="text-right text-xs text-gray-400 mt-0.5">{{ comment.length }}/500</p>
                </div>
            </div>

            <!-- Footer -->
            <div class="px-6 pb-6 flex gap-3">
                <button type="button" @click="$emit('close')"
                    class="flex-1 px-4 py-2.5 text-sm font-medium text-gray-600 bg-gray-100 rounded-xl hover:bg-gray-200 transition-colors">
                    ยกเลิก
                </button>
                <button type="button" @click="submitReview" :disabled="isSubmitting || rating === 0"
                    class="flex-1 px-4 py-2.5 text-sm font-medium text-white bg-gradient-to-r from-yellow-400 to-orange-400 rounded-xl hover:from-yellow-500 hover:to-orange-500 disabled:opacity-50 disabled:cursor-not-allowed transition-all">
                    {{ isSubmitting ? 'กำลังส่ง...' : 'ส่งรีวิว' }}
                </button>
            </div>
        </div>
    </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue'

const props = defineProps({
    show: { type: Boolean, default: false },
    trip: { type: Object, default: null },
})
const emit = defineEmits(['close', 'submitted'])

const { $api } = useNuxtApp()

const rating = ref(0)
const hoverRating = ref(0)
const comment = ref('')
const isSubmitting = ref(false)
const ratingError = ref('')

const ratingLabels = ['', 'แย่มาก', 'พอใช้', 'ปานกลาง', 'ดี', 'ดีมาก']
const ratingLabel = computed(() => ratingLabels[hoverRating.value || rating.value] || '')

// Reset state when modal opens
watch(() => props.show, (val) => {
    if (val) {
        rating.value = 0
        hoverRating.value = 0
        comment.value = ''
        ratingError.value = ''
    }
})

async function submitReview() {
    if (rating.value === 0) {
        ratingError.value = 'กรุณาเลือกคะแนน'
        return
    }
    ratingError.value = ''
    isSubmitting.value = true
    try {
        await $api('/reviews', {
            method: 'POST',
            body: {
                bookingId: props.trip.id,
                rating: rating.value,
                comment: comment.value.trim() || undefined,
            },
        })
        emit('submitted', { bookingId: props.trip.id, rating: rating.value, comment: comment.value })
        emit('close')
    } catch (err) {
        ratingError.value = err?.data?.message || 'ไม่สามารถส่งรีวิวได้'
    } finally {
        isSubmitting.value = false
    }
}
</script>

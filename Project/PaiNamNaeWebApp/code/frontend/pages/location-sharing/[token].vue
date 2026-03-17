<!-- Static build fallback: redirects /location-sharing/:token → /location-sharing?token= -->
<template>
  <div class="min-h-screen bg-gray-50 flex items-center justify-center">
    <p class="text-gray-500">กำลังเปลี่ยนเส้นทาง...</p>
  </div>
</template>

<script setup>
definePageMeta({ layout: false })
const route = useRoute()
const router = useRouter()
onMounted(() => {
  const token = route.params.token
  if (token) router.replace({ path: '/location-sharing', query: { token } })
})
</script>

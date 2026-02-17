<<<<<<< HEAD
<script setup>
    const contacts = [
    {name: "ตำรวจ (191)", phone:"191"},
    {name: "รถพยาบาล (1669)", phone:"1669"},
    {name: "สายด่วนจราจร (1197)", phone:"1197"},
    {name: "Noaa", phone: "0894228587"}
    ];

    const selected = ref(null); // เก็บเบอร์ที่เลือก

    //โทรออก
    const makeCall = () => {
    if (selected.value) {
        window.location.href = `tel:${selected.value.phone}`;
    }
    };
</script>

=======
>>>>>>> 1d331f1e884295cdf56f46b6a506c2fea8932d15
<template>
  <div class="p-6 max-w-4xl mx-auto">
    <h1 class="text-2xl font-bold text-red-600 mb-6 underline">SOS EMERGENCY</h1>

    <div class="grid grid-cols-1 md:grid-cols-2 gap-6 md:gap-10">
      <div class="flex flex-col items-center gap-6">

        <!-- Loading State -->
        <div v-if="isLoading" class="w-full p-3 text-center text-gray-400 border-2 border-gray-200 rounded">
          กำลังโหลด...
        </div>

        <!-- Dropdown -->
        <select v-else v-model="selected" class="w-full p-3 border-2 border-gray-400 rounded">
          <option :value="null">เลือกเบอร์ฉุกเฉิน</option>

          <!-- Hardcoded national emergency numbers -->
          <optgroup label="เบอร์ฉุกเฉินทั่วไป">
            <option v-for="c in defaultContacts" :key="c.phone" :value="c">
              {{ c.name }}
            </option>
          </optgroup>

          <!-- User's personal contacts from the database -->
          <optgroup v-if="personalContacts.length > 0" label="รายชื่อส่วนตัวของฉัน">
            <option v-for="c in personalContacts" :key="c.id" :value="c">
              {{ c.name }} ({{ c.phone }})
            </option>
          </optgroup>
        </select>

        <!-- Selected number display -->
        <div v-if="selected"
          class="text-4xl font-mono font-bold text-red-600 border p-4 w-full max-w-[300px] text-center bg-gray-50">
          {{ selected.phone }}
        </div>

        <!-- Call Button -->
        <NuxtLink
          v-if="selected"
          :to="'tel:' + selected.phone"
          class="w-32 h-32 bg-red-600 rounded-full text-white font-bold text-xl shadow-lg flex items-center justify-center active:bg-red-800 no-underline">
          CALL
        </NuxtLink>

        <!-- Hint to add personal contacts -->
        <p v-if="!isLoading && personalContacts.length === 0" class="text-sm text-gray-400 text-center">
          คุณยังไม่มีรายชื่อส่วนตัว
          <NuxtLink to="/profile/manage_contacts" class="text-blue-500 underline">
            เพิ่มได้ที่นี่
          </NuxtLink>
        </p>

      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const { $api } = useNuxtApp()

//เบอร์โทรฉุกเฉินเริ่มต้น
const defaultContacts = [
  { name: 'ตำรวจ (191)',         phone: '191' },
  { name: 'รถพยาบาล (1669)',     phone: '1669' },
  { name: 'สายด่วนจราจร (1197)', phone: '1197' },
]

const personalContacts = ref([])
const selected = ref(null)
const isLoading = ref(false)

//ดึงข้อมูลจาก Emergency Contacts ที่บันทึกไว้
const fetchPersonalContacts = async () => {
  isLoading.value = true
  try {
    const res = await $api('/emergency-contacts')
    personalContacts.value = res
  } catch (err) {
    // Non-critical — the page still works with just the default numbers
    console.error('fetchPersonalContacts error:', err)
  } finally {
    isLoading.value = false
  }
}

onMounted(fetchPersonalContacts)
</script>

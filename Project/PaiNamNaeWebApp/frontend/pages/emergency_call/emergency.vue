<script setup>
    const contacts = [
    {name: "ตำรวจ (191)", phone:"191"},
    {name: "รถพยาบาล (1669)", phone:"1669"},
    {name: "สายด่วนจราจร (1197)", phone:"1197"}
    ];

    const selected = ref(null); // เก็บเบอร์ที่เลือก

    //โทรออก
    const makeCall = () => {
    if (selected.value) {
        window.location.href = `tel:${selected.value.phone}`;
    }
    };
</script>

<template>
  <div class="p-6 max-w-4xl mx-auto">
    <h1 class="text-2xl font-bold text-red-600 mb-6 underline">SOS EMERGENCY</h1>
    
    <div class="grid grid-cols-2 gap-10">
      <div class="flex flex-col items-center gap-6">
        <select v-model="selected" class="w-full p-3 border-2 border-gray-400 rounded">
          <option :value="null">เลือกเบอร์ฉุกเฉิน</option>
          <option v-for="c in contacts" :key="c.phone" :value="c">{{ c.name }}</option>
        </select>

        <div v-if="selected" class="text-4xl font-mono font-bold text-red-600 border p-4 w-full text-center bg-gray-50">
          {{ selected.phone }}
        </div>

     <NuxtLink 
        v-if="selected"
        :to="'tel:' + selected.phone"
        class="w-32 h-32 bg-red-600 rounded-full text-white font-bold text-xl shadow-lg flex items-center justify-center active:bg-red-800 no-underline">
        CALL
     </NuxtLink>
      </div>
    </div>
  </div>
</template>
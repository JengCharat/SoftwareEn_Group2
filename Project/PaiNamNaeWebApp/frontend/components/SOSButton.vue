<template>
  <div class="flex items-center px-2">
    <NuxtLink to="/emergency_call/emergency" class="group relative flex items-center">
      <button
        class="flex h-9 w-9 items-center justify-center rounded-full bg-red-600 shadow-md transition-all duration-300 group-hover:bg-red-700 group-hover:scale-105 active:scale-95"
      >
        <span class="text-[10px] font-black italic text-white tracking-tighter">SOS</span>
      </button>

      <span class="absolute -bottom-8 left-1/2 -translate-x-1/2 scale-0 rounded bg-gray-800 px-2 py-1 text-[10px] text-white transition-all group-hover:scale-100 whitespace-nowrap z-50">
        ขอความช่วยเหลือฉุกเฉิน
      </span>
    </NuxtLink>
  </div>
</template>
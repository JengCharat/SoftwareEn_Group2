<template>
    <div>
        <div class="flex items-center justify-center py-8">
            <div class="flex bg-white rounded-lg shadow-lg overflow-hidden max-w-6xl w-full mx-4 border border-gray-300">

                <ProfileSidebar />

                <main class="flex-1 p-8">
                    
                    <div class="text-center mb-8">
                        <div class="inline-flex items-center justify-center w-16 h-16 bg-blue-600 rounded-full mb-4">
                            <svg class="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                    d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z">
                                </path>
                            </svg>
                        </div>
                        <h1 class="text-3xl font-bold text-gray-800 mb-2">จัดการเบอร์ติดต่อฉุกเฉิน</h1>
                        <p class="text-gray-600 max-w-md mx-auto">
                            เพิ่มรายชื่อผู้ติดต่อหรือเบอร์ฉุกเฉินส่วนตัวของคุณ
                        </p>
                    </div>

                    <div class="bg-gray-50 p-6 rounded-lg border border-gray-200 mb-8">
                        <label class="block text-sm font-medium text-gray-700 mb-2">เพิ่มรายชื่อใหม่</label>
                        <div class="flex flex-col md:flex-row gap-4">
                            <input v-model="newName" type="text" placeholder="ชื่อเรียก (เช่น พ่อ, กู้ภัยตำบล)"
                                class="flex-1 p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none transition" />
                            <input v-model="newPhone" type="tel" placeholder="เบอร์โทรศัพท์"
                                class="flex-1 p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none transition"
                                @keyup.enter="addContact" />
                            <button @click="addContact"
                                class="bg-[#2563EB] hover:bg-blue-700 text-white text-sm md:text-[16px] px-4 py-2 rounded-lg transition-colors whitespace-nowrap">
                                เพิ่ม
                            </button>
                        </div>
                    </div>

                    <div class="space-y-4">
                        <div class="flex justify-between items-end border-b pb-2">
                            <h2 class="text-xl font-semibold text-gray-800">รายชื่อทั้งหมด</h2>
                            <span class="text-sm text-gray-500">จำนวน {{ contacts.length }} รายชื่อ</span>
                        </div>

                        <div v-if="contacts.length === 0"
                            class="text-center py-10 text-gray-400 bg-gray-50 rounded-lg border-dashed border-2 border-gray-200">
                            ยังไม่มีรายชื่อผู้ติดต่อ
                        </div>

                        <transition-group name="list" tag="ul" class="space-y-3">
                            <li v-for="contact in contacts" :key="contact.id"
                                class="flex justify-between items-center p-4 bg-white border border-gray-100 rounded-lg shadow-sm hover:shadow-md transition-shadow">
                                <div class="flex items-center gap-4">
                                    <div
                                        class="w-10 h-10 bg-blue-100 rounded-full flex items-center justify-center text-blue-600 font-bold">
                                        {{ contact.name.charAt(0) }}
                                    </div>
                                    <div>
                                        <p class="font-bold text-gray-800">{{ contact.name }}</p>
                                        <p class="text-gray-500 text-sm font-mono">{{ contact.phone }}</p>
                                    </div>
                                </div>

                                <div class="flex items-center gap-3">
                                    <button @click="removeContact(contact.id)"
                                        class="bg-red-300 p-2 rounded-full transition-all duration-200 hover:bg-red-400" 
                                        title="ลบ">
                                        <div class="step-indicator">ลบ</div>
                                    </button>
                                </div>
                            </li>
                        </transition-group>
                    </div>

                </main>
            </div>
        </div>
    </div>
</template>


<script setup>
import { ref } from 'vue'


// 1. จำลองข้อมูล (Mock Data)
const contacts = ref([
    { id: 1, name: "แอดมิน (Admin)", phone: "02-999-9999" },
    { id: 2, name: "หัวหน้าหมู่บ้าน", phone: "081-234-5678" }
]);

const newName = ref('');
const newPhone = ref('');

// 2. ฟังก์ชันเพิ่ม
const addContact = () => {
    if (!newName.value || !newPhone.value) {
        alert('กรุณากรอกชื่อและเบอร์โทร');
        return;
    }
    const fakeId = Date.now();
    contacts.value.push({
        id: fakeId,
        name: newName.value,
        phone: newPhone.value
    });
    newName.value = '';
    newPhone.value = '';
};

// 3. ฟังก์ชันลบ
const removeContact = (id) => {
    if (confirm('ยืนยันการลบ?')) {
        contacts.value = contacts.value.filter(c => c.id !== id);
    }
};
</script>

<style scoped>
/* Animation สำหรับ List */
.list-enter-active,
.list-leave-active {
    transition: all 0.5s ease;
}

.list-enter-from,
.list-leave-to {
    opacity: 0;
    transform: translateX(30px);
}
</style>
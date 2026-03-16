<template>
    <div class="text-gray-900 bg-gray-50">
        <!-- HERO -->
        <section class="relative overflow-hidden">
            <div class="absolute inset-0 bg-gradient-to-b from-blue-50 to-transparent"></div>
            <div class="relative px-4 pt-10 pb-16 mx-auto max-w-7xl sm:px-6 lg:px-8 lg:pt-16 lg:pb-24">


                <div class="grid items-center grid-cols-1 gap-8 lg:grid-cols-2 lg:gap-12">
                    <div>
                        <h1 class="text-3xl font-extrabold tracking-tight text-gray-900 sm:text-4xl lg:text-5xl">
                            เดินทางร่วมกัน <span class="text-blue-600">อย่างมั่นใจ</span> ด้วยความปลอดภัยเป็นอันดับหนึ่ง
                        </h1>
                        <p class="mt-4 text-base text-gray-600 sm:text-lg">
                            จับคู่ผู้โดยสารและผู้ขับอย่างฉลาดด้วยเส้นทางที่เหมาะสม ตรวจสอบตัวตนด้วย OTP มีปุ่ม <span
                                class="font-semibold">SOS</span> ส่งพิกัดฉุกเฉิน
                            พร้อมระบบรีวิวและติดตามแบบเรียลไทม์
                        </p>
                        <div class="flex flex-col gap-3 mt-6 sm:flex-row">
                            <NuxtLink to="/findTrip"
                                class="inline-flex items-center justify-center px-6 py-3 text-white bg-blue-600 rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2">
                                ค้นหาเส้นทาง
                            </NuxtLink>
                            <NuxtLink to="/register"
                                class="inline-flex items-center justify-center px-6 py-3 text-blue-600 bg-white border border-blue-200 rounded-md hover:bg-blue-50 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2">
                                สมัครสมาชิก
                            </NuxtLink>
                        </div>

                        <!-- Trust badges / stats -->
                        <div class="grid grid-cols-2 gap-4 mt-8 sm:grid-cols-3">
                            <div class="p-4 bg-white border border-gray-200 rounded-lg card">
                                <p class="text-2xl font-bold text-blue-600">4.8★</p>
                                <p class="text-sm text-gray-600">คะแนนความพึงพอใจ</p>
                            </div>
                            <div class="p-4 bg-white border border-gray-200 rounded-lg card">
                                <p class="text-2xl font-bold text-blue-600">+10K</p>
                                <p class="text-sm text-gray-600">ผู้ใช้ที่ไว้ใจ</p>
                            </div>
                            <div class="p-4 bg-white border border-gray-200 rounded-lg card">
                                <p class="text-2xl font-bold text-blue-600">24/7</p>
                                <p class="text-sm text-gray-600">ติดตามแบบเรียลไทม์</p>
                            </div>
                        </div>
                    </div>

                    <div class="relative">
                        <div class="p-2 bg-white border border-gray-200 shadow-md rounded-xl card">
                            <img class="object-cover w-full rounded-lg h-80" alt="Carpool preview"
                                src="https://transportation.ucsd.edu/_images/headers/carpool-header.jpg" />
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- QUICK ACTIONS (Anchor targets for buttons) -->
        <section id="action-find" class="relative z-10 px-4 mx-auto -mt-10 max-w-7xl sm:px-6 lg:px-8 lg:-mt-16">
            <div class="p-6 bg-white border border-gray-200 shadow-md rounded-xl">
                <h2 class="mb-4 text-xl font-semibold">เริ่มต้นอย่างรวดเร็ว</h2>
                <div class="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-5">
                    <input type="text" placeholder="จุดเริ่มต้น"
                        class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent" />
                    <input type="text" placeholder="จุดปลายทาง"
                        class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent" />
                    <input type="date"
                        class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent" />
                    <select
                        class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent">
                        <option>1 ที่นั่ง</option>
                        <option>2 ที่นั่ง</option>
                        <option>3 ที่นั่ง</option>
                        <option>4 ที่นั่ง</option>
                    </select>
                    <NuxtLink to="/findTrip"
                        class="w-full px-4 py-2 text-white transition bg-blue-600 rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2">ค้นหา</NuxtLink>
                </div>
            </div>
        </section>

        <!-- FEATURES -->
        <section id="features" class="px-4 py-12 mx-auto max-w-7xl sm:px-6 lg:px-8 lg:py-16">
            <div class="mb-10 text-center">
                <h2 class="text-2xl font-extrabold sm:text-3xl">ฟีเจอร์เด่นเพื่อความปลอดภัย</h2>
                <p class="mt-2 text-gray-600">ออกแบบโดยคำนึงถึงความน่าเชื่อถือและประสบการณ์ผู้ใช้</p>
            </div>

            <div class="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
                <!-- Feature card -->
                <div class="p-6 bg-white border border-gray-200 rounded-lg card">
                    <div class="flex items-center justify-center w-10 h-10 mb-3 text-blue-600 bg-blue-100 rounded-lg">🔐
                    </div>
                    <h3 class="mb-1 font-semibold">ยืนยันตัวตนด้วย OTP</h3>
                    <p class="text-sm text-gray-600">ตรวจสอบเบอร์โทรศัพท์ก่อนใช้งาน ป้องกันบัญชีปลอม
                        เพิ่มความไว้ใจทั้งสองฝ่าย</p>
                </div>
                <div class="p-6 bg-white border border-gray-200 rounded-lg card">
                    <div class="flex items-center justify-center w-10 h-10 mb-3 text-blue-600 bg-blue-100 rounded-lg">🧭
                    </div>
                    <h3 class="mb-1 font-semibold">แมตช์เส้นทางอัจฉริยะ</h3>
                    <p class="text-sm text-gray-600">ใช้แผนที่และเส้นทางเพื่อจับคู่ผู้โดยสารกับผู้ขับที่เหมาะสมที่สุด
                    </p>
                </div>
                <div class="p-6 bg-white border border-gray-200 rounded-lg card">
                    <div class="flex items-center justify-center w-10 h-10 mb-3 text-blue-600 bg-blue-100 rounded-lg">📡
                    </div>
                    <h3 class="mb-1 font-semibold">ติดตามแบบเรียลไทม์</h3>
                    <p class="text-sm text-gray-600">ติดตามความคืบหน้าการเดินทางด้วยจุดตรวจ (checkpoint)
                        และการอัปเดตตำแหน่ง
                    </p>
                </div>
                <div class="p-6 bg-white border border-gray-200 rounded-lg card">
                    <div class="flex items-center justify-center w-10 h-10 mb-3 text-blue-600 bg-blue-100 rounded-lg">🆘
                    </div>
                    <h3 class="mb-1 font-semibold">ปุ่ม SOS ส่งพิกัดฉุกเฉิน</h3>
                    <p class="text-sm text-gray-600">ช่วยแจ้งผู้ติดต่อฉุกเฉินหรือเจ้าหน้าที่
                        พร้อมพิกัดทันทีเมื่อเกิดเหตุไม่คาดคิด</p>
                </div>
                <div class="p-6 bg-white border border-gray-200 rounded-lg card">
                    <div class="flex items-center justify-center w-10 h-10 mb-3 text-blue-600 bg-blue-100 rounded-lg">⭐
                    </div>
                    <h3 class="mb-1 font-semibold">รีวิวและเรตติ้ง</h3>
                    <p class="text-sm text-gray-600">โปร่งใสด้วยคะแนนจากผู้ใช้จริง ช่วยตัดสินใจก่อนร่วมเดินทาง</p>
                </div>
                <div class="p-6 bg-white border border-gray-200 rounded-lg card">
                    <div class="flex items-center justify-center w-10 h-10 mb-3 text-blue-600 bg-blue-100 rounded-lg">💬
                    </div>
                    <h3 class="mb-1 font-semibold">แชทเรียลไทม์</h3>
                    <p class="text-sm text-gray-600">สื่อสารก่อนออกเดินทางเพื่อยืนยันรายละเอียดและข้อตกลง</p>
                </div>
            </div>
        </section>

        <!-- HOW IT WORKS -->
        <section id="how" class="px-4 pb-12 mx-auto max-w-7xl sm:px-6 lg:px-8 lg:pb-16">
            <div class="p-6 bg-white border border-gray-200 rounded-xl lg:p-8">
                <h2 class="mb-6 text-2xl font-extrabold">ใช้งานอย่างไร</h2>
                <div class="grid grid-cols-1 gap-6 lg:grid-cols-2">
                    <div class="p-5 border border-blue-100 rounded-lg bg-blue-50">
                        <h3 class="mb-3 font-semibold text-blue-700">สำหรับผู้โดยสาร</h3>
                        <ol class="space-y-2 text-sm text-gray-700">
                            <li>1) ค้นหาเส้นทางที่ต้องการและเลือกผู้ขับที่เชื่อถือได้</li>
                            <li>2) จองที่นั่งและยืนยันผ่าน OTP</li>
                            <li>3) ติดตามการเดินทางผ่านแผนที่แบบเรียลไทม์</li>
                        </ol>
                    </div>
                    <div class="p-5 border border-green-100 rounded-lg bg-green-50">
                        <h3 class="mb-3 font-semibold text-green-700">สำหรับผู้ขับ</h3>
                        <ol class="space-y-2 text-sm text-gray-700">
                            <li>1) เสนอเส้นทางและเวลาที่สะดวก</li>
                            <li>2) รับคำขอจองจากผู้โดยสารที่ยืนยันตัวตนแล้ว</li>
                            <li>3) ออกเดินทาง ปลอดภัยพร้อมรีวิวหลังจบการเดินทาง</li>
                        </ol>
                    </div>
                </div>
                <div class="flex flex-col gap-3 mt-6 sm:flex-row">
                    <a href="#action-find"
                        class="inline-flex items-center justify-center px-6 py-3 text-white bg-blue-600 rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2">เริ่มค้นหา</a>
                    <a id="action-offer" href="#"
                        class="inline-flex items-center justify-center px-6 py-3 text-blue-600 bg-white border border-blue-200 rounded-md hover:bg-blue-50 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2">เริ่มเสนอเส้นทาง</a>
                </div>
            </div>
        </section>

        <!-- SAFETY HIGHLIGHTS -->
        <section class="px-4 pb-12 mx-auto max-w-7xl sm:px-6 lg:px-8 lg:pb-16">
            <div class="grid grid-cols-1 gap-6 lg:grid-cols-3">
                <div class="p-6 bg-white border border-gray-200 rounded-xl card">
                    <h3 class="mb-2 font-semibold">ชั้นความปลอดภัยหลายระดับ</h3>
                    <p class="text-sm text-gray-600">ตั้งแต่ยืนยันตัวตน, การตรวจโปรไฟล์, รีวิวชุมชน
                        จนถึงการติดตามเส้นทางทุกขั้นตอน</p>
                </div>
                <div class="p-6 bg-white border border-gray-200 rounded-xl card">
                    <h3 class="mb-2 font-semibold">ความเป็นส่วนตัวมาก่อน</h3>
                    <p class="text-sm text-gray-600">ซ่อนข้อมูลสำคัญ แสดงเฉพาะสิ่งจำเป็นก่อนยืนยันการเดินทาง</p>
                </div>
                <div class="p-6 bg-white border border-gray-200 rounded-xl card">
                    <h3 class="mb-2 font-semibold">รองรับเหตุฉุกเฉิน</h3>
                    <p class="text-sm text-gray-600">ปุ่ม SOS แจ้งเตือนพร้อมพิกัดแบบทันที ช่วยเหลือได้รวดเร็ว</p>
                </div>
            </div>
        </section>

        <!-- TESTIMONIALS -->
        <section class="px-4 pb-12 mx-auto max-w-7xl sm:px-6 lg:px-8 lg:pb-16">
            <div class="mb-8 text-center">
                <h2 class="text-2xl font-extrabold sm:text-3xl">เสียงจากผู้ใช้</h2>
                <p class="mt-2 text-gray-600">ประสบการณ์จริงจากการเดินทางร่วมกัน</p>
            </div>
            <div class="grid grid-cols-1 gap-6 md:grid-cols-3">
                <div class="p-6 bg-white border border-gray-200 rounded-lg card">
                    <div class="flex items-center space-x-3">
                        <img class="object-cover w-10 h-10 rounded-full"
                            src="https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=60&h=60&fit=crop&crop=face"
                            alt="avatar" />
                        <div>
                            <p class="font-semibold">สมชาย ใจดี</p>
                            <p class="text-sm text-yellow-500">★★★★★</p>
                        </div>
                    </div>
                    <p class="mt-3 text-sm text-gray-600">ระบบชัดเจน ปลอดภัย อุ่นใจตลอดทริป</p>
                </div>
                <div class="p-6 bg-white border border-gray-200 rounded-lg card">
                    <div class="flex items-center space-x-3">
                        <img class="object-cover w-10 h-10 rounded-full"
                            src="https://images.unsplash.com/photo-1494790108755-2616b2dc0a48?w=60&h=60&fit=crop&crop=face"
                            alt="avatar" />
                        <div>
                            <p class="font-semibold">วรรณา สุขใจ</p>
                            <p class="text-sm text-yellow-500">★★★★☆</p>
                        </div>
                    </div>
                    <p class="mt-3 text-sm text-gray-600">จับคู่ไว เส้นทางสะดวก ประหยัดเวลา</p>
                </div>
                <div class="p-6 bg-white border border-gray-200 rounded-lg card">
                    <div class="flex items-center space-x-3">
                        <img class="object-cover w-10 h-10 rounded-full"
                            src="https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=60&h=60&fit=crop&crop=face"
                            alt="avatar" />
                        <div>
                            <p class="font-semibold">อนุชา รักเดินทาง</p>
                            <p class="text-sm text-yellow-500">★★★★★</p>
                        </div>
                    </div>
                    <p class="mt-3 text-sm text-gray-600">ผู้ขับและผู้โดยสารสุภาพมาก ๆ แนะนำเลย</p>
                </div>
            </div>
        </section>

        <!-- FAQ -->
        <section class="px-4 pb-12 mx-auto max-w-7xl sm:px-6 lg:px-8 lg:pb-16">
            <div class="bg-white border border-gray-200 divide-y divide-gray-200 rounded-xl">
                <div class="p-6">
                    <h2 class="text-2xl font-extrabold">คำถามที่พบบ่อย</h2>
                </div>

                <div class="p-6">
                    <button class="flex items-center justify-between w-full font-medium text-left"
                        @click="toggleFaq('f1')">
                        ต้องยืนยันตัวตนอย่างไร?
                        <svg class="w-4 h-4 ml-1 transition-transform duration-300"
                            :class="{ 'rotate-180': openFaqId === 'f1' }" fill="none" stroke="currentColor"
                            viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7">
                            </path>
                        </svg>
                    </button>
                    <div class="mt-3 text-sm text-gray-600 faq-content" :class="{ 'show': openFaqId === 'f1' }">
                        <p>ผู้ใช้ต้องยืนยันหมายเลขโทรศัพท์ด้วยรหัส OTP ก่อนใช้งานจองหรือเสนอเส้นทาง</p>
                    </div>
                </div>

                <div class="p-6">
                    <button class="flex items-center justify-between w-full font-medium text-left"
                        @click="toggleFaq('f2')">
                        ปลอดภัยระหว่างเดินทางอย่างไร?
                        <svg class="w-4 h-4 ml-1 transition-transform duration-300"
                            :class="{ 'rotate-180': openFaqId === 'f2' }" fill="none" stroke="currentColor"
                            viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7">
                            </path>
                        </svg>
                    </button>
                    <div class="mt-3 text-sm text-gray-600 faq-content" :class="{ 'show': openFaqId === 'f2' }">
                        <p>มีปุ่ม SOS ส่งพิกัดฉุกเฉิน, การติดตามแบบเรียลไทม์ และระบบรีวิวช่วยคัดกรอง</p>
                    </div>
                </div>

                <div class="p-6">
                    <button class="flex items-center justify-between w-full font-medium text-left"
                        @click="toggleFaq('f3')">
                        มีค่าธรรมเนียมหรือไม่?
                        <svg class="w-4 h-4 ml-1 transition-transform duration-300"
                            :class="{ 'rotate-180': openFaqId === 'f3' }" fill="none" stroke="currentColor"
                            viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7">
                            </path>
                        </svg>
                    </button>
                    <div class="mt-3 text-sm text-gray-600 faq-content" :class="{ 'show': openFaqId === 'f3' }">
                        <p>ไม่มีค่าใช้บริการพื้นฐาน อาจมีค่าธรรมเนียมบางส่วนขึ้นกับการชำระเงินในอนาคต</p>
                    </div>
                </div>
            </div>
        </section>

        <!-- FINAL CTA -->
        <section class="px-4 pb-16 mx-auto max-w-7xl sm:px-6 lg:px-8">
            <div
                class="flex flex-col items-start justify-between gap-6 p-8 text-white bg-blue-600 rounded-2xl lg:p-10 lg:flex-row lg:items-center">
                <div>
                    <h3 class="text-2xl font-bold">พร้อมออกเดินทางร่วมกันอย่างปลอดภัยแล้วหรือยัง?</h3>
                    <p class="mt-1 text-blue-100">เข้าร่วมชุมชนไปนำแหน่วันนี้</p>
                </div>
                <div class="flex w-full gap-3 sm:w-auto">
                    <a href="#action-find"
                        class="inline-flex items-center justify-center flex-1 px-6 py-3 text-blue-600 bg-white rounded-md sm:flex-none hover:bg-blue-50 focus:outline-none focus:ring-2 focus:ring-white focus:ring-offset-2 focus:ring-offset-blue-600">เริ่มค้นหาเส้นทาง</a>
                    <a href="#"
                        class="inline-flex items-center justify-center flex-1 px-6 py-3 text-white bg-blue-700 rounded-md sm:flex-none hover:bg-blue-800 focus:outline-none focus:ring-2 focus:ring-white focus:ring-offset-2 focus:ring-offset-blue-700">เริ่มเสนอเส้นทาง</a>
                </div>
            </div>
        </section>

        <!-- FOOTER -->
        <footer class="bg-white border-t border-gray-200">
            <div
                class="flex flex-col items-center justify-between gap-3 px-4 py-6 mx-auto text-sm text-gray-600 max-w-7xl sm:px-6 lg:px-8 sm:flex-row sm:items-center">
                <p>© <span id="y"></span> Pai Nam Nae. สงวนลิขสิทธิ์.</p>

            </div>
        </footer>

    </div>
</template>

<script setup>
import { ref } from 'vue';

// สร้าง State เพื่อเก็บ ID ของคำถามที่กำลังเปิดอยู่
const openFaqId = ref(null);

// ฟังก์ชันสำหรับเปิด/ปิด FAQ
const toggleFaq = (id) => {
    if (openFaqId.value === id) {
        // ถ้าคลิกคำถามที่เปิดอยู่แล้ว ให้ปิดมัน
        openFaqId.value = null;
    } else {
        // ถ้าคลิกคำถามใหม่ ให้เปิดอันนั้น
        openFaqId.value = id;
    }
};
</script>

<style scoped>
.card {
    transition: all 0.3s ease;
}

.card:hover {
    transform: translateY(-2px);
    box-shadow: 0 10px 25px rgba(59, 130, 246, 0.15);
}

.badge {
    display: inline-flex;
    align-items: center;
    padding: 0.25rem 0.5rem;
    border-radius: 9999px;
    font-size: 0.75rem;
    font-weight: 600;
}

.faq-content {
    max-height: 0;
    overflow: hidden;
    transition: max-height 0.4s ease-out;
}

.faq-content.show {
    max-height: 200px;
    /* สามารถปรับความสูงได้ตามความเหมาะสม */
    transition: max-height 0.4s ease-in;
}

.rotate-180 {
    transform: rotate(180deg);
}
</style>

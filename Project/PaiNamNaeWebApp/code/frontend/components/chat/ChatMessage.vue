<template>
    <div
        :class="[
            'flex mb-3',
            isOwnMessage ? 'justify-end' : 'justify-start'
        ]"
    >
        <!-- Avatar (แสดงเฉพาะข้อความจากคู่สนทนา) -->
        <div v-if="!isOwnMessage" class="flex-shrink-0 mr-3">
            <div class="flex items-center justify-center w-8 h-8 text-sm font-medium text-white bg-gray-400 rounded-full">
                {{ senderInitial }}
            </div>
        </div>

        <!-- Message Bubble -->
        <div
            :class="[
                'max-w-[70%] rounded-2xl px-4 py-2 shadow-sm',
                isOwnMessage 
                    ? 'bg-blue-600 text-white rounded-br-md' 
                    : 'bg-gray-100 text-gray-900 rounded-bl-md'
            ]"
        >
            <!-- Sender Role Label (แสดงเฉพาะข้อความจากคู่สนทนา) -->
            <div v-if="!isOwnMessage && showSenderLabel" class="mb-1 text-xs font-medium text-gray-500">
                {{ senderLabel }}
            </div>

            <!-- Message Content -->
            <p class="text-sm leading-relaxed whitespace-pre-wrap break-words">
                {{ message.content }}
            </p>

            <!-- Message Meta -->
            <div 
                :class="[
                    'flex items-center mt-1 text-xs',
                    isOwnMessage ? 'justify-end text-blue-200' : 'justify-start text-gray-400'
                ]"
            >
                <span>{{ formattedTime }}</span>
                
                <!-- Read Status (แสดงเฉพาะข้อความที่ตัวเองส่ง) -->
                <span v-if="isOwnMessage" class="ml-2">
                    <svg v-if="message.readAt" class="w-4 h-4 text-blue-200" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <!-- Double check (อ่านแล้ว) -->
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m0 0l4-4m-4 4l-4 4" />
                    </svg>
                    <svg v-else class="w-4 h-4 text-blue-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <!-- Single check (ส่งแล้ว) -->
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                    </svg>
                </span>
            </div>
        </div>

        <!-- Avatar placeholder (แสดงเฉพาะข้อความของตัวเอง เพื่อให้ layout สมมาตร) -->
        <div v-if="isOwnMessage" class="flex-shrink-0 w-8 ml-3"></div>
    </div>
</template>

<script setup>
import { computed } from 'vue'
import dayjs from 'dayjs'
import 'dayjs/locale/th'

dayjs.locale('th')

const props = defineProps({
    message: {
        type: Object,
        required: true
    },
    myRole: {
        type: String,
        required: true
    },
    showSenderLabel: {
        type: Boolean,
        default: true
    }
})

// ข้อความนี้เป็นของตัวเองหรือไม่
const isOwnMessage = computed(() => props.message.senderRole === props.myRole)

// Label แสดงบทบาทผู้ส่ง
const senderLabel = computed(() => {
    return props.message.senderRole === 'DRIVER' ? 'คนขับ' : 'ผู้โดยสาร'
})

// ตัวอักษรแรกของผู้ส่ง
const senderInitial = computed(() => {
    return props.message.senderRole === 'DRIVER' ? 'ขับ' : 'ผด'
})

// Format เวลา
const formattedTime = computed(() => {
    const time = dayjs(props.message.createdAt)
    const now = dayjs()
    
    // ถ้าเป็นวันนี้ แสดงแค่เวลา
    if (time.isSame(now, 'day')) {
        return time.format('HH:mm')
    }
    // ถ้าเป็นเมื่อวาน
    if (time.isSame(now.subtract(1, 'day'), 'day')) {
        return 'เมื่อวาน ' + time.format('HH:mm')
    }
    // ถ้าเป็นปีนี้
    if (time.isSame(now, 'year')) {
        return time.format('D MMM HH:mm')
    }
    // ปีอื่น
    return time.format('D MMM YYYY HH:mm')
})
</script>

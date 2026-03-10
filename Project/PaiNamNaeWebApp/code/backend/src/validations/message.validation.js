const { z } = require('zod');

// Schema สำหรับ booking ID และ message ID
const bookingIdParamSchema = z.object({
    bookingId: z.string().cuid({ message: 'Invalid booking ID format' }),
});

const messageIdParamSchema = z.object({
    bookingId: z.string().cuid({ message: 'Invalid booking ID format' }),
    messageId: z.string().cuid({ message: 'Invalid message ID format' }),
});

// Schema สำหรับส่งข้อความใหม่
const sendMessageSchema = z.object({
    content: z
        .string()
        .min(1, 'ข้อความต้องมีอย่างน้อย 1 ตัวอักษร')
        .max(1000, 'ข้อความต้องไม่เกิน 1000 ตัวอักษร'),
});

// Schema สำหรับ query ดึงข้อความ
const listMessagesQuerySchema = z.object({
    page: z.coerce.number().int().min(1).default(1),
    limit: z.coerce.number().int().min(1).max(100).default(50),
    sortOrder: z.enum(['asc', 'desc']).default('asc'), // เรียงจากเก่าไปใหม่
});

module.exports = {
    bookingIdParamSchema,
    messageIdParamSchema,
    sendMessageSchema,
    listMessagesQuerySchema,
};

const express = require('express');
const validate = require('../middlewares/validate');
const { protect } = require('../middlewares/auth');
const messageController = require('../controllers/message.controller');
const {
    bookingIdParamSchema,
    messageIdParamSchema,
    sendMessageSchema,
    listMessagesQuerySchema,
} = require('../validations/message.validation');

const router = express.Router({ mergeParams: true });

// ===== Message Routes (ภายใต้ /api/bookings/:bookingId/...) =====

/**
 * @route   GET /api/bookings/:bookingId/chat
 * @desc    ดึงข้อมูลห้องแชท
 * @access  Private (Driver หรือ Passenger ของ booking)
 */
router.get(
    '/chat',
    protect,
    validate({ params: bookingIdParamSchema }),
    messageController.getChatRoom
);

/**
 * @route   GET /api/bookings/:bookingId/messages
 * @desc    ดึงรายการข้อความทั้งหมดในการจอง
 * @access  Private (Driver หรือ Passenger ของ booking)
 */
router.get(
    '/messages',
    protect,
    validate({ params: bookingIdParamSchema, query: listMessagesQuerySchema }),
    messageController.getMessages
);

/**
 * @route   POST /api/bookings/:bookingId/messages
 * @desc    ส่งข้อความใหม่
 * @access  Private (Driver หรือ Passenger ของ booking)
 */
router.post(
    '/messages',
    protect,
    validate({ params: bookingIdParamSchema, body: sendMessageSchema }),
    messageController.sendMessage
);

/**
 * @route   GET /api/bookings/:bookingId/messages/unread-count
 * @desc    นับจำนวนข้อความที่ยังไม่ได้อ่าน
 * @access  Private (Driver หรือ Passenger ของ booking)
 */
router.get(
    '/messages/unread-count',
    protect,
    validate({ params: bookingIdParamSchema }),
    messageController.countUnreadMessages
);

/**
 * @route   PATCH /api/bookings/:bookingId/messages/read-all
 * @desc    Mark ข้อความทั้งหมดว่าอ่านแล้ว
 * @access  Private (Driver หรือ Passenger ของ booking)
 */
router.patch(
    '/messages/read-all',
    protect,
    validate({ params: bookingIdParamSchema }),
    messageController.markAllMessagesAsRead
);

/**
 * @route   PATCH /api/bookings/:bookingId/messages/:messageId/read
 * @desc    Mark ข้อความเดี่ยวว่าอ่านแล้ว
 * @access  Private (Driver หรือ Passenger ของ booking)
 */
router.patch(
    '/messages/:messageId/read',
    protect,
    validate({ params: messageIdParamSchema }),
    messageController.markMessageAsRead
);

module.exports = router;

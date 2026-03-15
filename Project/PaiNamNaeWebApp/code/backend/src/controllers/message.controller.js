const asyncHandler = require('express-async-handler');
const messageService = require('../services/message.service');

/**
 * @desc    ส่งข้อความใหม่ในการจอง
 * @route   POST /api/bookings/:bookingId/messages
 * @access  Private (Driver หรือ Passenger ของ booking)
 */
const sendMessage = asyncHandler(async (req, res) => {
    const { bookingId } = req.params;
    const userId = req.user.sub;
    const { content } = req.body;

    const message = await messageService.sendMessage(bookingId, userId, content);

    res.status(201).json({
        success: true,
        message: 'ส่งข้อความสำเร็จ',
        data: message
    });
});

/**
 * @desc    ดึงรายการข้อความทั้งหมดในการจอง
 * @route   GET /api/bookings/:bookingId/messages
 * @access  Private (Driver หรือ Passenger ของ booking)
 */
const getMessages = asyncHandler(async (req, res) => {
    const { bookingId } = req.params;
    const userId = req.user.sub;

    const result = await messageService.getMessages(bookingId, userId, req.query);

    res.status(200).json({
        success: true,
        message: 'ดึงข้อความสำเร็จ',
        ...result
    });
});

/**
 * @desc    ดึงข้อมูลห้องแชท
 * @route   GET /api/bookings/:bookingId/chat
 * @access  Private (Driver หรือ Passenger ของ booking)
 */
const getChatRoom = asyncHandler(async (req, res) => {
    const { bookingId } = req.params;
    const userId = req.user.sub;

    const chatRoom = await messageService.getChatRoom(bookingId, userId);

    res.status(200).json({
        success: true,
        message: 'ดึงข้อมูลห้องแชทสำเร็จ',
        data: chatRoom
    });
});

/**
 * @desc    Mark ข้อความว่าอ่านแล้ว
 * @route   PATCH /api/bookings/:bookingId/messages/:messageId/read
 * @access  Private (Driver หรือ Passenger ของ booking)
 */
const markMessageAsRead = asyncHandler(async (req, res) => {
    const { bookingId, messageId } = req.params;
    const userId = req.user.sub;

    const message = await messageService.markMessageAsRead(bookingId, messageId, userId);

    res.status(200).json({
        success: true,
        message: 'ทำเครื่องหมายอ่านข้อความสำเร็จ',
        data: message
    });
});

/**
 * @desc    Mark ข้อความทั้งหมดว่าอ่านแล้ว
 * @route   PATCH /api/bookings/:bookingId/messages/read-all
 * @access  Private (Driver หรือ Passenger ของ booking)
 */
const markAllMessagesAsRead = asyncHandler(async (req, res) => {
    const { bookingId } = req.params;
    const userId = req.user.sub;

    const result = await messageService.markAllMessagesAsRead(bookingId, userId);

    res.status(200).json({
        success: true,
        message: 'ทำเครื่องหมายอ่านข้อความทั้งหมดสำเร็จ',
        data: result
    });
});

/**
 * @desc    นับจำนวนข้อความที่ยังไม่ได้อ่าน
 * @route   GET /api/bookings/:bookingId/messages/unread-count
 * @access  Private (Driver หรือ Passenger ของ booking)
 */
const countUnreadMessages = asyncHandler(async (req, res) => {
    const { bookingId } = req.params;
    const userId = req.user.sub;

    const result = await messageService.countUnreadMessages(bookingId, userId);

    res.status(200).json({
        success: true,
        message: 'นับข้อความที่ยังไม่ได้อ่านสำเร็จ',
        data: result
    });
});

module.exports = {
    sendMessage,
    getMessages,
    getChatRoom,
    markMessageAsRead,
    markAllMessagesAsRead,
    countUnreadMessages
};

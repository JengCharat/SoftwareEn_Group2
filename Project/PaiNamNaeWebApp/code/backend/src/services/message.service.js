const prisma = require('../utils/prisma');
const ApiError = require('../utils/ApiError');
const { BookingStatus } = require('@prisma/client');
const { detectPersonalInfo } = require('../utils/personalInfoDetector');

/**
 * ตรวจสอบสิทธิ์การเข้าถึง booking (ต้องเป็น driver หรือ passenger ของ booking นั้น)
 */
const checkBookingAccess = async (bookingId, userId) => {
    const booking = await prisma.booking.findUnique({
        where: { id: bookingId },
        include: {
            route: {
                select: { driverId: true }
            }
        }
    });

    if (!booking) {
        throw new ApiError(404, 'ไม่พบการจองนี้');
    }

    const isDriver = booking.route.driverId === userId;
    const isPassenger = booking.passengerId === userId;

    if (!isDriver && !isPassenger) {
        throw new ApiError(403, 'คุณไม่มีสิทธิ์เข้าถึงการจองนี้');
    }

    return {
        booking,
        isDriver,
        isPassenger,
        role: isDriver ? 'DRIVER' : 'PASSENGER'
    };
};

/**
 * ส่งข้อความใหม่ในการจอง
 * Driver หรือ Passenger สามารถส่งข้อความได้โดยไม่เปิดเผยข้อมูลส่วนตัว
 */
const sendMessage = async (bookingId, userId, content) => {
    const { booking, role } = await checkBookingAccess(bookingId, userId);

    // ตรวจสอบว่าการจองยังอยู่ในสถานะที่สามารถแชทได้
    const allowedStatuses = [BookingStatus.PENDING, BookingStatus.CONFIRMED];
    if (!allowedStatuses.includes(booking.status)) {
        throw new ApiError(400, 'ไม่สามารถส่งข้อความในการจองที่ถูกยกเลิกหรือปฏิเสธแล้ว');
    }

    // สร้างข้อความใหม่
    const message = await prisma.message.create({
        data: {
            bookingId,
            senderId: userId,
            senderRole: role,
            content: content.trim()
        },
        select: {
            id: true,
            bookingId: true,
            senderRole: true,
            content: true,
            readAt: true,
            createdAt: true
        }
    });

    // ตรวจจับข้อมูลส่วนตัวในข้อความ
    const piiResult = detectPersonalInfo(content);
    if (piiResult.detected) {
        // แจ้งเตือนผู้ส่งว่าข้อความมีข้อมูลส่วนตัว
        message.personalInfoWarning = {
            detected: true,
            types: piiResult.types,
            warning: `ข้อความของคุณอาจมี${piiResult.types.join(', ')} กรุณาระวังการเปิดเผยข้อมูลส่วนตัว`
        };
    }

    // สร้าง notification แจ้งเตือนผู้รับ
    const recipientId = role === 'DRIVER' ? booking.passengerId : booking.route.driverId;
    await prisma.notification.create({
        data: {
            userId: recipientId,
            type: 'BOOKING',
            title: role === 'DRIVER' ? 'คนขับส่งข้อความถึงคุณ' : 'ผู้โดยสารส่งข้อความถึงคุณ',
            body: content.length > 50 ? content.substring(0, 50) + '...' : content,
            metadata: {
                kind: 'NEW_MESSAGE',
                bookingId,
                messageId: message.id,
                senderRole: role
            }
        }
    });

    return message;
};

/**
 * ดึงรายการข้อความทั้งหมดในการจอง
 * เรียงตามเวลา และไม่เปิดเผยข้อมูลส่วนตัวของผู้ส่ง
 */
const getMessages = async (bookingId, userId, opts = {}) => {
    await checkBookingAccess(bookingId, userId);

    const {
        page = 1,
        limit = 50,
        sortOrder = 'asc' // เรียงจากเก่าไปใหม่ (chat style)
    } = opts;

    const skip = (page - 1) * limit;
    const take = limit;

    const [total, messages] = await prisma.$transaction([
        prisma.message.count({ where: { bookingId } }),
        prisma.message.findMany({
            where: { bookingId },
            orderBy: { createdAt: sortOrder },
            skip,
            take,
            select: {
                id: true,
                bookingId: true,
                senderRole: true, // แค่บอกว่าเป็น DRIVER หรือ PASSENGER
                content: true,
                readAt: true,
                createdAt: true
            }
        })
    ]);

    return {
        data: messages,
        pagination: {
            page,
            limit,
            total,
            totalPages: Math.ceil(total / limit)
        }
    };
};

/**
 * อ่านข้อความ - mark as read
 * เฉพาะข้อความที่ส่งมาถึงตัวเอง (ไม่ใช่ข้อความที่ตัวเองส่ง)
 */
const markMessageAsRead = async (bookingId, messageId, userId) => {
    const { role } = await checkBookingAccess(bookingId, userId);

    const message = await prisma.message.findUnique({
        where: { id: messageId }
    });

    if (!message || message.bookingId !== bookingId) {
        throw new ApiError(404, 'ไม่พบข้อความนี้');
    }

    // ไม่สามารถ mark read ข้อความที่ตัวเองส่ง
    if (message.senderRole === role) {
        throw new ApiError(400, 'ไม่สามารถทำเครื่องหมายอ่านข้อความที่คุณส่งเอง');
    }

    // ถ้าอ่านแล้วไม่ต้องทำอีก
    if (message.readAt) {
        return message;
    }

    return prisma.message.update({
        where: { id: messageId },
        data: { readAt: new Date() },
        select: {
            id: true,
            bookingId: true,
            senderRole: true,
            content: true,
            readAt: true,
            createdAt: true
        }
    });
};

/**
 * Mark all messages as read สำหรับผู้ใช้
 */
const markAllMessagesAsRead = async (bookingId, userId) => {
    const { role } = await checkBookingAccess(bookingId, userId);

    // Mark เฉพาะข้อความที่ส่งมาจากอีกฝ่าย
    const oppositeRole = role === 'DRIVER' ? 'PASSENGER' : 'DRIVER';

    const result = await prisma.message.updateMany({
        where: {
            bookingId,
            senderRole: oppositeRole,
            readAt: null
        },
        data: { readAt: new Date() }
    });

    return { count: result.count };
};

/**
 * นับจำนวนข้อความที่ยังไม่ได้อ่าน
 */
const countUnreadMessages = async (bookingId, userId) => {
    const { role } = await checkBookingAccess(bookingId, userId);

    const oppositeRole = role === 'DRIVER' ? 'PASSENGER' : 'DRIVER';

    const count = await prisma.message.count({
        where: {
            bookingId,
            senderRole: oppositeRole,
            readAt: null
        }
    });

    return { unreadCount: count };
};

/**
 * ดึงข้อมูลห้องแชท (booking info สำหรับแสดงผล)
 * แสดงข้อมูลเฉพาะที่จำเป็น ไม่เปิดเผยข้อมูลส่วนตัว
 */
const getChatRoom = async (bookingId, userId) => {
    const { booking, role } = await checkBookingAccess(bookingId, userId);

    // ดึงข้อมูลเพิ่มเติม
    const fullBooking = await prisma.booking.findUnique({
        where: { id: bookingId },
        include: {
            route: {
                select: {
                    id: true,
                    startLocation: true,
                    endLocation: true,
                    departureTime: true,
                    routeSummary: true,
                    driver: {
                        select: {
                            id: true,
                            firstName: true,
                            profilePicture: true,
                            isVerified: true
                        }
                    },
                    vehicle: {
                        select: {
                            vehicleModel: true,
                            vehicleType: true,
                            color: true
                        }
                    }
                }
            },
            passenger: {
                select: {
                    id: true,
                    firstName: true,
                    profilePicture: true
                }
            }
        }
    });

    // สร้าง response ที่ปลอดภัย - แสดงเฉพาะข้อมูลที่จำเป็น
    const chatPartner = role === 'DRIVER' 
        ? {
            role: 'PASSENGER',
            firstName: fullBooking.passenger.firstName,
            profilePicture: fullBooking.passenger.profilePicture
        }
        : {
            role: 'DRIVER',
            firstName: fullBooking.route.driver.firstName,
            profilePicture: fullBooking.route.driver.profilePicture,
            isVerified: fullBooking.route.driver.isVerified
        };

    // นับข้อความที่ยังไม่ได้อ่าน
    const { unreadCount } = await countUnreadMessages(bookingId, userId);

    return {
        bookingId,
        status: fullBooking.status,
        myRole: role,
        chatPartner,
        route: {
            id: fullBooking.route.id,
            startLocation: fullBooking.route.startLocation,
            endLocation: fullBooking.route.endLocation,
            departureTime: fullBooking.route.departureTime,
            routeSummary: fullBooking.route.routeSummary
        },
        vehicle: fullBooking.route.vehicle,
        unreadCount
    };
};

module.exports = {
    sendMessage,
    getMessages,
    markMessageAsRead,
    markAllMessagesAsRead,
    countUnreadMessages,
    getChatRoom
};

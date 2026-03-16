const crypto = require('crypto');
const prisma = require('../utils/prisma');
const ApiError = require('../utils/ApiError');

const SHARE_EXPIRY_MS = 24 * 60 * 60 * 1000; // 24 hours

const getFrontendUrl = () => process.env.FRONTEND_URL || 'http://localhost:3002';

/**
 * สร้างหรือคืน active location share สำหรับ passenger
 * ถ้ามี active share อยู่แล้วจะคืนค่าเดิม
 */
const startSharing = async (passengerId, bookingId) => {
    // ถ้ามี active share อยู่แล้ว — คืนค่าเดิม
    const existing = await prisma.locationShare.findFirst({
        where: { passengerId, isActive: true, expiresAt: { gt: new Date() } },
    });
    if (existing) {
        return {
            ...existing,
            shareUrl: `${getFrontendUrl()}/location-sharing?token=${existing.shareToken}`,
        };
    }

    // ตรวจสอบ bookingId ถ้าระบุมา
    if (bookingId) {
        const booking = await prisma.booking.findFirst({ where: { id: bookingId, passengerId } });
        if (!booking) throw new ApiError(404, 'Booking not found');
    }

    const shareToken = crypto.randomBytes(24).toString('hex');
    const expiresAt = new Date(Date.now() + SHARE_EXPIRY_MS);

    const share = await prisma.locationShare.create({
        data: { passengerId, bookingId: bookingId || null, shareToken, isActive: true, expiresAt },
    });

    return {
        ...share,
        shareUrl: `${getFrontendUrl()}/location-sharing?token=${share.shareToken}`,
    };
};

/**
 * หยุดการแชร์โลเคชันของ passenger
 */
const stopSharing = async (passengerId) => {
    const share = await prisma.locationShare.findFirst({
        where: { passengerId, isActive: true },
    });
    if (!share) return { stopped: false };

    await prisma.locationShare.update({
        where: { id: share.id },
        data: { isActive: false },
    });
    return { stopped: true };
};

/**
 * อัปเดตพิกัด GPS ปัจจุบันของ passenger
 */
const updateLocation = async (passengerId, lat, lng) => {
    const share = await prisma.locationShare.findFirst({
        where: { passengerId, isActive: true, expiresAt: { gt: new Date() } },
    });
    if (!share) throw new ApiError(404, 'No active location share found. Please start sharing first.');

    await prisma.locationShare.update({
        where: { id: share.id },
        data: { lastLat: lat, lastLng: lng, lastUpdatedAt: new Date() },
    });
    return { updated: true };
};

/**
 * ดูสถานะการแชร์โลเคชันของ passenger (สำหรับ passenger เอง)
 */
const getStatus = async (passengerId) => {
    const share = await prisma.locationShare.findFirst({
        where: { passengerId, isActive: true, expiresAt: { gt: new Date() } },
        orderBy: { createdAt: 'desc' },
    });
    if (!share) return { isSharing: false };

    return {
        isSharing: true,
        shareToken: share.shareToken,
        shareUrl: `${getFrontendUrl()}/location-sharing?token=${share.shareToken}`,
        expiresAt: share.expiresAt,
        lastLat: share.lastLat,
        lastLng: share.lastLng,
        lastUpdatedAt: share.lastUpdatedAt,
    };
};

/**
 * ดูโลเคชันสาธารณะผ่าน token (ไม่ต้อง login)
 */
const getPublicView = async (shareToken) => {
    const share = await prisma.locationShare.findUnique({
        where: { shareToken },
        include: {
            passenger: { select: { firstName: true, lastName: true } },
        },
    });
    if (!share) throw new ApiError(404, 'Location share not found or has expired');

    const passengerName =
        [share.passenger.firstName, share.passenger.lastName].filter(Boolean).join(' ') || 'ผู้โดยสาร';

    const isActive = share.isActive && share.expiresAt > new Date();

    return {
        isActive,
        passengerName,
        lastLat: share.lastLat,
        lastLng: share.lastLng,
        lastUpdatedAt: share.lastUpdatedAt,
        expiresAt: share.expiresAt,
    };
};

module.exports = { startSharing, stopSharing, updateLocation, getStatus, getPublicView };

// SC#15 — ระบบรีวิวการเดินทาง
const prisma = require('../utils/prisma');
const ApiError = require('../utils/ApiError');

const INCLUDE_DRIVER = {
    select: { id: true, firstName: true, lastName: true, profilePicture: true },
};
const INCLUDE_PASSENGER = {
    select: { id: true, firstName: true, lastName: true, profilePicture: true },
};

/**
 * สร้างรีวิวใหม่ (passenger เท่านั้น)
 */
const createReview = async (passengerId, data) => {
    const { bookingId, rating, comment } = data;

    // ตรวจสอบว่าการจองมีอยู่จริง
    const booking = await prisma.booking.findUnique({
        where: { id: bookingId },
        include: { route: { select: { driverId: true, departureTime: true } } },
    });
    if (!booking) throw new ApiError(404, 'ไม่พบการจองนี้');

    // ตรวจว่าเป็น passenger ของการจองนี้จริง
    if (booking.passengerId !== passengerId) {
        throw new ApiError(403, 'คุณไม่ใช่ผู้โดยสารของการจองนี้');
    }

    // ตรวจสถานะการจอง: ต้องเป็น COMPLETED เท่านั้น (คนขับต้องกดเสร็จสิ้นก่อน)
    if (booking.status !== 'COMPLETED') {
        throw new ApiError(400, 'สามารถรีวิวได้เฉพาะการเดินทางที่เสร็จสิ้นแล้ว (คนขับต้องกดเสร็จสิ้นก่อน)');
    }

    // ตรวจว่ายังไม่เคยรีวิว booking นี้
    const existing = await prisma.review.findUnique({ where: { bookingId } });
    if (existing) throw new ApiError(409, 'คุณได้รีวิวการเดินทางนี้ไปแล้ว');

    return prisma.review.create({
        data: {
            bookingId,
            passengerId,
            driverId: booking.route.driverId,
            rating,
            comment: comment || null,
        },
        include: {
            driver: INCLUDE_DRIVER,
            passenger: INCLUDE_PASSENGER,
        },
    });
};

/**
 * ดูรีวิวที่ตัวเองเคยเขียน
 */
const getMyReviews = async (passengerId) => {
    const reviews = await prisma.review.findMany({
        where: { passengerId },
        include: {
            driver: INCLUDE_DRIVER,
            booking: {
                select: {
                    route: {
                        select: {
                            departureTime: true,
                            startLocation: true,
                            endLocation: true,
                        },
                    },
                },
            },
        },
        orderBy: { createdAt: 'desc' },
    });
    return reviews;
};

/**
 * ดูรีวิวทั้งหมดของ Driver พร้อมคะแนนเฉลี่ย (public)
 */
const getDriverReviews = async (driverId, opts = {}) => {
    const { page = 1, limit = 20 } = opts;
    const skip = (page - 1) * limit;

    const [reviews, agg] = await Promise.all([
        prisma.review.findMany({
            where: { driverId },
            include: {
                passenger: INCLUDE_PASSENGER,
            },
            orderBy: { createdAt: 'desc' },
            skip,
            take: limit,
        }),
        prisma.review.aggregate({
            where: { driverId },
            _avg: { rating: true },
            _count: { id: true },
        }),
    ]);

    return {
        data: reviews,
        avgRating: agg._avg.rating ? Math.round(agg._avg.rating * 10) / 10 : null,
        totalReviews: agg._count.id,
        pagination: {
            page,
            limit,
            totalPages: Math.ceil(agg._count.id / limit),
        },
    };
};

/**
 * แก้ไขรีวิว (เจ้าของเท่านั้น)
 */
const updateReview = async (reviewId, passengerId, data) => {
    const review = await prisma.review.findUnique({ where: { id: reviewId } });
    if (!review) throw new ApiError(404, 'ไม่พบรีวิวนี้');
    if (review.passengerId !== passengerId) throw new ApiError(403, 'คุณไม่มีสิทธิ์แก้ไขรีวิวนี้');

    return prisma.review.update({
        where: { id: reviewId },
        data: {
            ...(data.rating !== undefined && { rating: data.rating }),
            ...(data.comment !== undefined && { comment: data.comment }),
        },
        include: { driver: INCLUDE_DRIVER },
    });
};

/**
 * ลบรีวิว (เจ้าของเท่านั้น)
 */
const deleteReview = async (reviewId, passengerId) => {
    const review = await prisma.review.findUnique({ where: { id: reviewId } });
    if (!review) throw new ApiError(404, 'ไม่พบรีวิวนี้');
    if (review.passengerId !== passengerId) throw new ApiError(403, 'คุณไม่มีสิทธิ์ลบรีวิวนี้');

    return prisma.review.delete({ where: { id: reviewId } });
};

module.exports = { createReview, getMyReviews, getDriverReviews, updateReview, deleteReview };

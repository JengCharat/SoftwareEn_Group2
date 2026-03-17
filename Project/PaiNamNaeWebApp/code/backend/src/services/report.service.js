const prisma = require('../utils/prisma');
const ApiError = require('../utils/ApiError');
const { uploadToCloudinary } = require('../utils/cloudinary');
const { ReportStatus } = require('@prisma/client');

/**
 * สร้างรายงานใหม่ (Passenger รายงาน Driver)
 */
const createReport = async (reporterId, data, files = []) => {
    // ตรวจว่าคนถูกรายงานเป็น Driver จริง
    const driver = await prisma.user.findUnique({
        where: { id: data.reportedDriverId },
        select: { id: true, role: true },
    });

    if (!driver || driver.role !== 'DRIVER') {
        throw new ApiError(400, 'ผู้ถูกรายงานไม่ใช่คนขับ');
    }

    // ตรวจว่าไม่ได้รายงานตัวเอง
    if (reporterId === data.reportedDriverId) {
        throw new ApiError(400, 'ไม่สามารถรายงานตัวเองได้');
    }

    // ตรวจ booking (ถ้ามี) ว่า reporter เป็น passenger จริง
    if (data.bookingId) {
        const booking = await prisma.booking.findUnique({
            where: { id: data.bookingId },
            include: { route: { select: { driverId: true } } },
        });

        if (!booking) {
            throw new ApiError(404, 'ไม่พบการจองนี้');
        }
        if (booking.passengerId !== reporterId) {
            throw new ApiError(403, 'คุณไม่ใช่ผู้โดยสารของการจองนี้');
        }
        if (booking.route.driverId !== data.reportedDriverId) {
            throw new ApiError(400, 'คนขับไม่ตรงกับการจองนี้');
        }
    }

    // อัพโหลดหลักฐาน (รูป/วิดีโอ)
    let evidence = [];
    if (files && files.length > 0) {
        const uploadPromises = files.map(async (file) => {
            const result = await uploadToCloudinary(file.buffer, 'driver-reports');
            return {
                url: result.url,
                publicId: result.public_id,
                type: file.mimetype.startsWith('image/') ? 'image' : 'video',
                originalName: file.originalname,
            };
        });
        evidence = await Promise.all(uploadPromises);
    }

    // สร้างรายงาน
    const report = await prisma.driverReport.create({
        data: {
            reporterId,
            reportedDriverId: data.reportedDriverId,
            bookingId: data.bookingId || null,
            reason: data.reason,
            description: data.description,
            evidence: evidence.length > 0 ? evidence : undefined,
        },
        include: {
            reporter: { select: { id: true, firstName: true } },
            reportedDriver: { select: { id: true, firstName: true } },
        },
    });

    // แจ้ง Admin
    const admins = await prisma.user.findMany({
        where: { role: 'ADMIN' },
        select: { id: true },
    });

    if (admins.length > 0) {
        await prisma.notification.createMany({
            data: admins.map((admin) => ({
                userId: admin.id,
                type: 'SYSTEM',
                title: 'มีรายงานคนขับใหม่',
                body: `${report.reporter.firstName || 'ผู้โดยสาร'} รายงาน ${report.reportedDriver.firstName || 'คนขับ'}: ${data.reason}`,
                metadata: {
                    kind: 'NEW_DRIVER_REPORT',
                    reportId: report.id,
                    reportedDriverId: data.reportedDriverId,
                },
            })),
        });
    }

    return report;
};

/**
 * ดึงรายงานของตัวเอง (Passenger ดูรายงานที่ตัวเองสร้าง)
 */
const getMyReports = async (userId, opts = {}) => {
    const { page = 1, limit = 20 } = opts;
    const skip = (page - 1) * limit;

    const [total, reports] = await prisma.$transaction([
        prisma.driverReport.count({ where: { reporterId: userId } }),
        prisma.driverReport.findMany({
            where: { reporterId: userId },
            orderBy: { createdAt: 'desc' },
            skip,
            take: limit,
            include: {
                reportedDriver: { select: { id: true, firstName: true, profilePicture: true } },
                booking: { select: { id: true, route: { select: { routeSummary: true } } } },
            },
        }),
    ]);

    return {
        data: reports,
        pagination: { page, limit, total, totalPages: Math.ceil(total / limit) },
    };
};

/**
 * ดึงรายงานเดียว (Passenger ดูรายละเอียดรายงานของตัวเอง)
 */
const getReportById = async (reportId, userId) => {
    const report = await prisma.driverReport.findUnique({
        where: { id: reportId },
        include: {
            reporter: { select: { id: true, firstName: true, profilePicture: true } },
            reportedDriver: { select: { id: true, firstName: true, profilePicture: true } },
            booking: {
                select: {
                    id: true,
                    status: true,
                    route: { select: { id: true, routeSummary: true, departureTime: true } },
                },
            },
        },
    });

    if (!report) {
        throw new ApiError(404, 'ไม่พบรายงานนี้');
    }

    // Passenger ดูได้เฉพาะรายงานของตัวเอง, Admin ดูได้ทั้งหมด
    if (report.reporterId !== userId) {
        const user = await prisma.user.findUnique({ where: { id: userId }, select: { role: true } });
        if (!user || user.role !== 'ADMIN') {
            throw new ApiError(403, 'คุณไม่มีสิทธิ์ดูรายงานนี้');
        }
    }

    return report;
};

/**
 * Admin: ดึงรายงานทั้งหมด (พร้อม filter)
 */
const getAllReports = async (opts = {}) => {
    const { page = 1, limit = 20, status, reportedDriverId } = opts;
    const skip = (page - 1) * limit;

    const where = {};
    if (status) where.status = status;
    if (reportedDriverId) where.reportedDriverId = reportedDriverId;

    const [total, reports] = await prisma.$transaction([
        prisma.driverReport.count({ where }),
        prisma.driverReport.findMany({
            where,
            orderBy: { createdAt: 'desc' },
            skip,
            take: limit,
            include: {
                reporter: { select: { id: true, firstName: true, lastName: true, email: true } },
                reportedDriver: { select: { id: true, firstName: true, lastName: true, email: true } },
                booking: { select: { id: true, route: { select: { routeSummary: true } } } },
            },
        }),
    ]);

    return {
        data: reports,
        pagination: { page, limit, total, totalPages: Math.ceil(total / limit) },
    };
};

/**
 * Admin: อัพเดทสถานะรายงาน
 */
const updateReportStatus = async (reportId, adminId, data) => {
    const report = await prisma.driverReport.findUnique({ where: { id: reportId } });

    if (!report) {
        throw new ApiError(404, 'ไม่พบรายงานนี้');
    }

    const updateData = {
        status: data.status,
        adminId,
        adminNotes: data.adminNotes || null,
    };

    if (data.status === ReportStatus.RESOLVED || data.status === ReportStatus.DISMISSED) {
        updateData.resolvedAt = new Date();
    }

    const updated = await prisma.driverReport.update({
        where: { id: reportId },
        data: updateData,
        include: {
            reporter: { select: { id: true, firstName: true } },
            reportedDriver: { select: { id: true, firstName: true } },
        },
    });

    // แจ้งเตือน Passenger ผู้รายงาน
    const statusText = {
        REVIEWING: 'กำลังตรวจสอบ',
        RESOLVED: 'ดำเนินการแล้ว',
        DISMISSED: 'ยกเลิก/ไม่พบปัญหา',
    };

    await prisma.notification.create({
        data: {
            userId: report.reporterId,
            type: 'SYSTEM',
            title: 'อัพเดทสถานะรายงาน',
            body: `รายงานของคุณถูก${statusText[data.status] || 'อัพเดท'}แล้ว`,
            metadata: {
                kind: 'REPORT_STATUS_UPDATE',
                reportId: report.id,
                newStatus: data.status,
            },
        },
    });

    return updated;
};

module.exports = {
    createReport,
    getMyReports,
    getReportById,
    getAllReports,
    updateReportStatus,
};

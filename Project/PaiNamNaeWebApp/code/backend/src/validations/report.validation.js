const { z } = require('zod');
const { ReportReason, ReportStatus } = require('@prisma/client');

const createReportSchema = z.object({
    reportedDriverId: z.string().cuid('รหัสคนขับไม่ถูกต้อง'),
    bookingId: z.string().cuid('รหัสการจองไม่ถูกต้อง').optional(),
    reason: z.nativeEnum(ReportReason, { errorMap: () => ({ message: 'เหตุผลการรายงานไม่ถูกต้อง' }) }),
    description: z.string()
        .min(10, 'คำอธิบายต้องมีอย่างน้อย 10 ตัวอักษร')
        .max(2000, 'คำอธิบายต้องไม่เกิน 2000 ตัวอักษร'),
});

const updateReportStatusSchema = z.object({
    status: z.nativeEnum(ReportStatus, { errorMap: () => ({ message: 'สถานะไม่ถูกต้อง' }) }),
    adminNotes: z.string().max(2000, 'หมายเหตุต้องไม่เกิน 2000 ตัวอักษร').optional(),
});

const getReportParamsSchema = z.object({
    reportId: z.string().cuid('รหัสรายงานไม่ถูกต้อง'),
});

const listReportsQuerySchema = z.object({
    page: z.coerce.number().int().min(1).default(1).optional(),
    limit: z.coerce.number().int().min(1).max(100).default(20).optional(),
    status: z.nativeEnum(ReportStatus).optional(),
    reportedDriverId: z.string().cuid().optional(),
});

module.exports = {
    createReportSchema,
    updateReportStatusSchema,
    getReportParamsSchema,
    listReportsQuerySchema,
};

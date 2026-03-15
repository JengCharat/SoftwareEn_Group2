const express = require('express');
const validate = require('../middlewares/validate');
const { protect, requireAdmin } = require('../middlewares/auth');
const reportController = require('../controllers/report.controller');
const reportUpload = require('../middlewares/reportUpload.middleware');
const {
    createReportSchema,
    updateReportStatusSchema,
    getReportParamsSchema,
    listReportsQuerySchema,
} = require('../validations/report.validation');

const router = express.Router();

// --- Passenger Routes ---

// POST /reports - สร้างรายงาน (อัพโหลดหลักฐานสูงสุด 5 ไฟล์)
router.post(
    '/',
    protect,
    reportUpload.array('evidence', 5),
    validate({ body: createReportSchema }),
    reportController.createReport,
);

// GET /reports/my - ดูรายงานของตัวเอง
router.get(
    '/my',
    protect,
    validate({ query: listReportsQuerySchema }),
    reportController.getMyReports,
);

// --- Admin Routes ---

// GET /reports/admin - ดูรายงานทั้งหมด (Admin)  ← ต้องอยู่ก่อน /:reportId
router.get(
    '/admin',
    protect,
    requireAdmin,
    validate({ query: listReportsQuerySchema }),
    reportController.getAllReports,
);

// GET /reports/:reportId - ดูรายละเอียดรายงาน
router.get(
    '/:reportId',
    protect,
    validate({ params: getReportParamsSchema }),
    reportController.getReportById,
);

// PATCH /reports/:reportId/status - อัพเดทสถานะรายงาน (Admin)
router.patch(
    '/:reportId/status',
    protect,
    requireAdmin,
    validate({ params: getReportParamsSchema, body: updateReportStatusSchema }),
    reportController.updateReportStatus,
);

module.exports = router;

const asyncHandler = require('express-async-handler');
const reportService = require('../services/report.service');

const createReport = asyncHandler(async (req, res) => {
    const reporterId = req.user.sub;
    const report = await reportService.createReport(reporterId, req.body, req.files);
    res.status(201).json({ success: true, message: 'สร้างรายงานสำเร็จ', data: report });
});

const getMyReports = asyncHandler(async (req, res) => {
    const userId = req.user.sub;
    const result = await reportService.getMyReports(userId, req.query);
    res.status(200).json({ success: true, message: 'ดึงรายงานสำเร็จ', ...result });
});

const getReportById = asyncHandler(async (req, res) => {
    const userId = req.user.sub;
    const report = await reportService.getReportById(req.params.reportId, userId);
    res.status(200).json({ success: true, message: 'ดึงรายงานสำเร็จ', data: report });
});

const getAllReports = asyncHandler(async (req, res) => {
    const result = await reportService.getAllReports(req.query);
    res.status(200).json({ success: true, message: 'ดึงรายงานทั้งหมดสำเร็จ', ...result });
});

const updateReportStatus = asyncHandler(async (req, res) => {
    const adminId = req.user.sub;
    const report = await reportService.updateReportStatus(req.params.reportId, adminId, req.body);
    res.status(200).json({ success: true, message: 'อัพเดทสถานะรายงานสำเร็จ', data: report });
});

module.exports = {
    createReport,
    getMyReports,
    getReportById,
    getAllReports,
    updateReportStatus,
};

const asyncHandler = require('express-async-handler');
const { z } = require('zod');
const ApiError = require('../utils/ApiError');
const locationShareService = require('../services/locationShare.service');

const startSharingSchema = z.object({
    bookingId: z.string().optional(),
});

const updateLocationSchema = z.object({
    lat: z.number({ required_error: 'lat is required', invalid_type_error: 'lat must be a number' })
        .min(-90).max(90),
    lng: z.number({ required_error: 'lng is required', invalid_type_error: 'lng must be a number' })
        .min(-180).max(180),
});

/**
 * POST /api/location-sharing/start
 * Passenger เริ่มแชร์โลเคชัน — สร้าง public share link
 */
const start = asyncHandler(async (req, res) => {
    const passengerId = req.user.sub;

    const parsed = startSharingSchema.safeParse(req.body);
    if (!parsed.success) throw new ApiError(400, parsed.error.errors[0].message);

    const data = await locationShareService.startSharing(passengerId, parsed.data.bookingId);
    res.status(201).json({ success: true, data });
});

/**
 * DELETE /api/location-sharing/stop
 * Passenger หยุดแชร์โลเคชัน
 */
const stop = asyncHandler(async (req, res) => {
    const passengerId = req.user.sub;
    const data = await locationShareService.stopSharing(passengerId);
    res.status(200).json({ success: true, data });
});

/**
 * PATCH /api/location-sharing/update-location
 * Frontend ส่งพิกัด GPS ล่าสุดมาอัปเดต (ทุก 30 วินาที)
 */
const updateLocation = asyncHandler(async (req, res) => {
    const passengerId = req.user.sub;

    const parsed = updateLocationSchema.safeParse(req.body);
    if (!parsed.success) throw new ApiError(400, parsed.error.errors[0].message);

    const data = await locationShareService.updateLocation(passengerId, parsed.data.lat, parsed.data.lng);
    res.status(200).json({ success: true, data });
});

/**
 * GET /api/location-sharing/status
 * Passenger ดูสถานะการแชร์ของตัวเอง
 */
const getStatus = asyncHandler(async (req, res) => {
    const passengerId = req.user.sub;
    const data = await locationShareService.getStatus(passengerId);
    res.status(200).json({ success: true, data });
});

/**
 * GET /api/location-sharing/public/:token
 * Public endpoint — Emergency contact ดูโลเคชันโดยไม่ต้อง login
 */
const getPublicView = asyncHandler(async (req, res) => {
    const { token } = req.params;
    if (!token || token.length < 10) throw new ApiError(400, 'Invalid token');
    const data = await locationShareService.getPublicView(token);
    res.status(200).json({ success: true, data });
});

module.exports = { start, stop, updateLocation, getStatus, getPublicView };

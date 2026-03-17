const asyncHandler = require('express-async-handler');
const reviewService = require('../services/review.service');

const createReview = asyncHandler(async (req, res) => {
    const passengerId = req.user.sub;
    const review = await reviewService.createReview(passengerId, req.body);
    res.status(201).json({ success: true, message: 'สร้างรีวิวสำเร็จ', data: review });
});

const getMyReviews = asyncHandler(async (req, res) => {
    const passengerId = req.user.sub;
    const reviews = await reviewService.getMyReviews(passengerId);
    res.status(200).json({ success: true, message: 'ดึงรีวิวสำเร็จ', data: reviews });
});

const getDriverReviews = asyncHandler(async (req, res) => {
    const { driverId } = req.params;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const result = await reviewService.getDriverReviews(driverId, { page, limit });
    res.status(200).json({ success: true, message: 'ดึงรีวิวของคนขับสำเร็จ', ...result });
});

const updateReview = asyncHandler(async (req, res) => {
    const passengerId = req.user.sub;
    const review = await reviewService.updateReview(req.params.reviewId, passengerId, req.body);
    res.status(200).json({ success: true, message: 'อัพเดทรีวิวสำเร็จ', data: review });
});

const deleteReview = asyncHandler(async (req, res) => {
    const passengerId = req.user.sub;
    await reviewService.deleteReview(req.params.reviewId, passengerId);
    res.status(200).json({ success: true, message: 'ลบรีวิวสำเร็จ' });
});

module.exports = { createReview, getMyReviews, getDriverReviews, updateReview, deleteReview };

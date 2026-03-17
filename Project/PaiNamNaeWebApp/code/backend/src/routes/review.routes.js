const express = require('express');
const { protect } = require('../middlewares/auth');
const reviewController = require('../controllers/review.controller');

const router = express.Router();

// POST /reviews — สร้างรีวิว (ผู้โดยสารเท่านั้น)
router.post('/', protect, reviewController.createReview);

// GET /reviews/my — ดูรีวิวของตัวเอง
router.get('/my', protect, reviewController.getMyReviews);

// GET /reviews/driver/:driverId — ดูรีวิวและคะแนนเฉลี่ยของคนขับ
router.get('/driver/:driverId', protect, reviewController.getDriverReviews);

// PATCH /reviews/:reviewId — แก้ไขรีวิว
router.patch('/:reviewId', protect, reviewController.updateReview);

// DELETE /reviews/:reviewId — ลบรีวิว
router.delete('/:reviewId', protect, reviewController.deleteReview);

module.exports = router;

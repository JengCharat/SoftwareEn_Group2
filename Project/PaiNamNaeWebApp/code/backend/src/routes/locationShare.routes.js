const express = require('express');
const { protect } = require('../middlewares/auth');
const {
    start,
    stop,
    updateLocation,
    getStatus,
    getPublicView,
} = require('../controllers/locationShare.controller');

const router = express.Router();

// Public — no authentication required
router.get('/public/:token', getPublicView);

// Passenger-only (requires login)
router.get('/status', protect, getStatus);
router.post('/start', protect, start);
router.delete('/stop', protect, stop);
router.patch('/update-location', protect, updateLocation);

module.exports = router;

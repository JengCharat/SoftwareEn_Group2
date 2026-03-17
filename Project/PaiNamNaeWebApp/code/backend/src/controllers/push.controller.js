const asyncHandler = require('express-async-handler');
const pushService = require('../services/pushSubscription.service');
const { VAPID_PUBLIC_KEY } = require('../utils/webpush');

/** GET /api/push/vapid-public-key */
const getVapidPublicKey = asyncHandler(async (_req, res) => {
    res.status(200).json({
        success: true,
        data: { vapidPublicKey: VAPID_PUBLIC_KEY || null },
    });
});

/** POST /api/push/subscribe */
const subscribe = asyncHandler(async (req, res) => {
    const { endpoint, keys } = req.body;
    await pushService.subscribe(req.user.sub, { endpoint, keys });
    res.status(201).json({ success: true, message: 'Push subscription saved' });
});

/** POST /api/push/unsubscribe */
const unsubscribe = asyncHandler(async (req, res) => {
    const { endpoint } = req.body;
    await pushService.unsubscribe(req.user.sub, endpoint);
    res.status(200).json({ success: true, message: 'Push subscription removed' });
});

module.exports = { getVapidPublicKey, subscribe, unsubscribe };

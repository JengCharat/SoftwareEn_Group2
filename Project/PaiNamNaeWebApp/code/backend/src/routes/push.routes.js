const express = require('express');
const validate = require('../middlewares/validate');
const { protect } = require('../middlewares/auth');
const controller = require('../controllers/push.controller');
const { subscribeSchema, unsubscribeSchema } = require('../validations/push.validation');

const router = express.Router();

// GET /api/push/vapid-public-key  (public — ใช้ตอน register service worker)
router.get('/vapid-public-key', controller.getVapidPublicKey);

// POST /api/push/subscribe  (ต้อง login)
router.post(
    '/subscribe',
    protect,
    validate({ body: subscribeSchema }),
    controller.subscribe,
);

// POST /api/push/unsubscribe  (ต้อง login)
router.post(
    '/unsubscribe',
    protect,
    validate({ body: unsubscribeSchema }),
    controller.unsubscribe,
);

module.exports = router;

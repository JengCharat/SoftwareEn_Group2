const prisma = require('../utils/prisma');

/**
 * บันทึก push subscription ของ user (upsert — ถ้า endpoint ซ้ำจะอัปเดต keys)
 */
const subscribe = async (userId, { endpoint, keys }) => {
    return prisma.pushSubscription.upsert({
        where: {
            userId_endpoint: { userId, endpoint },
        },
        update: {
            p256dh: keys.p256dh,
            auth: keys.auth,
        },
        create: {
            userId,
            endpoint,
            p256dh: keys.p256dh,
            auth: keys.auth,
        },
    });
};

/**
 * ลบ push subscription (unsubscribe)
 */
const unsubscribe = async (userId, endpoint) => {
    return prisma.pushSubscription.deleteMany({
        where: { userId, endpoint },
    });
};

module.exports = { subscribe, unsubscribe };

const webpush = require('web-push');
const prisma = require('./prisma');

const VAPID_PUBLIC = process.env.VAPID_PUBLIC_KEY;
const VAPID_PRIVATE = process.env.VAPID_PRIVATE_KEY;
const VAPID_MAILTO = process.env.VAPID_MAILTO || 'mailto:admin@painamnae.com';

if (VAPID_PUBLIC && VAPID_PRIVATE) {
    webpush.setVapidDetails(VAPID_MAILTO, VAPID_PUBLIC, VAPID_PRIVATE);
} else {
    console.warn('[WebPush] VAPID keys not configured — push notifications disabled');
}

/**
 * ส่ง Web Push ไปยัง user ทุก subscription
 * @param {string} userId
 * @param {{ title: string, body: string, url?: string, icon?: string }} payload
 */
const sendPushToUser = async (userId, payload) => {
    if (!VAPID_PUBLIC || !VAPID_PRIVATE) {
        console.warn('[WebPush] VAPID not configured — skipping push to', userId);
        return;
    }

    const subscriptions = await prisma.pushSubscription.findMany({
        where: { userId },
    });

    if (subscriptions.length === 0) return;

    const data = JSON.stringify(payload);

    const results = await Promise.allSettled(
        subscriptions.map((sub) =>
            webpush.sendNotification(
                {
                    endpoint: sub.endpoint,
                    keys: { p256dh: sub.p256dh, auth: sub.auth },
                },
                data,
            ),
        ),
    );

    // ลบ subscription ที่หมดอายุหรือ unsubscribed (status 410 Gone)
    const expiredIds = [];
    results.forEach((r, i) => {
        if (r.status === 'rejected' && r.reason?.statusCode === 410) {
            expiredIds.push(subscriptions[i].id);
        }
    });

    if (expiredIds.length > 0) {
        await prisma.pushSubscription.deleteMany({
            where: { id: { in: expiredIds } },
        });
    }
};

module.exports = { sendPushToUser, VAPID_PUBLIC_KEY: VAPID_PUBLIC };

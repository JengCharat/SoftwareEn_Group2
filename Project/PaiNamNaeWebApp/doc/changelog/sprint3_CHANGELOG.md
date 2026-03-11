# Changelog — Sprint 3

## Story Card #12 (Enhancement) — Web Push Notification แทนอีเมล

**User Story:**
> As a passenger, I want to get a notification when the driver is about to pick me up so that I can get myself ready or respond to the driver.

**เป้าหมาย:** เปลี่ยนจากแจ้งเตือนผ่านอีเมลเป็น **Web Push Pop-up Notification** ที่แสดงบนมือถือ/เดสก์ท็อปแม้ผู้ใช้ไม่ได้เปิดเว็บอยู่ (รองรับ Android Chrome, iOS Safari)

---

### Acceptance Criteria

| # | เงื่อนไข | หมายเหตุ |
|---|---------|---------|
| AC-1 | เมื่อ Passenger เปิดเว็บครั้งแรกหลัง login ระบบจะขอ **Notification permission** และ register Service Worker อัตโนมัติ | ทำงานผ่าน composable `usePushNotification` |
| AC-2 | เมื่อ Driver กด "แจ้งกำลังไปรับ" ระบบส่ง **Web Push Notification** ไปยังทุก device ที่ Passenger ลงทะเบียนไว้ | ส่งผ่าน Web Push API + VAPID |
| AC-3 | Push notification แสดงเป็น **native pop-up** บนมือถือ/เดสก์ท็อป พร้อมชื่อคนขับ เส้นทาง และ Booking ID | ตามภาพ reference — Android/iOS style |
| AC-4 | เมื่อผู้ใช้คลิกที่ push notification จะเปิดหน้า `/myTrip` บนเว็บโดยอัตโนมัติ | ผ่าน `notificationclick` event ใน Service Worker |
| AC-5 | อีเมลยังคงส่งเป็น **fallback** ควบคู่กับ push notification | best-effort ทั้งสองช่องทาง |
| AC-6 | Subscription ที่หมดอายุ (410 Gone) จะถูกลบอัตโนมัติ | cleanup ใน `sendPushToUser()` |

---

### การเปลี่ยนแปลงที่ implement

#### Database

**`backend/prisma/schema.prisma`**
- เพิ่ม model `PushSubscription` (id, userId, endpoint, p256dh, auth, createdAt) พร้อม unique constraint `[userId, endpoint]`
- เพิ่ม relation `pushSubscriptions` ใน model `User`

#### Backend

**`backend/src/utils/webpush.js`** *(สร้างใหม่)*
- Utility สำหรับส่ง Web Push ผ่าน `web-push` package + VAPID authentication
- ฟังก์ชัน `sendPushToUser(userId, payload)` — ดึง subscription ทุก device ของ user แล้วส่ง push, ลบ subscription ที่หมดอายุ (status 410) อัตโนมัติ

**`backend/src/services/pushSubscription.service.js`** *(สร้างใหม่)*
- `subscribe(userId, { endpoint, keys })` — upsert push subscription (ถ้า endpoint ซ้ำจะอัปเดต keys)
- `unsubscribe(userId, endpoint)` — ลบ push subscription

**`backend/src/controllers/push.controller.js`** *(สร้างใหม่)*
- `getVapidPublicKey` — ส่งคืน VAPID public key สำหรับ frontend
- `subscribe` / `unsubscribe` — จัดการ push subscription

**`backend/src/validations/push.validation.js`** *(สร้างใหม่)*
- Zod schema สำหรับ validate `subscribeSchema` (endpoint, keys.p256dh, keys.auth) และ `unsubscribeSchema`

**`backend/src/routes/push.routes.js`** *(สร้างใหม่)*
- `GET  /api/push/vapid-public-key` — public endpoint
- `POST /api/push/subscribe` — ต้อง login
- `POST /api/push/unsubscribe` — ต้อง login

**`backend/src/routes/index.js`**
- เพิ่ม `router.use("/push", pushRoutes)`

**`backend/src/services/booking.service.js`**
- เพิ่ม `require('../utils/webpush')` — import `sendPushToUser`
- ในฟังก์ชัน `notifyPassengerDriverOnTheWay`: เพิ่มการส่ง Web Push **ก่อน** อีเมล (ทั้งสองเป็น fire-and-forget)

**`backend/package.json`**
- เพิ่ม dependency `web-push: ^3.6.7`

**`backend/.env` / `.env.example`**
- เพิ่ม `VAPID_PUBLIC_KEY`, `VAPID_PRIVATE_KEY`, `VAPID_MAILTO`

#### Frontend

**`frontend/public/sw.js`** *(สร้างใหม่)*
- Service Worker สำหรับ Web Push — รับ `push` event แสดง native notification pop-up
- Handle `notificationclick` — เปิดหน้า `/myTrip` เมื่อผู้ใช้คลิก notification

**`frontend/composables/usePushNotification.js`** *(สร้างใหม่)*
- Composable จัดการ push notification lifecycle:
  - `checkSupport()` — ตรวจว่า browser รองรับ
  - `subscribePush()` — ขอ permission, register SW, subscribe pushManager, ส่ง subscription ไป backend
  - `checkExistingSubscription()` — ตรวจว่ามี subscription อยู่แล้วหรือไม่

**`frontend/layouts/default.vue`**
- Import `usePushNotification` composable
- เมื่อ user login → ตรวจสอบ push subscription เดิม → ถ้าไม่มีจะ subscribe อัตโนมัติ

**`frontend/layouts/default_v1.vue`**
- เช่นเดียวกับ `default.vue`

---

### วันที่
- Implemented: 2026-03-10
- Sprint: Sprint 3
- AI Declare (Claude Opus 4.6) : ใช้ในการออกแบบ Web Push architecture, สร้าง Service Worker, webpush utility, push subscription API และ composable

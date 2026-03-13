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

#### ทดสอบ

| ไฟล์ | รายละเอียด |
|------|----------|
| `test/sprint3/test_code/API_Test/PushNotification/push_notification_api.postman_collection.json` | Postman collection 21 test cases ครอบคลุม: Setup (login 2 roles + get booking), VAPID Key (public key, no private key leak, base64url length), Subscribe (happy path, idempotent, 401, invalid endpoint 400, missing keys 400), Unsubscribe (happy path, idempotent, 401), Notify Pickup (creates in-app notification, passenger sees in inbox, 429 cooldown, 403 passenger, 401 no auth, 404 non-existent, metadata validation) |

---

### วันที่
- Implemented: 2026-03-10
- Sprint: Sprint 3
- AI Declare (Claude Opus 4.6) : ใช้ในการออกแบบ Web Push architecture, สร้าง Service Worker, webpush utility, push subscription API และ composable

---

## Story Card #10 (Enhancement) — Personal Info Protection ในระบบแชท

**User Story:**
> As a driver, I want to send a message to a passenger without revealing too much personal information so that I can communicate with them in a safer manner.

**เป้าหมาย:** เพิ่มระบบตรวจจับและแจ้งเตือนเมื่อผู้ใช้พยายามส่งข้อมูลส่วนตัว (เบอร์โทร, ที่อยู่, อีเมล, บัญชีโซเชียลมีเดีย ฯลฯ) ผ่านระบบแชท เพื่อป้องกันการหลอกลวงและรักษาความเป็นส่วนตัว (คล้ายระบบ Community Policy ของ Lazada)

---

### Acceptance Criteria

| # | เงื่อนไข | หมายเหตุ |
|---|---------|---------|
| AC-1 | เมื่อผู้ใช้กำลังพิมพ์ข้อความที่มีข้อมูลส่วนตัว จะแสดง **warning สีเหลือง** แบบ real-time ใต้ช่องพิมพ์ | ตรวจจับขณะพิมพ์โดยใช้ computed property |
| AC-2 | เมื่อผู้ใช้กดส่งข้อความที่มีข้อมูลส่วนตัว จะแสดง **Confirmation Modal** ให้เลือก "แก้ไขข้อความ" หรือ "ส่งต่อไป" | ป้องกันการส่งโดยไม่ตั้งใจ |
| AC-3 | มี **แบนเนอร์แจ้งเตือนถาวร** ด้านบนรายการข้อความในห้องแชท (คล้าย Lazada Community Policy) | แจ้งเตือนตลอดว่าไม่ควรแชร์ข้อมูลส่วนตัว |
| AC-4 | ระบบตรวจจับครอบคลุมทั้ง **ภาษาไทยและอังกฤษ** รวมถึงเทคนิคหลบเลี่ยง | รองรับ zero-width chars, เลขไทย, เขียนเป็นคำ, ใส่ตัวคั่น ฯลฯ |
| AC-5 | Backend ตรวจจับข้อมูลส่วนตัวและแนบ **warning flag** ใน response กลับมา | เป็น defense-in-depth ไม่ block การส่ง |
| AC-6 | แก้ไข bug ข้อความหายตอน polling refresh ทุก 5 วินาที | `isLoading` ไม่ถูก set ตอน polling, ใช้ merge strategy แทน replace |

---

### การเปลี่ยนแปลงที่ implement

#### Frontend

**`frontend/utils/personalInfoDetector.js`** *(สร้างใหม่)*
- ฟังก์ชัน `detectPersonalInfo(text)` — ตรวจจับข้อมูลส่วนตัว 15+ หมวด
- ฟังก์ชัน `normalizeText(text)` — ลบ zero-width characters เพื่อป้องกันการหลบ regex
- ใช้ `Set` สำหรับ deduplicate ชื่อหมวดที่ตรวจพบ

**ข้อมูลที่ตรวจจับได้:**

| หมวด | ตัวอย่างที่ตรวจจับ (ไทย + อังกฤษ) |
|---|---|
| เบอร์โทรศัพท์ | `08x-xxx-xxxx`, `+66`, เลขไทย `๐๘๑...`, เขียนเป็นคำ, keyword `โทร/tel/call me` |
| อีเมล | `xxx@xxx.com`, `xxx แอท gmail`, fullwidth `＠` |
| LINE ID | `ไลน์/แอดไลน์/ทักไลน์/line id`, `line.me/xxx`, `เพิ่มเพื่อน/ทักมา` |
| เลขบัตรประชาชน | 13 หลักแยกด้วยตัวคั่นใดก็ได้, keyword `เลขบัตร/national id` |
| Facebook | `เฟส/fb/เฟสบุ๊ค`, `facebook.com/xxx`, `messenger/inbox เฟส` |
| Instagram | `ไอจี/ig/อินสตาแกรม`, `instagram.com/xxx` |
| Twitter/X | `ทวิตเตอร์/twitter`, `x.com/xxx` |
| TikTok | `ติ๊กต๊อก/tiktok`, `tiktok.com/@xxx` |
| Telegram | `เทเลแกรม/telegram`, `t.me/xxx` |
| Discord | `ดิสคอร์ด/discord` |
| WeChat | `วีแชท/wechat` |
| เลขบัญชีธนาคาร | ชื่อธนาคาร (กสิกร, SCB, KBank ฯลฯ), `บัญชี/account`, `พร้อมเพย์/promptpay`, `โอนเงิน` |
| ที่อยู่ (ไทย) | ตำบล, อำเภอ, จังหวัด, ซอย, ถนน, หมู่, อาคาร, คอนโด, รหัสไปรษณีย์ 5 หลัก, ชื่อจังหวัด |
| ที่อยู่ (EN) | `address/send to/deliver to`, `street/road/building/soi/district` |
| ลิงก์/URL | `https://...`, `www.xxx.com` |
| เลขพาสปอร์ต | `พาสปอร์ต/passport` |
| เลขใบขับขี่ | `ใบขับขี่/driver's license` |

**`frontend/components/chat/ChatInput.vue`** *(แก้ไข)*
- เพิ่ม real-time warning ขณะพิมพ์ (แถบสีเหลืองแสดงหมวดข้อมูลที่ตรวจพบ)
- เพิ่ม Confirmation Modal ก่อนส่งข้อความที่มีข้อมูลส่วนตัว (เลือก "แก้ไขข้อความ" หรือ "ส่งต่อไป")
- แยก `handleSubmit()` (ตรวจจับ) กับ `doSend()` (ส่งจริง) ออกจากกัน

**`frontend/components/chat/ChatRoom.vue`** *(แก้ไข)*
- เพิ่มแบนเนอร์ "⚠️ แจ้งเตือนจาก PaiNamNae" ด้านบนรายการข้อความ (คล้าย Lazada Community Policy warning)

**`frontend/composables/useChat.js`** *(แก้ไข)*
- แก้ bug `isLoading = true` ตอน polling ที่ทำให้ข้อความหายทุก 5 วินาที → ตั้ง `isLoading` เฉพาะตอนโหลดครั้งแรก
- ลบ double API call (`$api()` + `$api.raw()` ที่ซ้ำซ้อน)
- เปลี่ยน `refreshMessages()` เป็น **merge strategy** — รวมข้อความใหม่เข้ากับเดิมแทนที่จะเขียนทับ + อัพเดท `readAt`

#### Backend

**`backend/src/utils/personalInfoDetector.js`** *(สร้างใหม่)*
- เหมือน frontend version (CommonJS module) — ใช้ตรวจจับฝั่ง server เป็น defense-in-depth

**`backend/src/services/message.service.js`** *(แก้ไข)*
- Import `detectPersonalInfo` จาก utils
- เมื่อส่งข้อความที่มีข้อมูลส่วนตัว → แนบ `personalInfoWarning` ใน response (detected: true, types, warning message)

---

#### ทดสอบ

| ไฟล์ | รายละเอียด |
|------|----------|
| `test/sprint3/test_code/API_Test/Chat/chat_api.postman_collection.json` | Postman collection 31 test cases ครอบคลุม: Setup (login 2 roles + get bookingId), Chat Room (get info, unauthorized 401), Send Message (driver/passenger 201, no token 401, empty 400, over 1000 chars 400, third party 403), PII Detection (เบอร์โทร, อีเมล, LINE ID, ที่อยู่, เลขบัตรประชาชน, Facebook, เลขบัญชีธนาคาร, URL, เบอร์ obfuscated, รหัสไปรษณีย์), Get Messages (list, pagination, 401), Unread Count & Mark Read (get count, mark all, verify zero, mark single, own message 400, 401, non-existent booking 404) |

---

### วันที่
- Implemented: 2026-03-11
- Sprint: Sprint 3
- AI Declare (Claude Opus 4.6) : ใช้ในการออกแบบระบบตรวจจับข้อมูลส่วนตัว, สร้าง regex patterns (ไทย+อังกฤษ), UI warning/confirmation modal, แก้ bug polling, และ backend PII detection

---

## Story Card #13 (New Feature) — ระบบรายงานพฤติกรรมคนขับ (Driver Report)

**User Story:**
> As a passenger, I want to report the driver behavior to the admin and get the update on the filed case.

**เป้าหมาย:** ผู้โดยสารสามารถรายงานพฤติกรรมคนขับ พร้อมแนบหลักฐาน (รูปภาพ/วิดีโอ) และติดตามสถานะรายงานได้ แอดมินสามารถจัดการรายงานและอัพเดทสถานะได้

---

### Acceptance Criteria

| # | เงื่อนไข | หมายเหตุ |
|---|---------|---------|
| AC-1 | Passenger สร้างรายงานได้ โดยเลือกคนขับ, เหตุผล (8 ประเภท), รายละเอียด | ผ่านหน้า `/report/create` |
| AC-2 | รองรับอัพโหลดหลักฐาน JPEG/JPG/PNG/MP4/MP3 สูงสุด 5 ไฟล์ ขนาดไม่เกิน 20MB ต่อไฟล์ | ผ่าน Multer → Cloudinary |
| AC-3 | Passenger ดูรายงานของตัวเองได้ พร้อม pagination | หน้า `/report` |
| AC-4 | Passenger ดูรายละเอียดรายงานพร้อมหลักฐานและ timeline สถานะ | หน้า `/report/[id]` |
| AC-5 | Admin เห็นรายงานทั้งหมด กรองตามสถานะได้ | หน้า `/admin/reports` |
| AC-6 | Admin อัพเดทสถานะ (PENDING → REVIEWING → RESOLVED/DISMISSED) พร้อมหมายเหตุได้ | หน้า `/admin/reports/[id]` |
| AC-7 | ระบบแจ้งเตือน Admin เมื่อมีรายงานใหม่ | ผ่าน Notification model |
| AC-8 | ระบบแจ้งเตือน Passenger เมื่อสถานะเปลี่ยน | ผ่าน Notification model |

---

### การเปลี่ยนแปลงที่ implement

#### Database

**`backend/prisma/schema.prisma`**
- เพิ่ม enum `ReportStatus` (PENDING, REVIEWING, RESOLVED, DISMISSED)
- เพิ่ม enum `ReportReason` (RECKLESS_DRIVING, HARASSMENT, FRAUD, NO_SHOW, VEHICLE_CONDITION, ROUTE_DEVIATION, INAPPROPRIATE_BEHAVIOR, OTHER)
- เพิ่ม model `DriverReport` มี relations ไปยัง User (reporter, reportedDriver, admin) และ Booking
- เพิ่ม field `evidence` (JSON) สำหรับเก็บข้อมูลไฟล์หลักฐาน
- เพิ่ม relation ใน User model: `ReportsCreated`, `ReportsReceived`
- เพิ่ม relation ใน Booking model: `DriverReport`

#### Backend — ไฟล์ใหม่

| ไฟล์ | รายละเอียด |
|------|-----------|
| `src/services/report.service.js` | Business logic: createReport, getMyReports, getReportById, getAllReports, updateReportStatus พร้อม Cloudinary upload และ Notification |
| `src/controllers/report.controller.js` | Express controller ใช้ asyncHandler |
| `src/routes/report.routes.js` | Routes: POST /, GET /my, GET /:reportId, GET /admin, PATCH /:reportId/status |
| `src/validations/report.validation.js` | Zod schemas: createReportSchema, updateReportStatusSchema, getReportParamsSchema, listReportsQuerySchema |
| `src/middlewares/reportUpload.middleware.js` | Multer config: 20MB limit, JPEG/JPG/PNG/MP4/MP3 |

#### Backend — ไฟล์ที่แก้ไข

| ไฟล์ | รายละเอียด |
|------|-----------|
| `src/routes/index.js` | เพิ่ม `router.use("/reports", reportRoutes)` |

#### Frontend — ไฟล์ใหม่

| ไฟล์ | รายละเอียด |
|------|-----------|
| `pages/report/create.vue` | หน้าสร้างรายงาน: เลือกคนขับจาก booking, เหตุผล, รายละเอียด, อัพโหลดหลักฐาน (preview รูป/วิดีโอ) |
| `pages/report/index.vue` | หน้ารายการรายงานของ Passenger พร้อม pagination |
| `pages/report/[id].vue` | หน้าดูรายละเอียดรายงาน พร้อม timeline สถานะ และ admin notes |
| `pages/admin/reports/index.vue` | หน้า Admin ดูรายงานทั้งหมด กรองตามสถานะ ในรูป table |
| `pages/admin/reports/[id].vue` | หน้า Admin ดูรายละเอียดและอัพเดทสถานะ พร้อมหมายเหตุ |

#### Frontend — ไฟล์ที่แก้ไข

| ไฟล์ | รายละเอียด |
|------|-----------|
| `layouts/default.vue` | เพิ่มลิงก์ "รายงานคนขับ" สำหรับ Passenger ในเมนู navigation |
| `components/admin/AdminSidebar.vue` | เพิ่มลิงก์ "Report Management" ใน Admin sidebar |

#### ทดสอบ

| ไฟล์ | รายละเอียด |
|------|-----------|
| `test/sprint3/test_code/API_Test/Report/driver_report.postman_collection.json` | Postman collection 25+ test cases ครอบคลุม: Setup (login 3 roles), Create Report (happy + validations), Get My Reports, Get by ID, Admin List (filter), Admin Update Status, Notification verification |
| `test/sprint3/test_code/Robot_Test/driver_report_api.robot` | Robot Framework API test suite 27 test cases ครอบคลุม: Create Report (valid, HARASSMENT, validations), Get My Reports (list, filter), Get by ID (own/cross-user), Admin List/Filter, Admin Update Status (REVIEWING/RESOLVED/DISMISSED), Passenger Notification |
| `test/sprint3/test_code/Robot_Test/driver_report_browser.robot` | Robot Framework Selenium browser test suite 16 test cases ครอบคลุม: Login (happy/negative), Navigate to Create Report, Form fields validation, Character count, Submit report, Report list (heading, button, badges), Report detail (navigation, status badge), Unauthenticated redirect, MyTrip report button |

---

### วันที่
- Implemented: 2026-03-11
- Sprint: Sprint 3
- AI Declare (Claude Opus 4.6) : ใช้ในการออกแบบ Database schema, Backend API (service/controller/routes/validation/middleware), Frontend pages (Passenger report + Admin management), Postman test collection, และ Changelog

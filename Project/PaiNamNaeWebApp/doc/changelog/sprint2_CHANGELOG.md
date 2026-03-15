# Changelog — Sprint 2

## Story Card #12 — Driver Pick-Up Notification for Passenger

**User Story:**
> As a passenger, I want to get a notification when the driver is about to pick me up so that I can get myself ready or respond to the driver.

---

### Acceptance Criteria (ออกแบบโดยทีม)

| # | เงื่อนไข | หมายเหตุ |
|---|---------|---------|
| AC-1 | Driver สามารถกดปุ่ม **"แจ้งกำลังไปรับ"** ได้เฉพาะ Booking ที่มีสถานะ `CONFIRMED` เท่านั้น | ป้องกัน spam จาก booking ที่ยังไม่ยืนยัน |
| AC-2 | เมื่อ Driver กด ระบบจะสร้าง Notification ชนิด `BOOKING` พร้อม `metadata.kind = "DRIVER_ON_THE_WAY"` ไปยัง Passenger ของ Booking นั้น | persistent notification บันทึกใน DB |
| AC-3 | Passenger ที่เปิดแอปอยู่จะเห็น **Toast notification** ขึ้นทันที (ภายใน polling interval ≤ 30 วินาที) โดยไม่ต้องกด Reload | UX ที่ผู้โดยสารรับรู้ทันที |
| AC-4 | ห้อง Bell Notification ในแถบ Header แสดงจุดแดง (unread badge) พร้อมข้อความ **"คนขับกำลังมารับคุณแล้ว"** | notification panel ปกติ |
| AC-5 | Driver กดปุ่มซ้ำได้ (เพื่อ remind) แต่ระบบ Cooldown **3 นาที** ต่อ booking — ถ้ายังอยู่ใน cooldown ปุ่มจะ disable และแสดงเวลานับถอยหลัง | ป้องกัน spam |
| AC-6 | Notification ต้องระบุชื่อคนขับ รหัส Booking และเส้นทางปลายทางใน `body` เพื่อให้ Passenger ระบุได้ว่าเป็นเส้นทางไหน | ข้อมูลที่เพียงพอสำหรับผู้โดยสาร |
| AC-7 | ถ้า Passenger ไม่ได้เปิดแอป Notification จะยังคงอยู่ใน inbox (Bell panel) รอให้กลับมาอ่าน | persistent via DB |
| AC-8 | ระบบส่ง **อีเมลแจ้งเตือน** ไปยังอีเมลของ Passenger ควบคู่กับ in-app notification เพื่อให้ผู้โดยสารที่ไม่ได้เปิดเว็บรับรู้ได้ทันที | best-effort (ไม่ block API) ผ่าน SMTP / Nodemailer |

---

### การเปลี่ยนแปลงที่ implement

#### Backend

**`backend/src/services/booking.service.js`**
- เพิ่มฟังก์ชัน `notifyPassengerDriverOnTheWay(bookingId, driverId)` — validate สถานะ booking, ตรวจสอบ ownership, enforce cooldown 3 นาที ผ่าน `metadata.lastPickupNotifiedAt`, สร้าง notification `DRIVER_ON_THE_WAY` ไปยัง passenger
- เพิ่มการส่งอีเมลแจ้งเตือนแบบ fire-and-forget หลัง notification ถูกสร้างแล้ว (ไม่ block API response)

**`backend/src/utils/email.js`** *(สร้างใหม่)*
- Utility module สำหรับส่งอีเมลผ่าน SMTP ด้วย Nodemailer
- รองรับ Gmail, Outlook หรือ SMTP server ใด ๆ ผ่าน ENV config
- ถ้าไม่ตั้งค่า `SMTP_*` ระบบจะข้ามการส่งอีเมลโดยอัตโนมัติ (graceful fallback)

**`backend/src/controllers/booking.controller.js`**
- เพิ่ม handler `notifyPassengerDriverOnTheWay` รับ `PATCH /bookings/:id/notify-pickup`

**`backend/src/routes/booking.routes.js`**
- เพิ่ม route `PATCH /bookings/:id/notify-pickup` (protect + requireDriverVerified)

#### Frontend

**`frontend/pages/myRoute/index.vue`**
- เพิ่มปุ่ม **"แจ้งกำลังไปรับ"** ใน booking card เมื่อสถานะ = `confirmed`
- Logic cooldown 3 นาทีฝั่ง UI (นับถอยหลังแสดงบนปุ่ม)

**`frontend/layouts/default.vue`**
- เพิ่ม `setInterval` polling `/notifications?limit=5` ทุก 30 วินาที เมื่อ user login อยู่
- เมื่อพบ notification ที่ `metadata.kind === "DRIVER_ON_THE_WAY"` และยังไม่ได้อ่าน (`readAt === null`) ซึ่งสร้างหลัง session เริ่ม — แสดง Toast `warning` ขึ้นทันที และเพิ่มเข้า notification list

---

### วันที่
- Implemented: 2026-02-26
- Sprint: Sprint 2, Week 2
- AI Declare (Claude Opus 4.6) : ใช้ขึ้นโครงในการสร้างการแจ้งเตือน และทำ Toast Wrapper
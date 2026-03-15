/**
 * @swagger
 * tags:
 *   name: Messages
 *   description: ระบบข้อความแบบปลอดภัย - สื่อสารระหว่าง Driver และ Passenger โดยไม่เปิดเผยข้อมูลส่วนตัว
 */

/**
 * @swagger
 * /api/bookings/{bookingId}/chat:
 *   get:
 *     summary: ดึงข้อมูลห้องแชท
 *     description: |
 *       ดึงข้อมูลห้องแชทสำหรับการจองนั้นๆ รวมถึงข้อมูลคู่สนทนา (แสดงเฉพาะชื่อและรูปโปรไฟล์)
 *       ข้อมูลเส้นทาง และจำนวนข้อความที่ยังไม่ได้อ่าน
 *     tags: [Messages]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: bookingId
 *         required: true
 *         schema: { type: string, example: "cmbooking12345" }
 *         description: ID ของการจอง
 *     responses:
 *       200:
 *         description: ดึงข้อมูลห้องแชทสำเร็จ
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success: { type: boolean, example: true }
 *                 message: { type: string, example: "ดึงข้อมูลห้องแชทสำเร็จ" }
 *                 data:
 *                   type: object
 *                   properties:
 *                     bookingId: { type: string }
 *                     status: { type: string, enum: [PENDING, CONFIRMED, REJECTED, CANCELLED] }
 *                     myRole: { type: string, enum: [DRIVER, PASSENGER] }
 *                     chatPartner:
 *                       type: object
 *                       properties:
 *                         role: { type: string, enum: [DRIVER, PASSENGER] }
 *                         firstName: { type: string }
 *                         profilePicture: { type: string }
 *                         isVerified: { type: boolean }
 *                     route:
 *                       type: object
 *                       properties:
 *                         id: { type: string }
 *                         startLocation: { type: object }
 *                         endLocation: { type: object }
 *                         departureTime: { type: string, format: date-time }
 *                         routeSummary: { type: string }
 *                     vehicle:
 *                       type: object
 *                       properties:
 *                         vehicleModel: { type: string }
 *                         vehicleType: { type: string }
 *                         color: { type: string }
 *                     unreadCount: { type: integer }
 *       403:
 *         description: ไม่มีสิทธิ์เข้าถึงการจองนี้
 *       404:
 *         description: ไม่พบการจอง
 */

/**
 * @swagger
 * /api/bookings/{bookingId}/messages:
 *   get:
 *     summary: ดึงรายการข้อความทั้งหมดในการจอง
 *     description: |
 *       ดึงข้อความทั้งหมดในห้องแชทของการจองนั้น โดยเรียงจากเก่าไปใหม่ (chat style)
 *       ข้อความจะแสดงเฉพาะ senderRole (DRIVER/PASSENGER) โดยไม่เปิดเผยข้อมูลส่วนตัว
 *     tags: [Messages]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: bookingId
 *         required: true
 *         schema: { type: string, example: "cmbooking12345" }
 *       - in: query
 *         name: page
 *         schema: { type: integer, default: 1 }
 *       - in: query
 *         name: limit
 *         schema: { type: integer, default: 50 }
 *       - in: query
 *         name: sortOrder
 *         schema: { type: string, enum: [asc, desc], default: asc }
 *     responses:
 *       200:
 *         description: ดึงข้อความสำเร็จ
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success: { type: boolean, example: true }
 *                 message: { type: string }
 *                 data:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       id: { type: string }
 *                       bookingId: { type: string }
 *                       senderRole: { type: string, enum: [DRIVER, PASSENGER] }
 *                       content: { type: string }
 *                       readAt: { type: string, format: date-time, nullable: true }
 *                       createdAt: { type: string, format: date-time }
 *                 pagination:
 *                   type: object
 *                   properties:
 *                     page: { type: integer }
 *                     limit: { type: integer }
 *                     total: { type: integer }
 *                     totalPages: { type: integer }
 *       403:
 *         description: ไม่มีสิทธิ์เข้าถึงการจองนี้
 *       404:
 *         description: ไม่พบการจอง
 *   post:
 *     summary: ส่งข้อความใหม่
 *     description: |
 *       ส่งข้อความถึงคู่สนทนาในการจองนั้น ระบบจะส่ง notification แจ้งเตือนผู้รับโดยอัตโนมัติ
 *       สามารถส่งได้เฉพาะการจองที่อยู่ในสถานะ PENDING หรือ CONFIRMED
 *     tags: [Messages]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: bookingId
 *         required: true
 *         schema: { type: string, example: "cmbooking12345" }
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [content]
 *             properties:
 *               content:
 *                 type: string
 *                 minLength: 1
 *                 maxLength: 1000
 *                 example: "สวัสดีครับ กรุณารอ ณ จุดรับที่นัดหมายตามเวลานะครับ"
 *     responses:
 *       201:
 *         description: ส่งข้อความสำเร็จ
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success: { type: boolean, example: true }
 *                 message: { type: string, example: "ส่งข้อความสำเร็จ" }
 *                 data:
 *                   type: object
 *                   properties:
 *                     id: { type: string }
 *                     bookingId: { type: string }
 *                     senderRole: { type: string, enum: [DRIVER, PASSENGER] }
 *                     content: { type: string }
 *                     readAt: { type: string, nullable: true }
 *                     createdAt: { type: string, format: date-time }
 *       400:
 *         description: ไม่สามารถส่งข้อความในการจองที่ถูกยกเลิกหรือปฏิเสธแล้ว
 *       403:
 *         description: ไม่มีสิทธิ์เข้าถึงการจองนี้
 *       404:
 *         description: ไม่พบการจอง
 */

/**
 * @swagger
 * /api/bookings/{bookingId}/messages/unread-count:
 *   get:
 *     summary: นับจำนวนข้อความที่ยังไม่ได้อ่าน
 *     description: นับจำนวนข้อความที่ส่งมาจากคู่สนทนาและยังไม่ได้อ่าน
 *     tags: [Messages]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: bookingId
 *         required: true
 *         schema: { type: string, example: "cmbooking12345" }
 *     responses:
 *       200:
 *         description: นับสำเร็จ
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success: { type: boolean, example: true }
 *                 message: { type: string }
 *                 data:
 *                   type: object
 *                   properties:
 *                     unreadCount: { type: integer, example: 3 }
 *       403:
 *         description: ไม่มีสิทธิ์เข้าถึงการจองนี้
 *       404:
 *         description: ไม่พบการจอง
 */

/**
 * @swagger
 * /api/bookings/{bookingId}/messages/read-all:
 *   patch:
 *     summary: Mark ข้อความทั้งหมดว่าอ่านแล้ว
 *     description: ทำเครื่องหมายข้อความทั้งหมดที่ส่งมาจากคู่สนทนาว่าอ่านแล้ว
 *     tags: [Messages]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: bookingId
 *         required: true
 *         schema: { type: string, example: "cmbooking12345" }
 *     responses:
 *       200:
 *         description: ทำเครื่องหมายอ่านทั้งหมดสำเร็จ
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success: { type: boolean, example: true }
 *                 message: { type: string }
 *                 data:
 *                   type: object
 *                   properties:
 *                     count: { type: integer, example: 5 }
 *       403:
 *         description: ไม่มีสิทธิ์เข้าถึงการจองนี้
 *       404:
 *         description: ไม่พบการจอง
 */

/**
 * @swagger
 * /api/bookings/{bookingId}/messages/{messageId}/read:
 *   patch:
 *     summary: Mark ข้อความเดี่ยวว่าอ่านแล้ว
 *     description: |
 *       ทำเครื่องหมายข้อความหนึ่งว่าอ่านแล้ว
 *       ไม่สามารถ mark ข้อความที่ตัวเองส่งได้
 *     tags: [Messages]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: bookingId
 *         required: true
 *         schema: { type: string, example: "cmbooking12345" }
 *       - in: path
 *         name: messageId
 *         required: true
 *         schema: { type: string, example: "cmmessage12345" }
 *     responses:
 *       200:
 *         description: ทำเครื่องหมายอ่านสำเร็จ
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success: { type: boolean, example: true }
 *                 message: { type: string }
 *                 data:
 *                   type: object
 *                   properties:
 *                     id: { type: string }
 *                     bookingId: { type: string }
 *                     senderRole: { type: string }
 *                     content: { type: string }
 *                     readAt: { type: string, format: date-time }
 *                     createdAt: { type: string, format: date-time }
 *       400:
 *         description: ไม่สามารถทำเครื่องหมายอ่านข้อความที่ตัวเองส่ง
 *       403:
 *         description: ไม่มีสิทธิ์เข้าถึงการจองนี้
 *       404:
 *         description: ไม่พบการจองหรือข้อความ
 */

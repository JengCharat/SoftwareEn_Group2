const { Router } = require('express');
const {
  getMyEmergencyContacts,
  createEmergencyContact,
  updateEmergencyContact,
  deleteEmergencyContact,
  adminGetAllEmergencyContacts,
  adminGetContactsByUser,
  adminDeleteEmergencyContact,
} = require('../controllers/emergencyContact.controller');
const { protect, requireAdmin } = require('../middlewares/auth');


const router = Router();
//User Route (ต้อง Login)
/**
 * @swagger
 * /api/emergency-contacts:
 *   get:
 *     summary: List all emergency contacts for the current user
 *     tags: [EmergencyContacts]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of emergency contacts
 *       401:
 *         description: Unauthorized
 */
router.get('/', protect, getMyEmergencyContacts);

/**
 * @swagger
 * /api/emergency-contacts:
 *   post:
 *     summary: Create a new emergency contact
 *     tags: [EmergencyContacts]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - name
 *               - phone
 *             properties:
 *               name:
 *                 type: string
 *                 example: "พ่อ"
 *               phone:
 *                 type: string
 *                 example: "081-234-5678"
 *     responses:
 *       201:
 *         description: Contact created successfully
 *       400:
 *         description: Validation error
 *       401:
 *         description: Unauthorized
 */
router.post('/', protect, createEmergencyContact);

/**
 * @swagger
 * /api/emergency-contacts/{id}:
 *   put:
 *     summary: Update an emergency contact
 *     tags: [EmergencyContacts]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *               phone:
 *                 type: string
 *     responses:
 *       200:
 *         description: Contact updated successfully
 *       403:
 *         description: Forbidden
 *       404:
 *         description: Contact not found
 */
router.put('/:id', protect, updateEmergencyContact);

/**
 * @swagger
 * /api/emergency-contacts/{id}:
 *   delete:
 *     summary: Delete an emergency contact
 *     tags: [EmergencyContacts]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Contact deleted successfully
 *       403:
 *         description: Forbidden
 *       404:
 *         description: Contact not found
 */
router.delete('/:id', protect, deleteEmergencyContact);

//Admin Route
/**
 * @swagger
 * /api/emergency-contacts/admin:
 *   get:
 *     summary: List all emergency contacts in the system (Admin only)
 *     tags: [EmergencyContacts]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of all emergency contacts
 *       403:
 *         description: Forbidden
 */
router.get('/admin', protect, requireAdmin, adminGetAllEmergencyContacts);

/**
 * @swagger
 * /api/emergency-contacts/admin/user/{userId}:
 *   get:
 *     summary: List all emergency contacts for a specific user (Admin only)
 *     tags: [EmergencyContacts]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: userId
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: List of emergency contacts for the user
 *       404:
 *         description: User not found
 */
router.get('/admin/user/:userId', protect, requireAdmin, adminGetContactsByUser);

/**
 * @swagger
 * /api/emergency-contacts/admin/{id}:
 *   delete:
 *     summary: Delete any emergency contact (Admin only)
 *     tags: [EmergencyContacts]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Contact deleted successfully
 *       404:
 *         description: Contact not found
 */
router.delete('/admin/:id', protect, requireAdmin, adminDeleteEmergencyContact);

module.exports = router;
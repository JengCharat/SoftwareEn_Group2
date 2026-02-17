const { z } = require("zod");
const prisma = require("../utils/prisma");

const createEmergencyContactSchema = z.object({
  name: z
    .string({ required_error: "Name is required" })
    .min(1, "Name cannot be empty")
    .max(100, "Name must be at most 100 characters"),
  phone: z
    .string({ required_error: "Phone number is required" })
    .min(1, "Phone number cannot be empty")
    .max(20, "Phone number must be at most 20 characters"),
});

const updateEmergencyContactSchema = z.object({
  name: z
    .string()
    .min(1, "Name cannot be empty")
    .max(100, "Name must be at most 100 characters")
    .optional(),
  phone: z
    .string()
    .min(1, "Phone number cannot be empty")
    .max(20, "Phone number must be at most 20 characters")
    .optional(),
});

//User Controller
/**
 * GET /api/emergency-contacts
 * List all emergency contacts for the current logged-in user.
 */
const getMyEmergencyContacts = async (req, res) => {
  try {
    const userId = req.user.sub;

    const contacts = await prisma.emergencyContact.findMany({
      where: { userId },
      orderBy: { createdAt: "asc" },
    });

    return res.status(200).json({
      success: true,
      data: contacts,
    });
  } catch (error) {
    console.error("getMyEmergencyContacts error:", error);
    return res.status(500).json({
      success: false,
      message: "Internal server error",
    });
  }
};

/**
 * POST /api/emergency-contacts
 * Create a new emergency contact for the current logged-in user.
 */
const createEmergencyContact = async (req, res) => {
  try {
    const userId = req.user.sub;

    const parsed = createEmergencyContactSchema.safeParse(req.body);
    if (!parsed.success) {
      return res.status(400).json({
        success: false,
        message: "Validation error",
        errors: parsed.error.errors,
      });
    }

    const { name, phone } = parsed.data;

    const contact = await prisma.emergencyContact.create({
      data: { userId, name, phone },
    });

    return res.status(201).json({
      success: true,
      message: "Emergency contact created successfully",
      data: contact,
    });
  } catch (error) {
    console.error("createEmergencyContact error:", error);
    return res.status(500).json({
      success: false,
      message: "Internal server error",
    });
  }
};

/**
 * PUT /api/emergency-contacts/:id
 * Update an emergency contact belonging to the current logged-in user.
 */
const updateEmergencyContact = async (req, res) => {
  try {
    const userId = req.user.sub;
    const contactId = req.params.id;

    const parsed = updateEmergencyContactSchema.safeParse(req.body);
    if (!parsed.success) {
      return res.status(400).json({
        success: false,
        message: "Validation error",
        errors: parsed.error.errors,
      });
    }

    const existing = await prisma.emergencyContact.findUnique({
      where: { id: contactId },
    });

    if (!existing) {
      return res.status(404).json({
        success: false,
        message: "Emergency contact not found",
      });
    }

    if (existing.userId !== userId) {
      return res.status(403).json({
        success: false,
        message: "You do not have permission to update this contact",
      });
    }

    const updated = await prisma.emergencyContact.update({
      where: { id: contactId },
      data: parsed.data,
    });

    return res.status(200).json({
      success: true,
      message: "Emergency contact updated successfully",
      data: updated,
    });
  } catch (error) {
    console.error("updateEmergencyContact error:", error);
    return res.status(500).json({
      success: false,
      message: "Internal server error",
    });
  }
};

/**
 * DELETE /api/emergency-contacts/:id
 * Delete an emergency contact belonging to the current logged-in user.
 */
const deleteEmergencyContact = async (req, res) => {
  try {
    const userId = req.user.sub;
    const contactId = req.params.id;

    const existing = await prisma.emergencyContact.findUnique({
      where: { id: contactId },
    });

    if (!existing) {
      return res.status(404).json({
        success: false,
        message: "Emergency contact not found",
      });
    }

    if (existing.userId !== userId) {
      return res.status(403).json({
        success: false,
        message: "You do not have permission to delete this contact",
      });
    }

    await prisma.emergencyContact.delete({
      where: { id: contactId },
    });

    return res.status(200).json({
      success: true,
      message: "Emergency contact deleted successfully",
    });
  } catch (error) {
    console.error("deleteEmergencyContact error:", error);
    return res.status(500).json({
      success: false,
      message: "Internal server error",
    });
  }
};

//Admin Controller
/**
 * GET /api/emergency-contacts/admin
 * List all emergency contacts in the system (Admin only).
 */
const adminGetAllEmergencyContacts = async (req, res) => {
  try {
    const contacts = await prisma.emergencyContact.findMany({
      orderBy: { createdAt: "desc" },
      include: {
        user: {
          select: { id: true, username: true, email: true },
        },
      },
    });

    return res.status(200).json({
      success: true,
      data: contacts,
    });
  } catch (error) {
    console.error("adminGetAllEmergencyContacts error:", error);
    return res.status(500).json({
      success: false,
      message: "Internal server error",
    });
  }
};

/**
 * GET /api/emergency-contacts/admin/user/:userId
 * List all emergency contacts for a specific user (Admin only).
 */
const adminGetContactsByUser = async (req, res) => {
  try {
    const targetUserId = req.params.userId;

    const userExists = await prisma.user.findUnique({
      where: { id: targetUserId },
    });

    if (!userExists) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    const contacts = await prisma.emergencyContact.findMany({
      where: { userId: targetUserId },
      orderBy: { createdAt: "asc" },
    });

    return res.status(200).json({
      success: true,
      data: contacts,
    });
  } catch (error) {
    console.error("adminGetContactsByUser error:", error);
    return res.status(500).json({
      success: false,
      message: "Internal server error",
    });
  }
};

/**
 * DELETE /api/emergency-contacts/admin/:id
 * Delete any emergency contact (Admin only).
 */
const adminDeleteEmergencyContact = async (req, res) => {
  try {
    const contactId = req.params.id;

    const existing = await prisma.emergencyContact.findUnique({
      where: { id: contactId },
    });

    if (!existing) {
      return res.status(404).json({
        success: false,
        message: "Emergency contact not found",
      });
    }

    await prisma.emergencyContact.delete({
      where: { id: contactId },
    });

    return res.status(200).json({
      success: true,
      message: "Emergency contact deleted successfully",
    });
  } catch (error) {
    console.error("adminDeleteEmergencyContact error:", error);
    return res.status(500).json({
      success: false,
      message: "Internal server error",
    });
  }
};

module.exports = {
  getMyEmergencyContacts,
  createEmergencyContact,
  updateEmergencyContact,
  deleteEmergencyContact,
  adminGetAllEmergencyContacts,
  adminGetContactsByUser,
  adminDeleteEmergencyContact,
};


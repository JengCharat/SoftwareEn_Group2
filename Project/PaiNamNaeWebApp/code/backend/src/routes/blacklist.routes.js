const express = require("express");
const blacklistController = require("../controllers/blacklist.controller");

const { protect, requireAdmin } = require("../middlewares/auth");
const router = express.Router();

// DELETE /api/blacklist/:id
router.delete(
  "/:id",
  protect,
  requireAdmin,
  blacklistController.deleteBlacklist,
);
module.exports = router;

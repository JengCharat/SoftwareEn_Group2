const asyncHandler = require("express-async-handler");
const blacklistService = require("../services/blacklist.service");

exports.deleteBlacklist = asyncHandler(async (req, res) => {
  const { id } = req.params;

  await blacklistService.deleteBlacklist(id);

  res.status(200).json({
    success: true,
    message: "Blacklist removed successfully",
  });
});

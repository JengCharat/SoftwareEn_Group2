const prisma = require("../utils/prisma.js");
const ApiError = require("../utils/ApiError.js");

const checkUserAccess = async (userId) => {
  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: {
      id: true,
      nationalIdNumber: true,
    },
  });

  if (!user) {
    throw new ApiError(404, "User not found");
  }

  if (!user.nationalIdNumber) return;

  const blacklist = await prisma.blacklist.findFirst({
    where: {
      nationalIdNumber: user.nationalIdNumber,
    },
  });

  if (!blacklist) return;

  const now = new Date();

  if (!blacklist.expiresAt || blacklist.expiresAt > now) {
    throw new ApiError(403, "Your account has been suspended.");
  }

  await prisma.user.update({
    where: { id: user.id },
    data: { isActive: true },
  });

  await prisma.blacklist.delete({
    where: { id: blacklist.id },
  });
};

const deleteBlacklist = async (id) => {
  const blacklist = await prisma.blacklist.findUnique({
    where: { id },
  });

  if (!blacklist) {
    throw new ApiError(404, "Blacklist not found");
  }

  await prisma.blacklist.delete({
    where: { id },
  });

  await prisma.user.updateMany({
    where: { nationalIdNumber: blacklist.nationalIdNumber },
    data: { isActive: true },
  });
};

module.exports = {
  checkUserAccess,
  deleteBlacklist,
};

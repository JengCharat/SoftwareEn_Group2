import prisma from "../utils/prisma.js";
import ApiError from "../utils/ApiError.js";

export const checkUserAccess = async (userId) => {
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
  console.log("===== BLACKLIST CHECK =====");
  console.log("now:", now);
  console.log("now ISO:", now.toISOString());

  console.log("expireAt:", blacklist.expiresAt);
  console.log(
    "expireAt ISO:",
    blacklist.expiresAt ? blacklist.expiresAt.toISOString() : null,
  );

  console.log(
    "isExpired:",
    blacklist.expiresAt ? blacklist.expiresAt < now : "no expire",
  );

  console.log("===========================");

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

export const deleteBlacklist = async (id) => {
  const blacklist = await prisma.blacklist.findUnique({
    where: { id },
  });

  if (!blacklist) {
    throw new ApiError(404, "Blacklist not found");
  }

  await prisma.blacklist.delete({
    where: { id },
  });

  // reactivate user
  await prisma.user.updateMany({
    where: { nationalIdNumber: blacklist.nationalIdNumber },
    data: { isActive: true },
  });
};

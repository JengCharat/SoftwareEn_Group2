const prisma = require("../utils/prisma");

const getAllLog = async () => {
  const logs = await prisma.activityLog.findMany({
    orderBy: { createdAt: "desc" },
    include: {
      user: {
        select: {
          id: true,
          email: true,
          username: true,
        },
      },
    },
  });

  return logs;
};

module.exports = {
  getAllLog,
};

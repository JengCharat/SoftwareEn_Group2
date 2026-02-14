const prisma = require("../utils/prisma");

const getAllLog = async () => {
  const logs = await prisma.activityLog.findMany({
    orderBy: {
      createdAt: "desc",
    },
  });

  return logs;
};

module.exports = {
  getAllLog,
};

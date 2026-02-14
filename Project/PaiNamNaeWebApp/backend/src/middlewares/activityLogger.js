import prisma from "../utils/prisma.js";

export const activityLogger = (req, res, next) => {
  res.on("finish", async () => {
    try {
      await prisma.activityLog.create({
        data: {
          userId: req.user?.sub || null,
          method: req.method,
          endpoint: req.originalUrl,
          statusCode: res.statusCode,
          ipAddress: req.ip,
          userAgent: req.headers["user-agent"],
        },
      });
    } catch (err) {
      console.error("Activity log error:", err);
    }
  });

  next();
};

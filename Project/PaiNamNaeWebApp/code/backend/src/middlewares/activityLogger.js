import prisma from "../utils/prisma.js";
import { UAParser } from "ua-parser-js";

export const activityLogger = (req, res, next) => {
  const startTime = Date.now();

  res.on("finish", async () => {
    try {
      const userAgent = req.headers["user-agent"] || "";
      const parser = new UAParser(userAgent);
      const ua = parser.getResult();

      const duration = Date.now() - startTime;

      await prisma.activityLog.create({
        data: {
          userId: req.user?.sub || null,
          method: req.method,
          endpoint: req.originalUrl,
          statusCode: res.statusCode,

          ipAddress: req.ip,
          userAgent: userAgent,
        },
      });
    } catch (err) {
      console.error("Activity log error:", err);
    }
  });

  next();
};

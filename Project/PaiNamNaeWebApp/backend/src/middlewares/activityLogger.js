import prisma from "../utils/prisma.js";
import { UAParser } from "ua-parser-js";

export const activityLogger = (req, res, next) => {
  res.on("finish", async () => {
    try {
      const userAgent = req.headers["user-agent"] || "";

      const parser = new UAParser(userAgent);
      const result = parser.getResult();

      await prisma.activityLog.create({
        data: {
          userId: req.user?.sub || null,
          method: req.method,
          endpoint: req.originalUrl,
          statusCode: res.statusCode,
          ipAddress: req.ip,
          userAgent: userAgent,

          deviceType: result.device.type || "desktop",
          os: result.os.name || null,
          browser: result.browser.name || null,
        },
      });
    } catch (err) {
      console.error("Activity log error:", err);
    }
  });

  next();
};

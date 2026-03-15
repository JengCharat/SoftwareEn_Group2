-- AlterTable
ALTER TABLE "ActivityLog" ADD COLUMN     "browserVersion" TEXT,
ADD COLUMN     "contentLength" INTEGER,
ADD COLUMN     "deviceModel" TEXT,
ADD COLUMN     "deviceVendor" TEXT,
ADD COLUMN     "engine" TEXT,
ADD COLUMN     "engineVersion" TEXT,
ADD COLUMN     "osVersion" TEXT,
ADD COLUMN     "referer" TEXT,
ADD COLUMN     "responseTimeMs" INTEGER;

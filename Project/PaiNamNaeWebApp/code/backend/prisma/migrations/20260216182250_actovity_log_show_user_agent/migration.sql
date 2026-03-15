/*
  Warnings:

  - You are about to drop the column `browser` on the `ActivityLog` table. All the data in the column will be lost.
  - You are about to drop the column `browserVersion` on the `ActivityLog` table. All the data in the column will be lost.
  - You are about to drop the column `contentLength` on the `ActivityLog` table. All the data in the column will be lost.
  - You are about to drop the column `deviceModel` on the `ActivityLog` table. All the data in the column will be lost.
  - You are about to drop the column `deviceType` on the `ActivityLog` table. All the data in the column will be lost.
  - You are about to drop the column `deviceVendor` on the `ActivityLog` table. All the data in the column will be lost.
  - You are about to drop the column `engine` on the `ActivityLog` table. All the data in the column will be lost.
  - You are about to drop the column `engineVersion` on the `ActivityLog` table. All the data in the column will be lost.
  - You are about to drop the column `os` on the `ActivityLog` table. All the data in the column will be lost.
  - You are about to drop the column `osVersion` on the `ActivityLog` table. All the data in the column will be lost.
  - You are about to drop the column `referer` on the `ActivityLog` table. All the data in the column will be lost.
  - You are about to drop the column `responseTimeMs` on the `ActivityLog` table. All the data in the column will be lost.

*/
-- AlterTable
ALTER TABLE "ActivityLog" DROP COLUMN "browser",
DROP COLUMN "browserVersion",
DROP COLUMN "contentLength",
DROP COLUMN "deviceModel",
DROP COLUMN "deviceType",
DROP COLUMN "deviceVendor",
DROP COLUMN "engine",
DROP COLUMN "engineVersion",
DROP COLUMN "os",
DROP COLUMN "osVersion",
DROP COLUMN "referer",
DROP COLUMN "responseTimeMs";

-- CreateTable
CREATE TABLE "Blacklist" (
    "id" TEXT NOT NULL,
    "nationalIdNumber" TEXT NOT NULL,
    "userId" TEXT,
    "reason" TEXT,
    "addedByAdmin" TEXT,
    "expiresAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Blacklist_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Blacklist_nationalIdNumber_key" ON "Blacklist"("nationalIdNumber");

-- CreateIndex
CREATE INDEX "Blacklist_userId_idx" ON "Blacklist"("userId");

-- AddForeignKey
ALTER TABLE "Blacklist" ADD CONSTRAINT "Blacklist_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

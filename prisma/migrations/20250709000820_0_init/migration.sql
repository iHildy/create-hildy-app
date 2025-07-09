-- CreateTable
CREATE TABLE "TestTable" (
    "id" TEXT NOT NULL DEFAULT concat('test_', gen_random_uuid()),
    "name" TEXT NOT NULL,
    "description" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "TestTable_pkey" PRIMARY KEY ("id")
);

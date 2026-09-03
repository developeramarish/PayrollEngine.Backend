CREATE OR REPLACE FUNCTION GetDerivedPayrollRegulations(
    IN "tenantId" INTEGER, IN "payrollId" INTEGER,
    IN "regulationDate" TIMESTAMP(6), IN "createdBefore" TIMESTAMP(6)
)
RETURNS TABLE(
    "Id" INT, "Status" INT, "Created" TIMESTAMPTZ, "Updated" TIMESTAMPTZ,
    "Name" TEXT, "NameLocalizations" TEXT,
    "ValidFrom" TIMESTAMP, "Owner" TEXT, "SharedRegulation" BOOLEAN,
    "TenantId" INT, "Attributes" TEXT,
    "Level" INT, "Priority" INT
)
LANGUAGE sql STABLE AS $$
        WITH DerivedRegulations AS (
        SELECT r."Id", pl."Level", pl."Priority",
            ROW_NUMBER() OVER (PARTITION BY pl."Id", r."Name" ORDER BY r."ValidFrom" DESC, r."Created" DESC) AS "RowNumber"
        FROM "PayrollLayer" pl
        INNER JOIN "Regulation" r ON pl."RegulationName" = r."Name"
        WHERE r."Status" = 0
          AND (r."TenantId" = "tenantId"
            OR (r."SharedRegulation" = true
              AND EXISTS (SELECT 1 FROM "RegulationShare" rs WHERE rs."ProviderRegulationId" = r."Id" AND rs."ConsumerTenantId" = "tenantId" AND rs."IsolationLevel" >= 3)))
          AND r."Created" <= "createdBefore"
          AND (r."ValidFrom" IS NULL OR r."ValidFrom" <= "regulationDate")
          AND pl."Status" = 0 AND pl."PayrollId" = "payrollId"
    ),
    Regulations AS (SELECT "Id", "Level", "Priority" FROM DerivedRegulations WHERE "RowNumber" = 1)
    SELECT r."Id", r."Status", r."Created", r."Updated",
        r."Name", r."NameLocalizations",
        r."ValidFrom", r."Owner", r."SharedRegulation",
        r."TenantId", r."Attributes",
        reg."Level", reg."Priority"
    FROM "Regulation" r
    INNER JOIN Regulations reg ON r."Id" = reg."Id"
    ORDER BY reg."Level" DESC, reg."Priority" DESC;
$$;

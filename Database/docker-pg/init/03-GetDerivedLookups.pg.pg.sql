-- =============================================================================
-- GetDerivedLookups
-- =============================================================================

CREATE OR REPLACE FUNCTION GetDerivedLookups(
    IN "tenantId" INTEGER, IN "payrollId" INTEGER,
    IN "regulationDate" TIMESTAMP(6), IN "createdBefore" TIMESTAMP(6),
    IN "lookupNames" TEXT
)
RETURNS TABLE(
    "RegulationId" INT, "Level" INT, "Priority" INT,
    "Id" INT, "Status" INT, "Created" TIMESTAMPTZ, "Updated" TIMESTAMPTZ, "LkRegulationId" INT,
    "Name" TEXT, "NameLocalizations" TEXT, "Description" TEXT, "DescriptionLocalizations" TEXT,
    "OverrideType" INT, "RangeSize" NUMERIC, "Attributes" TEXT, "RangeMode" INT
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
    SELECT
        reg."Id" AS "RegulationId", reg."Level", reg."Priority",
        lk."Id", lk."Status", lk."Created", lk."Updated", lk."RegulationId" AS "LkRegulationId",
        lk."Name", lk."NameLocalizations", lk."Description", lk."DescriptionLocalizations",
        lk."OverrideType", lk."RangeSize", lk."Attributes", lk."RangeMode"
    FROM "Lookup" lk
    INNER JOIN Regulations reg ON lk."RegulationId" = reg."Id"
    WHERE lk."Status" = 0
      AND lk."Created" <= "createdBefore"
      AND ("lookupNames" IS NULL
           OR LOWER(lk."Name") IN (
               SELECT LOWER(jt.val)
               FROM jsonb_array_elements_text("lookupNames"::jsonb) AS jt(val)))
    ORDER BY reg."Level" DESC, reg."Priority" DESC;
$$;

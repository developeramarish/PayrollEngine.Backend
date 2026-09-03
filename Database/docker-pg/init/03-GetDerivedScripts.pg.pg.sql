-- =============================================================================
-- GetDerivedScripts
-- OverrideType excluded from SELECT (matches T-SQL explicit column list)
-- =============================================================================

CREATE OR REPLACE FUNCTION GetDerivedScripts(
    IN "tenantId" INTEGER, IN "payrollId" INTEGER,
    IN "regulationDate" TIMESTAMP(6), IN "createdBefore" TIMESTAMP(6),
    IN "scriptNames" TEXT
)
RETURNS TABLE(
    "RegulationId" INT, "Level" INT, "Priority" INT,
    "Id" INT, "Status" INT, "Created" TIMESTAMPTZ, "Updated" TIMESTAMPTZ, "ScRegulationId" INT,
    "Name" TEXT, "FunctionTypeMask" BIGINT, "Value" TEXT
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
        s."Id", s."Status", s."Created", s."Updated", s."RegulationId" AS "ScRegulationId",
        s."Name", s."FunctionTypeMask", s."Value"
    FROM "Script" s
    INNER JOIN Regulations reg ON s."RegulationId" = reg."Id"
    WHERE s."Status" = 0
      AND s."Created" <= "createdBefore"
      AND ("scriptNames" IS NULL
           OR LOWER(s."Name") IN (
               SELECT LOWER(jt.val)
               FROM jsonb_array_elements_text("scriptNames"::jsonb) AS jt(val)))
    ORDER BY reg."Level" DESC, reg."Priority" DESC;
$$;

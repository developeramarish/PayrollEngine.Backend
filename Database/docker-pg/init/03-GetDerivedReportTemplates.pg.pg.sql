-- =============================================================================
-- GetDerivedReportTemplates
-- rt."Schema" double-quoted (reserved keyword in PG)
-- =============================================================================

CREATE OR REPLACE FUNCTION GetDerivedReportTemplates(
    IN "tenantId" INTEGER, IN "payrollId" INTEGER,
    IN "regulationDate" TIMESTAMP(6), IN "createdBefore" TIMESTAMP(6),
    IN "reportNames" TEXT, IN "culture" TEXT
)
RETURNS TABLE(
    "RegulationId" INT, "Level" INT, "Priority" INT,
    "Id" INT, "Status" INT, "Created" TIMESTAMPTZ, "Updated" TIMESTAMPTZ, "ReportId" INT,
    "Name" TEXT, "Culture" TEXT, "Content" TEXT, "ContentType" TEXT,
    "Schema" TEXT, "Resource" TEXT, "OverrideType" INT, "Attributes" TEXT
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
        rt."Id", rt."Status", rt."Created", rt."Updated", rt."ReportId",
        rt."Name", rt."Culture", rt."Content", rt."ContentType",
        rt."Schema", rt."Resource", rt."OverrideType", rt."Attributes"
    FROM "ReportTemplate" rt
    INNER JOIN "Report" rp ON rt."ReportId" = rp."Id"
    INNER JOIN Regulations reg ON rp."RegulationId" = reg."Id"
    WHERE rt."Status" = 0
      AND rt."Created" <= "createdBefore"
      AND ("reportNames" IS NULL
           OR LOWER(rp."Name") IN (
               SELECT LOWER(jt.val)
               FROM jsonb_array_elements_text("reportNames"::jsonb) AS jt(val)))
      AND ("culture" IS NULL OR rt."Culture" = "culture")
    ORDER BY reg."Level" DESC, reg."Priority" DESC;
$$;

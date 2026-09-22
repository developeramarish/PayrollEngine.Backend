-- =============================================================================
-- GetDerivedReportParameters
-- =============================================================================

CREATE OR REPLACE FUNCTION GetDerivedReportParameters(
    IN "tenantId" INTEGER, IN "payrollId" INTEGER,
    IN "regulationDate" TIMESTAMP(6), IN "createdBefore" TIMESTAMP(6),
    IN "reportNames" TEXT
)
RETURNS TABLE(
    "RegulationId" INT, "Level" INT, "Priority" INT,
    "Id" INT, "Status" INT, "Created" TIMESTAMPTZ, "Updated" TIMESTAMPTZ, "ReportId" INT,
    "Name" TEXT, "NameLocalizations" TEXT, "Description" TEXT, "DescriptionLocalizations" TEXT,
    "Mandatory" BOOLEAN, "Hidden" BOOLEAN, "Value" TEXT, "ValueType" INT, "ParameterType" INT,
    "OverrideType" INT, "Attributes" TEXT
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
              AND EXISTS (SELECT 1 FROM "RegulationShare" rs
                          INNER JOIN "Regulation" rp ON rs."ProviderRegulationId" = rp."Id"
                          WHERE rp."Name" = r."Name" AND rs."ConsumerTenantId" = "tenantId" AND rs."IsolationLevel" >= 3)))
          AND r."Created" <= "createdBefore"
          AND (r."ValidFrom" IS NULL OR r."ValidFrom" <= "regulationDate")
          AND pl."Status" = 0 AND pl."PayrollId" = "payrollId"
    ),
    Regulations AS (SELECT "Id", "Level", "Priority" FROM DerivedRegulations WHERE "RowNumber" = 1)
    SELECT
        reg."Id" AS "RegulationId", reg."Level", reg."Priority",
        rpar."Id", rpar."Status", rpar."Created", rpar."Updated", rpar."ReportId",
        rpar."Name", rpar."NameLocalizations", rpar."Description", rpar."DescriptionLocalizations",
        rpar."Mandatory", rpar."Hidden", rpar."Value", rpar."ValueType", rpar."ParameterType",
        rpar."OverrideType", rpar."Attributes"
    FROM "ReportParameter" rpar
    INNER JOIN "Report" rp ON rpar."ReportId" = rp."Id"
    INNER JOIN Regulations reg ON rp."RegulationId" = reg."Id"
    WHERE rpar."Status" = 0
      AND rpar."Created" <= "createdBefore"
      AND ("reportNames" IS NULL
           OR LOWER(rp."Name") IN (
               SELECT LOWER(jt.val)
               FROM jsonb_array_elements_text("reportNames"::jsonb) AS jt(val)))
    ORDER BY reg."Level" DESC, reg."Priority" DESC;
$$;

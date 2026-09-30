-- =============================================================================
-- GetDerivedCaseFieldsOfCase
-- Filtered by case names (not field names).
-- =============================================================================

CREATE OR REPLACE FUNCTION GetDerivedCaseFieldsOfCase(
    IN "tenantId" INTEGER, IN "payrollId" INTEGER,
    IN "regulationDate" TIMESTAMP(6), IN "createdBefore" TIMESTAMP(6),
    IN "caseNames" TEXT, IN "includeClusters" TEXT, IN "excludeClusters" TEXT
)
RETURNS TABLE(
    "RegulationId" INT, "Level" INT, "Priority" INT,
    "CaseId" INT, "CaseType" INT,
    "Id" INT, "Status" INT, "Created" TIMESTAMPTZ, "Updated" TIMESTAMPTZ,
    "Name" TEXT, "NameLocalizations" TEXT, "Description" TEXT, "DescriptionLocalizations" TEXT,
    "ValueType" INT, "ValueScope" INT, "StartDateType" INT, "EndDateType" INT,
    "EndMandatory" BOOLEAN, "DefaultStart" TEXT, "DefaultEnd" TEXT, "DefaultValue" TEXT,
    "LookupSettings" TEXT, "TimeType" INT, "TimeUnit" INT, "Culture" TEXT,
    "PeriodAggregation" INT, "OverrideType" INT, "CancellationMode" INT, "ValueCreationMode" INT,
    "ValueMandatory" BOOLEAN, "Order" INT, "Tags" TEXT, "Clusters" TEXT, "Attributes" TEXT, "ValueAttributes" TEXT
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
        cf."CaseId", c."CaseType",
        cf."Id", cf."Status", cf."Created", cf."Updated",
        cf."Name", cf."NameLocalizations", cf."Description", cf."DescriptionLocalizations",
        cf."ValueType", cf."ValueScope", cf."StartDateType", cf."EndDateType",
        cf."EndMandatory", cf."DefaultStart", cf."DefaultEnd", cf."DefaultValue",
        cf."LookupSettings", cf."TimeType", cf."TimeUnit", cf."Culture",
        cf."PeriodAggregation", cf."OverrideType", cf."CancellationMode", cf."ValueCreationMode",
        cf."ValueMandatory", cf."Order", cf."Tags", cf."Clusters", cf."Attributes", cf."ValueAttributes"
    FROM "CaseField" cf
    INNER JOIN "Case" c ON cf."CaseId" = c."Id"
    INNER JOIN Regulations reg ON c."RegulationId" = reg."Id"
    WHERE cf."Status" = 0
      AND cf."Created" <= "createdBefore"
      AND (("includeClusters" IS NULL AND "excludeClusters" IS NULL)
           OR IsMatchingCluster("includeClusters", "excludeClusters", cf."Clusters") = 1)
      AND ("caseNames" IS NULL
           OR LOWER(c."Name") IN (
               SELECT LOWER(jt.val)
               FROM jsonb_array_elements_text("caseNames"::jsonb) AS jt(val)))
    ORDER BY reg."Level" DESC, reg."Priority" DESC;
$$;

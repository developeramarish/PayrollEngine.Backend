-- =============================================================================
-- GetDerivedLookupValues
-- lv."Key" double-quoted (reserved keyword in PG)
-- Case-sensitive key filter (no LOWER(), identical to T-SQL)
-- =============================================================================

CREATE OR REPLACE FUNCTION GetDerivedLookupValues(
    IN "tenantId" INTEGER, IN "payrollId" INTEGER,
    IN "regulationDate" TIMESTAMP(6), IN "createdBefore" TIMESTAMP(6),
    IN "lookupNames" TEXT, IN "lookupKeys" TEXT
)
RETURNS TABLE(
    "RegulationId" INT, "Level" INT, "Priority" INT,
    "Id" INT, "Status" INT, "Created" TIMESTAMPTZ, "Updated" TIMESTAMPTZ, "LookupId" INT,
    "Key" TEXT, "KeyHash" INT, "RangeValue" NUMERIC, "Value" TEXT, "ValueLocalizations" TEXT,
    "OverrideType" INT, "LookupHash" INT
)
LANGUAGE sql STABLE AS $$
    WITH DerivedRegulations AS (
        SELECT r."Id", pl."Level", pl."Priority",
            ROW_NUMBER() OVER (PARTITION BY pl."Id", r."Name" ORDER BY r."ValidFrom" DESC NULLS LAST, r."Created" DESC) AS "RowNumber"
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
        lv."Id", lv."Status", lv."Created", lv."Updated", lv."LookupId",
        lv."Key", lv."KeyHash", lv."RangeValue", lv."Value", lv."ValueLocalizations",
        lv."OverrideType", lv."LookupHash"
    FROM "LookupValue" lv
    INNER JOIN "Lookup" lk ON lv."LookupId" = lk."Id"
    INNER JOIN Regulations reg ON lk."RegulationId" = reg."Id"
    WHERE lv."Status" = 0
      AND lv."Created" <= "createdBefore"
      AND ("lookupNames" IS NULL
           OR LOWER(lk."Name") IN (
               SELECT LOWER(jt.val)
               FROM jsonb_array_elements_text("lookupNames"::jsonb) AS jt(val)))
      AND ("lookupKeys" IS NULL
           OR lv."Key" IN (
               SELECT jt.val
               FROM jsonb_array_elements_text("lookupKeys"::jsonb) AS jt(val)))
    ORDER BY reg."Level" DESC, reg."Priority" DESC;
$$;

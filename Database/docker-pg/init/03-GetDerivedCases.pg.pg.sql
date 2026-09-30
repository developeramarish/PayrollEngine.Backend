-- =============================================================================
-- GetDerivedCases
-- Excludes Binary, Script, ScriptVersion, Hidden (performance hint identical to T-SQL)
-- =============================================================================

CREATE OR REPLACE FUNCTION GetDerivedCases(
    IN "tenantId" INTEGER, IN "payrollId" INTEGER,
    IN "regulationDate" TIMESTAMP(6), IN "createdBefore" TIMESTAMP(6),
    IN "caseType" INTEGER, IN "caseNames" TEXT,
    IN "includeClusters" TEXT, IN "excludeClusters" TEXT, IN "hidden" BOOLEAN
)
RETURNS TABLE(
    "RegulationId" INT, "Level" INT, "Priority" INT,
    "Id" INT, "Status" INT, "Created" TIMESTAMPTZ, "Updated" TIMESTAMPTZ, "CsRegulationId" INT,
    "CaseType" INT, "Name" TEXT, "NameLocalizations" TEXT, "NameSynonyms" TEXT,
    "Description" TEXT, "DescriptionLocalizations" TEXT,
    "DefaultReason" TEXT, "DefaultReasonLocalizations" TEXT,
    "BaseCase" TEXT, "BaseCaseFields" TEXT,
    "OverrideType" INT, "CancellationType" INT,
    "AvailableExpression" TEXT, "BuildExpression" TEXT, "ValidateExpression" TEXT,
    "Lookups" TEXT, "Slots" TEXT,
    "ScriptHash" INT, "Attributes" TEXT, "Clusters" TEXT,
    "AvailableActions" TEXT, "BuildActions" TEXT, "ValidateActions" TEXT
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
        c."Id", c."Status", c."Created", c."Updated", c."RegulationId" AS "CsRegulationId",
        c."CaseType", c."Name", c."NameLocalizations", c."NameSynonyms",
        c."Description", c."DescriptionLocalizations",
        c."DefaultReason", c."DefaultReasonLocalizations",
        c."BaseCase", c."BaseCaseFields",
        c."OverrideType", c."CancellationType",
        c."AvailableExpression", c."BuildExpression", c."ValidateExpression",
        c."Lookups", c."Slots",
        c."ScriptHash", c."Attributes", c."Clusters",
        c."AvailableActions", c."BuildActions", c."ValidateActions"
    FROM "Case" c
    INNER JOIN Regulations reg ON c."RegulationId" = reg."Id"
    WHERE c."Status" = 0
      AND c."Created" <= "createdBefore"
      AND ("hidden" IS NULL OR c."Hidden" = "hidden")
      AND ("caseType" IS NULL OR c."CaseType" = "caseType")
      AND (("includeClusters" IS NULL AND "excludeClusters" IS NULL)
           OR IsMatchingCluster("includeClusters", "excludeClusters", c."Clusters") = 1)
      AND ("caseNames" IS NULL
           OR LOWER(c."Name") IN (
               SELECT LOWER(jt.val)
               FROM jsonb_array_elements_text("caseNames"::jsonb) AS jt(val)))
    ORDER BY reg."Level" DESC, reg."Priority" DESC;
$$;

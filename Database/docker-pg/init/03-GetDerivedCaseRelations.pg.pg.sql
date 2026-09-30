-- =============================================================================
-- GetDerivedCaseRelations
-- cr."Order" double-quoted (reserved keyword in PG)
-- Excludes Binary, Script, ScriptVersion (performance hint)
-- =============================================================================

CREATE OR REPLACE FUNCTION GetDerivedCaseRelations(
    IN "tenantId" INTEGER, IN "payrollId" INTEGER,
    IN "regulationDate" TIMESTAMP(6), IN "createdBefore" TIMESTAMP(6),
    IN "sourceCaseName" TEXT, IN "targetCaseName" TEXT,
    IN "includeClusters" TEXT, IN "excludeClusters" TEXT
)
RETURNS TABLE(
    "RegulationId" INT, "Level" INT, "Priority" INT,
    "Id" INT, "Status" INT, "Created" TIMESTAMPTZ, "Updated" TIMESTAMPTZ, "CrRegulationId" INT,
    "SourceCaseName" TEXT, "SourceCaseNameLocalizations" TEXT,
    "SourceCaseSlot" TEXT, "SourceCaseSlotLocalizations" TEXT,
    "TargetCaseName" TEXT, "TargetCaseNameLocalizations" TEXT,
    "TargetCaseSlot" TEXT, "TargetCaseSlotLocalizations" TEXT,
    "RelationHash" INT, "BuildExpression" TEXT, "ValidateExpression" TEXT,
    "OverrideType" INT, "Order" INT,
    "ScriptHash" INT, "Attributes" TEXT, "Clusters" TEXT,
    "BuildActions" TEXT, "ValidateActions" TEXT
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
        cr."Id", cr."Status", cr."Created", cr."Updated", cr."RegulationId" AS "CrRegulationId",
        cr."SourceCaseName", cr."SourceCaseNameLocalizations",
        cr."SourceCaseSlot", cr."SourceCaseSlotLocalizations",
        cr."TargetCaseName", cr."TargetCaseNameLocalizations",
        cr."TargetCaseSlot", cr."TargetCaseSlotLocalizations",
        cr."RelationHash", cr."BuildExpression", cr."ValidateExpression",
        cr."OverrideType", cr."Order",
        cr."ScriptHash", cr."Attributes", cr."Clusters",
        cr."BuildActions", cr."ValidateActions"
    FROM "CaseRelation" cr
    INNER JOIN Regulations reg ON cr."RegulationId" = reg."Id"
    WHERE cr."Status" = 0
      AND cr."Created" <= "createdBefore"
      AND ("sourceCaseName" IS NULL
           OR LOWER(cr."SourceCaseName") = LOWER("sourceCaseName"))
      AND ("targetCaseName" IS NULL
           OR LOWER(cr."TargetCaseName") = LOWER("targetCaseName"))
      AND (("includeClusters" IS NULL AND "excludeClusters" IS NULL)
           OR IsMatchingCluster("includeClusters", "excludeClusters", cr."Clusters") = 1)
    ORDER BY cr."SourceCaseName", cr."TargetCaseName", reg."Level" DESC, reg."Priority" DESC;
$$;

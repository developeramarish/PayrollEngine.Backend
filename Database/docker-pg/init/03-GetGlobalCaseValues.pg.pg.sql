-- =============================================================================
-- GetGlobalCaseValues
-- Creates temp pivot table with optional attribute columns, then executes
-- the caller-supplied SQL against it.
-- Count queries (sql ILIKE '%COUNT(*)%') are routed via EXECUTE INTO to
-- return the count value in the first column ("Id") for Dapper long mapping.
-- =============================================================================

DROP PROCEDURE IF EXISTS GetGlobalCaseValues;

CREATE OR REPLACE FUNCTION "GetGlobalCaseValues"(
    IN "parentId"   INTEGER,
    IN "employeeId" INTEGER,
    IN "divisionId" INTEGER,
    IN "sql"        TEXT,
    IN "attributes" TEXT,
    IN "culture"    TEXT
)
RETURNS TABLE(
    "Id"                         INTEGER,
    "Status"                     INTEGER,
    "Created"                    TIMESTAMP(6),
    "Updated"                    TIMESTAMP(6),
    "TenantId"                   INTEGER,
    "DivisionId"                 INTEGER,
    "CaseName"                   VARCHAR(128),
    "CaseNameLocalizations"      TEXT,
    "CaseFieldName"              VARCHAR(128),
    "CaseFieldNameLocalizations" TEXT,
    "CaseSlot"                   VARCHAR(128),
    "CaseSlotLocalizations"      TEXT,
    "ValueType"                  INTEGER,
    "Value"                      TEXT,
    "NumericValue"               DECIMAL(28,6),
    "Culture"                    VARCHAR(128),
    "CaseRelation"               TEXT,
    "CancellationDate"           TIMESTAMP(6),
    "Start"                      TIMESTAMP(6),
    "End"                        TIMESTAMP(6),
    "Forecast"                   VARCHAR(128),
    "Tags"                       TEXT,
    "Attributes"                 TEXT
)
LANGUAGE plpgsql STABLE AS $$
DECLARE
    v_attrSql  TEXT;
    v_pivotSql TEXT;
    v_count    BIGINT;
BEGIN
    v_attrSql  := BuildAttributeQuery('"GlobalCaseValue"."Attributes"', "attributes");
    v_pivotSql := 'CREATE TEMP TABLE "##GlobalCaseValuePivot" AS'
        || ' SELECT "GlobalCaseValue".*'
        || v_attrSql
        || ' FROM "GlobalCaseValue"'
        || ' WHERE "GlobalCaseValue"."TenantId" = ' || "parentId"::TEXT;

    DROP TABLE IF EXISTS "##GlobalCaseValuePivot";
    EXECUTE v_pivotSql;

    IF "sql" ILIKE '%COUNT(*)%' OR "sql" ILIKE '%COUNT(0)%' THEN
        EXECUTE "sql" INTO v_count;
        "Id" := v_count::INTEGER;
        RETURN NEXT;
    ELSE
        RETURN QUERY EXECUTE "sql";
    END IF;

    DROP TABLE IF EXISTS "##GlobalCaseValuePivot";
EXCEPTION WHEN OTHERS THEN
    DROP TABLE IF EXISTS "##GlobalCaseValuePivot";
    RAISE;
END;
$$;

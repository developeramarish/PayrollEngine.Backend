-- =============================================================================
-- GetEmployeeCaseValues
-- Filter is EmployeeId (not TenantId) -- employee-scoped pivot.
-- Count queries (sql ILIKE '%COUNT(*)%') are routed via EXECUTE INTO to
-- return the count value in the first column ("Id") for Dapper long mapping.
-- =============================================================================

DROP PROCEDURE IF EXISTS GetEmployeeCaseValues;

CREATE OR REPLACE FUNCTION "GetEmployeeCaseValues"(
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
    "EmployeeId"                 INTEGER,
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
LANGUAGE plpgsql VOLATILE AS $$
DECLARE
    v_attrSql  TEXT;
    v_pivotSql TEXT;
    v_count    BIGINT;
BEGIN
    v_attrSql  := BuildAttributeQuery('"EmployeeCaseValue"."Attributes"', "attributes");
    v_pivotSql := 'CREATE TEMP TABLE "##EmployeeCaseValuePivot" AS'
        || ' SELECT "EmployeeCaseValue".*'
        || v_attrSql
        || ' FROM "EmployeeCaseValue"'
        || ' WHERE "EmployeeCaseValue"."EmployeeId" = ' || "parentId"::TEXT;

    DROP TABLE IF EXISTS "##EmployeeCaseValuePivot";
    EXECUTE v_pivotSql;

    IF "sql" ILIKE '%COUNT(*)%' OR "sql" ILIKE '%COUNT(0)%' THEN
        EXECUTE "sql" INTO v_count;
        "Id" := v_count::INTEGER;
        RETURN NEXT;
    ELSE
        RETURN QUERY EXECUTE "sql";
    END IF;

    DROP TABLE IF EXISTS "##EmployeeCaseValuePivot";
EXCEPTION WHEN OTHERS THEN
    DROP TABLE IF EXISTS "##EmployeeCaseValuePivot";
    RAISE;
END;
$$;

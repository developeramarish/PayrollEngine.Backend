-- =============================================================================
-- GetEmployeeCaseChangeValues
-- Filter is EmployeeId (not TenantId); extra JOIN to Employee for TenantId.
-- Creates temp pivot table joining CaseChange + CaseValue + User + Employee,
-- with optional culture-based name localization and attribute columns.
-- Count queries (sql ILIKE '%COUNT(*)%') are routed via EXECUTE INTO to
-- return the count value in the first column ("TenantId") for Dapper long mapping.
-- =============================================================================

DROP PROCEDURE IF EXISTS GetEmployeeCaseChangeValues;

CREATE OR REPLACE FUNCTION "GetEmployeeCaseChangeValues"(
    IN "parentId"   INTEGER,
    IN "employeeId" INTEGER,
    IN "divisionId" INTEGER,
    IN "sql"        TEXT,
    IN "attributes" TEXT,
    IN "culture"    TEXT
)
RETURNS TABLE(
    "TenantId"           INTEGER,
    "CaseChangeId"       INTEGER,
    "CaseChangeCreated"  TIMESTAMP(6),
    "Reason"             TEXT,
    "ValidationCaseName" VARCHAR(128),
    "CancellationType"   INTEGER,
    "CancellationId"     INTEGER,
    "CancellationDate"   TIMESTAMP(6),
    "EmployeeId"         INTEGER,
    "UserId"             INTEGER,
    "UserIdentifier"     VARCHAR(128),
    "DivisionId"         INTEGER,
    "Id"                 INTEGER,
    "Created"            TIMESTAMP(6),
    "Updated"            TIMESTAMP(6),
    "Status"             INTEGER,
    "CaseName"           VARCHAR(128),
    "CaseFieldName"      VARCHAR(128),
    "CaseSlot"           VARCHAR(128),
    "CaseRelation"       TEXT,
    "ValueType"          INTEGER,
    "Value"              TEXT,
    "NumericValue"       DECIMAL(28,6),
    "Culture"            VARCHAR(128),
    "Start"              TIMESTAMP(6),
    "End"                TIMESTAMP(6),
    "Forecast"           VARCHAR(128),
    "Tags"               TEXT,
    "Attributes"         TEXT,
    "Documents"          BIGINT
)
LANGUAGE plpgsql VOLATILE AS $$
DECLARE
    v_attrSql       TEXT;
    v_pivotSql      TEXT;
    v_caseName      TEXT;
    v_caseFieldName TEXT;
    v_caseSlot      TEXT;
    v_count         BIGINT;
BEGIN
    IF "culture" IS NULL THEN
        v_caseName      := '"EmployeeCaseValue"."CaseName"';
        v_caseFieldName := '"EmployeeCaseValue"."CaseFieldName"';
        v_caseSlot      := '"EmployeeCaseValue"."CaseSlot"';
    ELSE
        v_caseName      := 'GetLocalizedValue("EmployeeCaseValue"."CaseNameLocalizations", ''' || "culture" || ''', "EmployeeCaseValue"."CaseName")';
        v_caseFieldName := 'GetLocalizedValue("EmployeeCaseValue"."CaseFieldNameLocalizations", ''' || "culture" || ''', "EmployeeCaseValue"."CaseFieldName")';
        v_caseSlot      := 'GetLocalizedValue("EmployeeCaseValue"."CaseSlotLocalizations", ''' || "culture" || ''', "EmployeeCaseValue"."CaseSlot")';
    END IF;

    v_attrSql  := BuildAttributeQuery('"EmployeeCaseValue"."Attributes"', "attributes");
    v_pivotSql := 'CREATE TEMP TABLE "##EmployeeCaseChangeValuePivot" AS SELECT'
        || ' "Employee"."TenantId",'
        || ' "EmployeeCaseChange"."Id" AS "CaseChangeId",'
        || ' "EmployeeCaseChange"."Created" AS "CaseChangeCreated",'
        || ' "EmployeeCaseChange"."Reason",'
        || ' "EmployeeCaseChange"."ValidationCaseName",'
        || ' "EmployeeCaseChange"."CancellationType",'
        || ' "EmployeeCaseChange"."CancellationId",'
        || ' "EmployeeCaseChange"."CancellationDate",'
        || ' "EmployeeCaseChange"."EmployeeId",'
        || ' "EmployeeCaseChange"."UserId",'
        || ' "User"."Identifier" AS "UserIdentifier",'
        || ' "EmployeeCaseChange"."DivisionId",'
        || ' "EmployeeCaseValue"."Id",'
        || ' "EmployeeCaseValue"."Created",'
        || ' "EmployeeCaseValue"."Updated",'
        || ' "EmployeeCaseValue"."Status",'
        || ' ' || v_caseName      || ' AS "CaseName",'
        || ' ' || v_caseFieldName || ' AS "CaseFieldName",'
        || ' ' || v_caseSlot      || ' AS "CaseSlot",'
        || ' "EmployeeCaseValue"."CaseRelation",'
        || ' "EmployeeCaseValue"."ValueType",'
        || ' "EmployeeCaseValue"."Value",'
        || ' "EmployeeCaseValue"."NumericValue",'
        || ' "EmployeeCaseValue"."Culture",'
        || ' "EmployeeCaseValue"."Start",'
        || ' "EmployeeCaseValue"."End",'
        || ' "EmployeeCaseValue"."Forecast",'
        || ' "EmployeeCaseValue"."Tags",'
        || ' "EmployeeCaseValue"."Attributes",'
        || ' (SELECT COUNT(*) FROM "EmployeeCaseDocument" WHERE "CaseValueId" = "EmployeeCaseValue"."Id") AS "Documents"'
        || v_attrSql
        || ' FROM "EmployeeCaseValue"'
        || ' LEFT JOIN "EmployeeCaseValueChange" ON "EmployeeCaseValue"."Id" = "EmployeeCaseValueChange"."CaseValueId"'
        || ' LEFT JOIN "EmployeeCaseChange" ON "EmployeeCaseValueChange"."CaseChangeId" = "EmployeeCaseChange"."Id"'
        || ' LEFT JOIN "User" ON "User"."Id" = "EmployeeCaseChange"."UserId"'
        || ' LEFT JOIN "Employee" ON "Employee"."Id" = "EmployeeCaseChange"."EmployeeId"'
        || ' WHERE "EmployeeCaseChange"."EmployeeId" = ' || "parentId"::TEXT;

    DROP TABLE IF EXISTS "##EmployeeCaseChangeValuePivot";
    EXECUTE v_pivotSql;

    IF "sql" ILIKE '%COUNT(*)%' OR "sql" ILIKE '%COUNT(0)%' THEN
        EXECUTE "sql" INTO v_count;
        "TenantId" := v_count::INTEGER;
        RETURN NEXT;
    ELSE
        RETURN QUERY EXECUTE "sql";
    END IF;

    DROP TABLE IF EXISTS "##EmployeeCaseChangeValuePivot";
EXCEPTION WHEN OTHERS THEN
    DROP TABLE IF EXISTS "##EmployeeCaseChangeValuePivot";
    RAISE;
END;
$$;

-- =============================================================================
-- GetNationalCaseChangeValues
-- Creates temp pivot table joining CaseChange + CaseValue + User, with
-- optional culture-based name localization and attribute columns.
-- Count queries (sql ILIKE '%COUNT(*)%') are routed via EXECUTE INTO to
-- return the count value in the first column ("TenantId") for Dapper long mapping.
-- =============================================================================

DROP PROCEDURE IF EXISTS GetNationalCaseChangeValues;

CREATE OR REPLACE FUNCTION "GetNationalCaseChangeValues"(
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
LANGUAGE plpgsql STABLE AS $$
DECLARE
    v_attrSql       TEXT;
    v_pivotSql      TEXT;
    v_caseName      TEXT;
    v_caseFieldName TEXT;
    v_caseSlot      TEXT;
    v_count         BIGINT;
BEGIN
    IF "culture" IS NULL THEN
        v_caseName      := '"NationalCaseValue"."CaseName"';
        v_caseFieldName := '"NationalCaseValue"."CaseFieldName"';
        v_caseSlot      := '"NationalCaseValue"."CaseSlot"';
    ELSE
        v_caseName      := 'GetLocalizedValue("NationalCaseValue"."CaseNameLocalizations", ''' || "culture" || ''', "NationalCaseValue"."CaseName")';
        v_caseFieldName := 'GetLocalizedValue("NationalCaseValue"."CaseFieldNameLocalizations", ''' || "culture" || ''', "NationalCaseValue"."CaseFieldName")';
        v_caseSlot      := 'GetLocalizedValue("NationalCaseValue"."CaseSlotLocalizations", ''' || "culture" || ''', "NationalCaseValue"."CaseSlot")';
    END IF;

    v_attrSql  := BuildAttributeQuery('"NationalCaseValue"."Attributes"', "attributes");
    v_pivotSql := 'CREATE TEMP TABLE "##NationalCaseChangeValuePivot" AS SELECT'
        || ' "NationalCaseChange"."TenantId",'
        || ' "NationalCaseChange"."Id" AS "CaseChangeId",'
        || ' "NationalCaseChange"."Created" AS "CaseChangeCreated",'
        || ' "NationalCaseChange"."Reason",'
        || ' "NationalCaseChange"."ValidationCaseName",'
        || ' "NationalCaseChange"."CancellationType",'
        || ' "NationalCaseChange"."CancellationId",'
        || ' "NationalCaseChange"."CancellationDate",'
        || ' NULL AS "EmployeeId",'
        || ' "NationalCaseChange"."UserId",'
        || ' "User"."Identifier" AS "UserIdentifier",'
        || ' "NationalCaseChange"."DivisionId",'
        || ' "NationalCaseValue"."Id",'
        || ' "NationalCaseValue"."Created",'
        || ' "NationalCaseValue"."Updated",'
        || ' "NationalCaseValue"."Status",'
        || ' ' || v_caseName      || ' AS "CaseName",'
        || ' ' || v_caseFieldName || ' AS "CaseFieldName",'
        || ' ' || v_caseSlot      || ' AS "CaseSlot",'
        || ' "NationalCaseValue"."CaseRelation",'
        || ' "NationalCaseValue"."ValueType",'
        || ' "NationalCaseValue"."Value",'
        || ' "NationalCaseValue"."NumericValue",'
        || ' "NationalCaseValue"."Culture",'
        || ' "NationalCaseValue"."Start",'
        || ' "NationalCaseValue"."End",'
        || ' "NationalCaseValue"."Forecast",'
        || ' "NationalCaseValue"."Tags",'
        || ' "NationalCaseValue"."Attributes",'
        || ' (SELECT COUNT(*) FROM "NationalCaseDocument" WHERE "CaseValueId" = "NationalCaseValue"."Id") AS "Documents"'
        || v_attrSql
        || ' FROM "NationalCaseValue"'
        || ' LEFT JOIN "NationalCaseValueChange" ON "NationalCaseValue"."Id" = "NationalCaseValueChange"."CaseValueId"'
        || ' LEFT JOIN "NationalCaseChange" ON "NationalCaseValueChange"."CaseChangeId" = "NationalCaseChange"."Id"'
        || ' LEFT JOIN "User" ON "User"."Id" = "NationalCaseChange"."UserId"'
        || ' WHERE "NationalCaseChange"."TenantId" = ' || "parentId"::TEXT;

    DROP TABLE IF EXISTS "##NationalCaseChangeValuePivot";
    EXECUTE v_pivotSql;

    IF "sql" ILIKE '%COUNT(*)%' OR "sql" ILIKE '%COUNT(0)%' THEN
        EXECUTE "sql" INTO v_count;
        "TenantId" := v_count::INTEGER;
        RETURN NEXT;
    ELSE
        RETURN QUERY EXECUTE "sql";
    END IF;

    DROP TABLE IF EXISTS "##NationalCaseChangeValuePivot";
EXCEPTION WHEN OTHERS THEN
    DROP TABLE IF EXISTS "##NationalCaseChangeValuePivot";
    RAISE;
END;
$$;

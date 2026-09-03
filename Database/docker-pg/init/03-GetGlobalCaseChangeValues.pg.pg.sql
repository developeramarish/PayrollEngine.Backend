-- =============================================================================
-- GetGlobalCaseChangeValues
-- Creates temp pivot table joining CaseChange + CaseValue + User, with
-- optional culture-based name localization and attribute columns.
-- Count queries (sql ILIKE '%COUNT(*)%') are routed via EXECUTE INTO to
-- return the count value in the first column ("TenantId") for Dapper long mapping.
-- =============================================================================

DROP PROCEDURE IF EXISTS GetGlobalCaseChangeValues;

CREATE OR REPLACE FUNCTION "GetGlobalCaseChangeValues"(
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
        v_caseName      := '"GlobalCaseValue"."CaseName"';
        v_caseFieldName := '"GlobalCaseValue"."CaseFieldName"';
        v_caseSlot      := '"GlobalCaseValue"."CaseSlot"';
    ELSE
        v_caseName      := 'GetLocalizedValue("GlobalCaseValue"."CaseNameLocalizations", ''' || "culture" || ''', "GlobalCaseValue"."CaseName")';
        v_caseFieldName := 'GetLocalizedValue("GlobalCaseValue"."CaseFieldNameLocalizations", ''' || "culture" || ''', "GlobalCaseValue"."CaseFieldName")';
        v_caseSlot      := 'GetLocalizedValue("GlobalCaseValue"."CaseSlotLocalizations", ''' || "culture" || ''', "GlobalCaseValue"."CaseSlot")';
    END IF;

    v_attrSql  := BuildAttributeQuery('"GlobalCaseValue"."Attributes"', "attributes");
    v_pivotSql := 'CREATE TEMP TABLE "##GlobalCaseChangeValuePivot" AS SELECT'
        || ' "GlobalCaseChange"."TenantId",'
        || ' "GlobalCaseChange"."Id" AS "CaseChangeId",'
        || ' "GlobalCaseChange"."Created" AS "CaseChangeCreated",'
        || ' "GlobalCaseChange"."Reason",'
        || ' "GlobalCaseChange"."ValidationCaseName",'
        || ' "GlobalCaseChange"."CancellationType",'
        || ' "GlobalCaseChange"."CancellationId",'
        || ' "GlobalCaseChange"."CancellationDate",'
        || ' NULL AS "EmployeeId",'
        || ' "GlobalCaseChange"."UserId",'
        || ' "User"."Identifier" AS "UserIdentifier",'
        || ' "GlobalCaseChange"."DivisionId",'
        || ' "GlobalCaseValue"."Id",'
        || ' "GlobalCaseValue"."Created",'
        || ' "GlobalCaseValue"."Updated",'
        || ' "GlobalCaseValue"."Status",'
        || ' ' || v_caseName      || ' AS "CaseName",'
        || ' ' || v_caseFieldName || ' AS "CaseFieldName",'
        || ' ' || v_caseSlot      || ' AS "CaseSlot",'
        || ' "GlobalCaseValue"."CaseRelation",'
        || ' "GlobalCaseValue"."ValueType",'
        || ' "GlobalCaseValue"."Value",'
        || ' "GlobalCaseValue"."NumericValue",'
        || ' "GlobalCaseValue"."Culture",'
        || ' "GlobalCaseValue"."Start",'
        || ' "GlobalCaseValue"."End",'
        || ' "GlobalCaseValue"."Forecast",'
        || ' "GlobalCaseValue"."Tags",'
        || ' "GlobalCaseValue"."Attributes",'
        || ' (SELECT COUNT(*) FROM "GlobalCaseDocument" WHERE "CaseValueId" = "GlobalCaseValue"."Id") AS "Documents"'
        || v_attrSql
        || ' FROM "GlobalCaseValue"'
        || ' LEFT JOIN "GlobalCaseValueChange" ON "GlobalCaseValue"."Id" = "GlobalCaseValueChange"."CaseValueId"'
        || ' LEFT JOIN "GlobalCaseChange" ON "GlobalCaseValueChange"."CaseChangeId" = "GlobalCaseChange"."Id"'
        || ' LEFT JOIN "User" ON "User"."Id" = "GlobalCaseChange"."UserId"'
        || ' WHERE "GlobalCaseChange"."TenantId" = ' || "parentId"::TEXT;

    DROP TABLE IF EXISTS "##GlobalCaseChangeValuePivot";
    EXECUTE v_pivotSql;

    IF "sql" ILIKE '%COUNT(*)%' OR "sql" ILIKE '%COUNT(0)%' THEN
        EXECUTE "sql" INTO v_count;
        "TenantId" := v_count::INTEGER;
        RETURN NEXT;
    ELSE
        RETURN QUERY EXECUTE "sql";
    END IF;

    DROP TABLE IF EXISTS "##GlobalCaseChangeValuePivot";
EXCEPTION WHEN OTHERS THEN
    DROP TABLE IF EXISTS "##GlobalCaseChangeValuePivot";
    RAISE;
END;
$$;

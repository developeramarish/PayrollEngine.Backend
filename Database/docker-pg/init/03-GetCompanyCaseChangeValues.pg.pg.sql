-- =============================================================================
-- GetCompanyCaseChangeValues
-- Creates temp pivot table joining CaseChange + CaseValue + User, with
-- optional culture-based name localization and attribute columns.
-- Count queries (sql ILIKE '%COUNT(*)%') are routed via EXECUTE INTO to
-- return the count value in the first column ("TenantId") for Dapper long mapping.
-- =============================================================================

DROP PROCEDURE IF EXISTS GetCompanyCaseChangeValues;

CREATE OR REPLACE FUNCTION "GetCompanyCaseChangeValues"(
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
        v_caseName      := '"CompanyCaseValue"."CaseName"';
        v_caseFieldName := '"CompanyCaseValue"."CaseFieldName"';
        v_caseSlot      := '"CompanyCaseValue"."CaseSlot"';
    ELSE
        v_caseName      := 'GetLocalizedValue("CompanyCaseValue"."CaseNameLocalizations", ''' || "culture" || ''', "CompanyCaseValue"."CaseName")';
        v_caseFieldName := 'GetLocalizedValue("CompanyCaseValue"."CaseFieldNameLocalizations", ''' || "culture" || ''', "CompanyCaseValue"."CaseFieldName")';
        v_caseSlot      := 'GetLocalizedValue("CompanyCaseValue"."CaseSlotLocalizations", ''' || "culture" || ''', "CompanyCaseValue"."CaseSlot")';
    END IF;

    v_attrSql  := BuildAttributeQuery('"CompanyCaseValue"."Attributes"', "attributes");
    v_pivotSql := 'CREATE TEMP TABLE "##CompanyCaseChangeValuePivot" AS SELECT'
        || ' "CompanyCaseChange"."TenantId",'
        || ' "CompanyCaseChange"."Id" AS "CaseChangeId",'
        || ' "CompanyCaseChange"."Created" AS "CaseChangeCreated",'
        || ' "CompanyCaseChange"."Reason",'
        || ' "CompanyCaseChange"."ValidationCaseName",'
        || ' "CompanyCaseChange"."CancellationType",'
        || ' "CompanyCaseChange"."CancellationId",'
        || ' "CompanyCaseChange"."CancellationDate",'
        || ' NULL AS "EmployeeId",'
        || ' "CompanyCaseChange"."UserId",'
        || ' "User"."Identifier" AS "UserIdentifier",'
        || ' "CompanyCaseChange"."DivisionId",'
        || ' "CompanyCaseValue"."Id",'
        || ' "CompanyCaseValue"."Created",'
        || ' "CompanyCaseValue"."Updated",'
        || ' "CompanyCaseValue"."Status",'
        || ' ' || v_caseName      || ' AS "CaseName",'
        || ' ' || v_caseFieldName || ' AS "CaseFieldName",'
        || ' ' || v_caseSlot      || ' AS "CaseSlot",'
        || ' "CompanyCaseValue"."CaseRelation",'
        || ' "CompanyCaseValue"."ValueType",'
        || ' "CompanyCaseValue"."Value",'
        || ' "CompanyCaseValue"."NumericValue",'
        || ' "CompanyCaseValue"."Culture",'
        || ' "CompanyCaseValue"."Start",'
        || ' "CompanyCaseValue"."End",'
        || ' "CompanyCaseValue"."Forecast",'
        || ' "CompanyCaseValue"."Tags",'
        || ' "CompanyCaseValue"."Attributes",'
        || ' (SELECT COUNT(*) FROM "CompanyCaseDocument" WHERE "CaseValueId" = "CompanyCaseValue"."Id") AS "Documents"'
        || v_attrSql
        || ' FROM "CompanyCaseValue"'
        || ' LEFT JOIN "CompanyCaseValueChange" ON "CompanyCaseValue"."Id" = "CompanyCaseValueChange"."CaseValueId"'
        || ' LEFT JOIN "CompanyCaseChange" ON "CompanyCaseValueChange"."CaseChangeId" = "CompanyCaseChange"."Id"'
        || ' LEFT JOIN "User" ON "User"."Id" = "CompanyCaseChange"."UserId"'
        || ' WHERE "CompanyCaseChange"."TenantId" = ' || "parentId"::TEXT;

    DROP TABLE IF EXISTS "##CompanyCaseChangeValuePivot";
    EXECUTE v_pivotSql;

    IF "sql" ILIKE '%COUNT(*)%' OR "sql" ILIKE '%COUNT(0)%' THEN
        EXECUTE "sql" INTO v_count;
        "TenantId" := v_count::INTEGER;
        RETURN NEXT;
    ELSE
        RETURN QUERY EXECUTE "sql";
    END IF;

    DROP TABLE IF EXISTS "##CompanyCaseChangeValuePivot";
EXCEPTION WHEN OTHERS THEN
    DROP TABLE IF EXISTS "##CompanyCaseChangeValuePivot";
    RAISE;
END;
$$;

-- =============================================================================
-- GetPayrollResultValues
-- 5-way UNION ALL pivot of all result types.
-- Parameter order matches C# positional call (CaseValueExtendedParameters=true):
--   parentId, employeeId, divisionId, sql, attributes
-- p_sql from C# references "##PayrollResultPivot"; the inner pivot is exposed
-- as a CTE under that exact name so the caller query resolves it correctly.
-- =============================================================================

CREATE OR REPLACE FUNCTION "GetPayrollResultValues"(
    IN "parentId"   INT,
    IN "employeeId" INT,
    IN "divisionId" INT,
    IN "sql"        TEXT,
    IN "attributes" TEXT
)
RETURNS TABLE (
    "TenantId"           INT,
    "PayrollResultId"    INT,
    "Created"            TIMESTAMP(6),
    "ResultKind"         INT,
    "ResultId"           INT,
    "ResultParentId"     INT,
    "ResultNumber"       DECIMAL(28,6),
    "KindName"           VARCHAR(128),
    "ResultCreated"      TIMESTAMP(6),
    "ResultStart"        TIMESTAMP(6),
    "ResultEnd"          TIMESTAMP(6),
    "ResultType"         INT,
    "ResultValue"        TEXT,
    "ResultNumericValue" DECIMAL(28,6),
    "ResultCulture"      VARCHAR(128),
    "ResultTags"         TEXT,
    "Attributes"         TEXT,
    "JobId"              INT,
    "JobName"            VARCHAR(128),
    "JobReason"          TEXT,
    "Forecast"           VARCHAR(128),
    "JobStatus"          INT,
    "CycleName"          VARCHAR(128),
    "PeriodName"         VARCHAR(128),
    "PeriodStart"        TIMESTAMP(6),
    "PeriodEnd"          TIMESTAMP(6),
    "PayrunId"           INT,
    "PayrunName"         VARCHAR(128),
    "PayrollId"          INT,
    "PayrollName"        VARCHAR(128),
    "DivisionId"         INT,
    "DivisionName"       VARCHAR(128),
    "Culture"            VARCHAR(128),
    "UserId"             INT,
    "UserIdentifier"     VARCHAR(128),
    "EmployeeId"         INT,
    "EmployeeIdentifier" VARCHAR(128)
)
LANGUAGE plpgsql STABLE
AS $$
DECLARE
    v_attrNames TEXT;
    v_innerSql  TEXT;
    v_where     TEXT;
    v_fullSql   TEXT;
BEGIN
    v_attrNames := "GetAttributeNames"(attributes);

    -- Build optional WHERE clause (employee / division pre-filter inside the pivot)
    v_where := '';
    IF employeeId IS NOT NULL OR divisionId IS NOT NULL THEN
        v_where := ' WHERE ';
        IF employeeId IS NOT NULL THEN
            v_where := v_where || '"Employee"."Id" = ' || employeeId::TEXT;
        END IF;
        IF employeeId IS NOT NULL AND divisionId IS NOT NULL THEN
            v_where := v_where || ' AND ';
        END IF;
        IF divisionId IS NOT NULL THEN
            v_where := v_where || '"Division"."Id" = ' || divisionId::TEXT;
        END IF;
    END IF;

    -- Build inner pivot SELECT (fixed columns + optional dynamic attribute columns)
    v_innerSql :=
        'SELECT'
        || ' "PayrollResult"."TenantId",'
        || ' "PayrollResult"."Id" AS "PayrollResultId",'
        || ' "PayrollResult"."Created",'
        || ' "PayrollValue"."ResultKind",'
        || ' "PayrollValue"."ResultId",'
        || ' "PayrollValue"."ResultParentId",'
        || ' "PayrollValue"."ResultNumber",'
        || ' "PayrollValue"."KindName",'
        || ' "PayrollValue"."ResultCreated",'
        || ' "PayrollValue"."ResultStart",'
        || ' "PayrollValue"."ResultEnd",'
        || ' "PayrollValue"."ResultType",'
        || ' "PayrollValue"."ResultValue",'
        || ' "PayrollValue"."ResultNumericValue",'
        || ' "PayrollValue"."ResultCulture",'
        || ' "PayrollValue"."ResultTags",'
        || ' "PayrollValue"."Attributes",'
        || ' "PayrunJob"."Id" AS "JobId",'
        || ' "PayrunJob"."Name" AS "JobName",'
        || ' "PayrunJob"."CreatedReason" AS "JobReason",'
        || ' "PayrunJob"."Forecast",'
        || ' "PayrunJob"."JobStatus",'
        || ' "PayrunJob"."CycleName",'
        || ' "PayrunJob"."PeriodName",'
        || ' "PayrunJob"."PeriodStart",'
        || ' "PayrunJob"."PeriodEnd",'
        || ' "Payrun"."Id" AS "PayrunId",'
        || ' "Payrun"."Name" AS "PayrunName",'
        || ' "Payroll"."Id" AS "PayrollId",'
        || ' "Payroll"."Name" AS "PayrollName",'
        || ' "Division"."Id" AS "DivisionId",'
        || ' "Division"."Name" AS "DivisionName",'
        || ' "Division"."Culture",'
        || ' "User"."Id" AS "UserId",'
        || ' "User"."Identifier" AS "UserIdentifier",'
        || ' "Employee"."Id" AS "EmployeeId",'
        || ' "Employee"."Identifier" AS "EmployeeIdentifier"'
        || v_attrNames
        || ' FROM ('
        -- CollectorResult (kind=10)
        || ' SELECT 10 AS "ResultKind",'
        || ' "CollectorResult"."PayrollResultId",'
        || ' "CollectorResult"."Id" AS "ResultId",'
        || ' "CollectorResult"."PayrollResultId" AS "ResultParentId",'
        || ' "CollectorResult"."CollectorName" AS "KindName",'
        || ' CAST(0 AS DECIMAL(28,6)) AS "ResultNumber",'
        || ' "CollectorResult"."Created" AS "ResultCreated",'
        || ' "CollectorResult"."Start" AS "ResultStart",'
        || ' "CollectorResult"."End" AS "ResultEnd",'
        || ' "CollectorResult"."Tags" AS "ResultTags",'
        || ' "CollectorResult"."Attributes",'
        || ' "CollectorResult"."ValueType" AS "ResultType",'
        || ' to_char("CollectorResult"."Value", ''FM999999999999999999990.00'') AS "ResultValue",'
        || ' "CollectorResult"."Value" AS "ResultNumericValue",'
        || ' "CollectorResult"."Culture" AS "ResultCulture"'
        || "BuildAttributeQuery"('"CollectorResult"."Attributes"', attributes)
        || ' FROM "CollectorResult"'
        || ' UNION ALL'
        -- CollectorCustomResult (kind=11)
        || ' SELECT 11 AS "ResultKind",'
        || ' "CollectorResult"."PayrollResultId",'
        || ' "CollectorCustomResult"."Id" AS "ResultId",'
        || ' "CollectorResult"."Id" AS "ResultParentId",'
        || ' "CollectorCustomResult"."Source" AS "KindName",'
        || ' CAST(0 AS DECIMAL(28,6)) AS "ResultNumber",'
        || ' "CollectorCustomResult"."Created" AS "ResultCreated",'
        || ' "CollectorCustomResult"."Start" AS "ResultStart",'
        || ' "CollectorCustomResult"."End" AS "ResultEnd",'
        || ' "CollectorCustomResult"."Tags" AS "ResultTags",'
        || ' "CollectorCustomResult"."Attributes",'
        || ' "CollectorCustomResult"."ValueType" AS "ResultType",'
        || ' to_char("CollectorCustomResult"."Value", ''FM999999999999999999990.00'') AS "ResultValue",'
        || ' "CollectorCustomResult"."Value" AS "ResultNumericValue",'
        || ' "CollectorCustomResult"."Culture" AS "ResultCulture"'
        || "BuildAttributeQuery"('"CollectorCustomResult"."Attributes"', attributes)
        || ' FROM "CollectorResult"'
        || ' INNER JOIN "CollectorCustomResult" ON "CollectorResult"."Id" = "CollectorCustomResult"."CollectorResultId"'
        || ' UNION ALL'
        -- WageTypeResult (kind=20)
        || ' SELECT 20 AS "ResultKind",'
        || ' "WageTypeResult"."PayrollResultId",'
        || ' "WageTypeResult"."Id" AS "ResultId",'
        || ' "WageTypeResult"."PayrollResultId" AS "ResultParentId",'
        || ' "WageTypeResult"."WageTypeName" AS "KindName",'
        || ' "WageTypeResult"."WageTypeNumber" AS "ResultNumber",'
        || ' "WageTypeResult"."Created" AS "ResultCreated",'
        || ' "WageTypeResult"."Start" AS "ResultStart",'
        || ' "WageTypeResult"."End" AS "ResultEnd",'
        || ' "WageTypeResult"."Tags" AS "ResultTags",'
        || ' "WageTypeResult"."Attributes",'
        || ' "WageTypeResult"."ValueType" AS "ResultType",'
        || ' to_char("WageTypeResult"."Value", ''FM999999999999999999990.00'') AS "ResultValue",'
        || ' "WageTypeResult"."Value" AS "ResultNumericValue",'
        || ' "WageTypeResult"."Culture" AS "ResultCulture"'
        || "BuildAttributeQuery"('"WageTypeResult"."Attributes"', attributes)
        || ' FROM "WageTypeResult"'
        || ' UNION ALL'
        -- WageTypeCustomResult (kind=21)
        || ' SELECT 21 AS "ResultKind",'
        || ' "WageTypeResult"."PayrollResultId",'
        || ' "WageTypeCustomResult"."Id" AS "ResultId",'
        || ' "WageTypeResult"."Id" AS "ResultParentId",'
        || ' "WageTypeCustomResult"."Source" AS "KindName",'
        || ' CAST(0 AS DECIMAL(28,6)) AS "ResultNumber",'
        || ' "WageTypeCustomResult"."Created" AS "ResultCreated",'
        || ' "WageTypeCustomResult"."Start" AS "ResultStart",'
        || ' "WageTypeCustomResult"."End" AS "ResultEnd",'
        || ' "WageTypeCustomResult"."Tags" AS "ResultTags",'
        || ' "WageTypeCustomResult"."Attributes",'
        || ' "WageTypeCustomResult"."ValueType" AS "ResultType",'
        || ' to_char("WageTypeCustomResult"."Value", ''FM999999999999999999990.00'') AS "ResultValue",'
        || ' "WageTypeCustomResult"."Value" AS "ResultNumericValue",'
        || ' "WageTypeCustomResult"."Culture" AS "ResultCulture"'
        || "BuildAttributeQuery"('"WageTypeCustomResult"."Attributes"', attributes)
        || ' FROM "WageTypeResult"'
        || ' INNER JOIN "WageTypeCustomResult" ON "WageTypeResult"."Id" = "WageTypeCustomResult"."WageTypeResultId"'
        || ' UNION ALL'
        -- PayrunResult (kind=30)
        || ' SELECT 30 AS "ResultKind",'
        || ' "PayrunResult"."PayrollResultId",'
        || ' "PayrunResult"."Id" AS "ResultId",'
        || ' "PayrunResult"."PayrollResultId" AS "ResultParentId",'
        || ' "PayrunResult"."Name" AS "KindName",'
        || ' CAST(0 AS DECIMAL(28,6)) AS "ResultNumber",'
        || ' "PayrunResult"."Created" AS "ResultCreated",'
        || ' "PayrunResult"."Start" AS "ResultStart",'
        || ' "PayrunResult"."End" AS "ResultEnd",'
        || ' "PayrunResult"."Tags" AS "ResultTags",'
        || ' "PayrunResult"."Attributes",'
        || ' "PayrunResult"."ValueType" AS "ResultType",'
        || ' LTRIM("PayrunResult"."Value") AS "ResultValue",'
        || ' "PayrunResult"."NumericValue" AS "ResultNumericValue",'
        || ' "PayrunResult"."Culture" AS "ResultCulture"'
        || "BuildAttributeQuery"(NULL, attributes)
        || ' FROM "PayrunResult"'
        || ') "PayrollValue"'
        || ' LEFT JOIN "PayrollResult" ON "PayrollResult"."Id" = "PayrollValue"."PayrollResultId"'
        || ' LEFT JOIN "PayrunJob" ON "PayrollResult"."PayrunJobId" = "PayrunJob"."Id"'
        || ' LEFT JOIN "Payrun" ON "PayrunJob"."PayrunId" = "Payrun"."Id"'
        || ' LEFT JOIN "Employee" ON "PayrollResult"."EmployeeId" = "Employee"."Id"'
        || ' LEFT JOIN "Payroll" ON "PayrollResult"."PayrollId" = "Payroll"."Id"'
        || ' LEFT JOIN "Division" ON "Payroll"."DivisionId" = "Division"."Id"'
        || ' LEFT JOIN "User" ON "PayrunJob"."CreatedUserId" = "User"."Id"'
        || v_where;

    -- Wrap pivot as CTE under "##PayrollResultPivot" so the caller sql resolves it
    v_fullSql := 'WITH "##PayrollResultPivot" AS (' || v_innerSql || ') ' || sql;

    RETURN QUERY EXECUTE v_fullSql;
END;
$$;

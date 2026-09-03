-- =============================================================================
-- GetEmployeeCaseChangeValues
-- Filter is EmployeeId (not TenantId); extra JOIN to Employee for TenantId
-- =============================================================================

CREATE OR REPLACE PROCEDURE GetEmployeeCaseChangeValues(
    IN p_parentId   INTEGER,
    IN p_sql        TEXT,
    IN p_attributes TEXT,
    IN p_culture    TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_attrSql       TEXT;
    v_pivotSql      TEXT;
    v_caseName      TEXT;
    v_caseFieldName TEXT;
    v_caseSlot      TEXT;
BEGIN
    IF p_culture IS NULL THEN
        v_caseName      := 'EmployeeCaseValue.CaseName';
        v_caseFieldName := 'EmployeeCaseValue.CaseFieldName';
        v_caseSlot      := 'EmployeeCaseValue.CaseSlot';
    ELSE
        v_caseName      := 'GetLocalizedValue(EmployeeCaseValue.CaseNameLocalizations, ''' || p_culture || ''', EmployeeCaseValue.CaseName)';
        v_caseFieldName := 'GetLocalizedValue(EmployeeCaseValue.CaseFieldNameLocalizations, ''' || p_culture || ''', EmployeeCaseValue.CaseFieldName)';
        v_caseSlot      := 'GetLocalizedValue(EmployeeCaseValue.CaseSlotLocalizations, ''' || p_culture || ''', EmployeeCaseValue.CaseSlot)';
    END IF;

    v_attrSql  := BuildAttributeQuery('EmployeeCaseValue.Attributes', p_attributes);
    v_pivotSql := 'CREATE TEMP TABLE EmployeeCaseChangeValuePivot AS SELECT'
        || ' Employee.TenantId,'
        || ' EmployeeCaseChange.Id AS CaseChangeId,'
        || ' EmployeeCaseChange.Created AS CaseChangeCreated,'
        || ' EmployeeCaseChange.Reason,'
        || ' EmployeeCaseChange.ValidationCaseName,'
        || ' EmployeeCaseChange.CancellationType,'
        || ' EmployeeCaseChange.CancellationId,'
        || ' EmployeeCaseChange.CancellationDate,'
        || ' EmployeeCaseChange.EmployeeId,'
        || ' EmployeeCaseChange.UserId,'
        || ' "User".Identifier AS UserIdentifier,'
        || ' EmployeeCaseChange.DivisionId,'
        || ' EmployeeCaseValue.Id,'
        || ' EmployeeCaseValue.Created,'
        || ' EmployeeCaseValue.Updated,'
        || ' EmployeeCaseValue.Status,'
        || ' ' || v_caseName      || ' AS CaseName,'
        || ' ' || v_caseFieldName || ' AS CaseFieldName,'
        || ' ' || v_caseSlot      || ' AS CaseSlot,'
        || ' EmployeeCaseValue.CaseRelation,'
        || ' EmployeeCaseValue.ValueType,'
        || ' EmployeeCaseValue.Value,'
        || ' EmployeeCaseValue.NumericValue,'
        || ' EmployeeCaseValue.Culture,'
        || ' EmployeeCaseValue.Start,'
        || ' EmployeeCaseValue.End,'
        || ' EmployeeCaseValue.Forecast,'
        || ' EmployeeCaseValue.Tags,'
        || ' EmployeeCaseValue.Attributes,'
        || ' (SELECT COUNT(*) FROM EmployeeCaseDocument WHERE CaseValueId = EmployeeCaseValue.Id) AS Documents'
        || v_attrSql
        || ' FROM EmployeeCaseValue'
        || ' LEFT JOIN EmployeeCaseValueChange ON EmployeeCaseValue.Id = EmployeeCaseValueChange.CaseValueId'
        || ' LEFT JOIN EmployeeCaseChange ON EmployeeCaseValueChange.CaseChangeId = EmployeeCaseChange.Id'
        || ' LEFT JOIN "User" ON "User".Id = EmployeeCaseChange.UserId'
        || ' LEFT JOIN Employee ON Employee.Id = EmployeeCaseChange.EmployeeId'
        || ' WHERE EmployeeCaseChange.EmployeeId = ' || p_parentId::TEXT;

    DROP TABLE IF EXISTS EmployeeCaseChangeValuePivot;

    EXECUTE v_pivotSql;

    EXECUTE p_sql;

    DROP TABLE IF EXISTS EmployeeCaseChangeValuePivot;
EXCEPTION WHEN OTHERS THEN
    DROP TABLE IF EXISTS EmployeeCaseChangeValuePivot;
    RAISE;
END;
$$;

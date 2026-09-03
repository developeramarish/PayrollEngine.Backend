-- =============================================================================
-- GetCompanyCaseChangeValues
-- =============================================================================

CREATE OR REPLACE PROCEDURE GetCompanyCaseChangeValues(
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
        v_caseName      := 'CompanyCaseValue.CaseName';
        v_caseFieldName := 'CompanyCaseValue.CaseFieldName';
        v_caseSlot      := 'CompanyCaseValue.CaseSlot';
    ELSE
        v_caseName      := 'GetLocalizedValue(CompanyCaseValue.CaseNameLocalizations, ''' || p_culture || ''', CompanyCaseValue.CaseName)';
        v_caseFieldName := 'GetLocalizedValue(CompanyCaseValue.CaseFieldNameLocalizations, ''' || p_culture || ''', CompanyCaseValue.CaseFieldName)';
        v_caseSlot      := 'GetLocalizedValue(CompanyCaseValue.CaseSlotLocalizations, ''' || p_culture || ''', CompanyCaseValue.CaseSlot)';
    END IF;

    v_attrSql  := BuildAttributeQuery('CompanyCaseValue.Attributes', p_attributes);
    v_pivotSql := 'CREATE TEMP TABLE CompanyCaseChangeValuePivot AS SELECT'
        || ' CompanyCaseChange.TenantId,'
        || ' CompanyCaseChange.Id AS CaseChangeId,'
        || ' CompanyCaseChange.Created AS CaseChangeCreated,'
        || ' CompanyCaseChange.Reason,'
        || ' CompanyCaseChange.ValidationCaseName,'
        || ' CompanyCaseChange.CancellationType,'
        || ' CompanyCaseChange.CancellationId,'
        || ' CompanyCaseChange.CancellationDate,'
        || ' NULL AS EmployeeId,'
        || ' CompanyCaseChange.UserId,'
        || ' "User".Identifier AS UserIdentifier,'
        || ' CompanyCaseChange.DivisionId,'
        || ' CompanyCaseValue.Id,'
        || ' CompanyCaseValue.Created,'
        || ' CompanyCaseValue.Updated,'
        || ' CompanyCaseValue.Status,'
        || ' ' || v_caseName      || ' AS CaseName,'
        || ' ' || v_caseFieldName || ' AS CaseFieldName,'
        || ' ' || v_caseSlot      || ' AS CaseSlot,'
        || ' CompanyCaseValue.CaseRelation,'
        || ' CompanyCaseValue.ValueType,'
        || ' CompanyCaseValue.Value,'
        || ' CompanyCaseValue.NumericValue,'
        || ' CompanyCaseValue.Culture,'
        || ' CompanyCaseValue.Start,'
        || ' CompanyCaseValue.End,'
        || ' CompanyCaseValue.Forecast,'
        || ' CompanyCaseValue.Tags,'
        || ' CompanyCaseValue.Attributes,'
        || ' (SELECT COUNT(*) FROM CompanyCaseDocument WHERE CaseValueId = CompanyCaseValue.Id) AS Documents'
        || v_attrSql
        || ' FROM CompanyCaseValue'
        || ' LEFT JOIN CompanyCaseValueChange ON CompanyCaseValue.Id = CompanyCaseValueChange.CaseValueId'
        || ' LEFT JOIN CompanyCaseChange ON CompanyCaseValueChange.CaseChangeId = CompanyCaseChange.Id'
        || ' LEFT JOIN "User" ON "User".Id = CompanyCaseChange.UserId'
        || ' WHERE CompanyCaseChange.TenantId = ' || p_parentId::TEXT;

    DROP TABLE IF EXISTS CompanyCaseChangeValuePivot;

    EXECUTE v_pivotSql;

    EXECUTE p_sql;

    DROP TABLE IF EXISTS CompanyCaseChangeValuePivot;
EXCEPTION WHEN OTHERS THEN
    DROP TABLE IF EXISTS CompanyCaseChangeValuePivot;
    RAISE;
END;
$$;

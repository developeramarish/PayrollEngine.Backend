-- =============================================================================
-- GetNationalCaseChangeValues
-- =============================================================================

CREATE OR REPLACE PROCEDURE GetNationalCaseChangeValues(
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
        v_caseName      := 'NationalCaseValue.CaseName';
        v_caseFieldName := 'NationalCaseValue.CaseFieldName';
        v_caseSlot      := 'NationalCaseValue.CaseSlot';
    ELSE
        v_caseName      := 'GetLocalizedValue(NationalCaseValue.CaseNameLocalizations, ''' || p_culture || ''', NationalCaseValue.CaseName)';
        v_caseFieldName := 'GetLocalizedValue(NationalCaseValue.CaseFieldNameLocalizations, ''' || p_culture || ''', NationalCaseValue.CaseFieldName)';
        v_caseSlot      := 'GetLocalizedValue(NationalCaseValue.CaseSlotLocalizations, ''' || p_culture || ''', NationalCaseValue.CaseSlot)';
    END IF;

    v_attrSql  := BuildAttributeQuery('NationalCaseValue.Attributes', p_attributes);
    v_pivotSql := 'CREATE TEMP TABLE NationalCaseChangeValuePivot AS SELECT'
        || ' NationalCaseChange.TenantId,'
        || ' NationalCaseChange.Id AS CaseChangeId,'
        || ' NationalCaseChange.Created AS CaseChangeCreated,'
        || ' NationalCaseChange.Reason,'
        || ' NationalCaseChange.ValidationCaseName,'
        || ' NationalCaseChange.CancellationType,'
        || ' NationalCaseChange.CancellationId,'
        || ' NationalCaseChange.CancellationDate,'
        || ' NULL AS EmployeeId,'
        || ' NationalCaseChange.UserId,'
        || ' "User".Identifier AS UserIdentifier,'
        || ' NationalCaseChange.DivisionId,'
        || ' NationalCaseValue.Id,'
        || ' NationalCaseValue.Created,'
        || ' NationalCaseValue.Updated,'
        || ' NationalCaseValue.Status,'
        || ' ' || v_caseName      || ' AS CaseName,'
        || ' ' || v_caseFieldName || ' AS CaseFieldName,'
        || ' ' || v_caseSlot      || ' AS CaseSlot,'
        || ' NationalCaseValue.CaseRelation,'
        || ' NationalCaseValue.ValueType,'
        || ' NationalCaseValue.Value,'
        || ' NationalCaseValue.NumericValue,'
        || ' NationalCaseValue.Culture,'
        || ' NationalCaseValue.Start,'
        || ' NationalCaseValue.End,'
        || ' NationalCaseValue.Forecast,'
        || ' NationalCaseValue.Tags,'
        || ' NationalCaseValue.Attributes,'
        || ' (SELECT COUNT(*) FROM NationalCaseDocument WHERE CaseValueId = NationalCaseValue.Id) AS Documents'
        || v_attrSql
        || ' FROM NationalCaseValue'
        || ' LEFT JOIN NationalCaseValueChange ON NationalCaseValue.Id = NationalCaseValueChange.CaseValueId'
        || ' LEFT JOIN NationalCaseChange ON NationalCaseValueChange.CaseChangeId = NationalCaseChange.Id'
        || ' LEFT JOIN "User" ON "User".Id = NationalCaseChange.UserId'
        || ' WHERE NationalCaseChange.TenantId = ' || p_parentId::TEXT;

    DROP TABLE IF EXISTS NationalCaseChangeValuePivot;

    EXECUTE v_pivotSql;

    EXECUTE p_sql;

    DROP TABLE IF EXISTS NationalCaseChangeValuePivot;
EXCEPTION WHEN OTHERS THEN
    DROP TABLE IF EXISTS NationalCaseChangeValuePivot;
    RAISE;
END;
$$;

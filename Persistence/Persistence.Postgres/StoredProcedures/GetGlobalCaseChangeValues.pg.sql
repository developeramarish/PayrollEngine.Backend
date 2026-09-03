-- =============================================================================
-- GetGlobalCaseChangeValues
-- =============================================================================

CREATE OR REPLACE PROCEDURE GetGlobalCaseChangeValues(
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
        v_caseName      := 'GlobalCaseValue.CaseName';
        v_caseFieldName := 'GlobalCaseValue.CaseFieldName';
        v_caseSlot      := 'GlobalCaseValue.CaseSlot';
    ELSE
        v_caseName      := 'GetLocalizedValue(GlobalCaseValue.CaseNameLocalizations, ''' || p_culture || ''', GlobalCaseValue.CaseName)';
        v_caseFieldName := 'GetLocalizedValue(GlobalCaseValue.CaseFieldNameLocalizations, ''' || p_culture || ''', GlobalCaseValue.CaseFieldName)';
        v_caseSlot      := 'GetLocalizedValue(GlobalCaseValue.CaseSlotLocalizations, ''' || p_culture || ''', GlobalCaseValue.CaseSlot)';
    END IF;

    v_attrSql  := BuildAttributeQuery('GlobalCaseValue.Attributes', p_attributes);
    v_pivotSql := 'CREATE TEMP TABLE GlobalCaseChangeValuePivot AS SELECT'
        || ' GlobalCaseChange.TenantId,'
        || ' GlobalCaseChange.Id AS CaseChangeId,'
        || ' GlobalCaseChange.Created AS CaseChangeCreated,'
        || ' GlobalCaseChange.Reason,'
        || ' GlobalCaseChange.ValidationCaseName,'
        || ' GlobalCaseChange.CancellationType,'
        || ' GlobalCaseChange.CancellationId,'
        || ' GlobalCaseChange.CancellationDate,'
        || ' NULL AS EmployeeId,'
        || ' GlobalCaseChange.UserId,'
        || ' "User".Identifier AS UserIdentifier,'
        || ' GlobalCaseChange.DivisionId,'
        || ' GlobalCaseValue.Id,'
        || ' GlobalCaseValue.Created,'
        || ' GlobalCaseValue.Updated,'
        || ' GlobalCaseValue.Status,'
        || ' ' || v_caseName      || ' AS CaseName,'
        || ' ' || v_caseFieldName || ' AS CaseFieldName,'
        || ' ' || v_caseSlot      || ' AS CaseSlot,'
        || ' GlobalCaseValue.CaseRelation,'
        || ' GlobalCaseValue.ValueType,'
        || ' GlobalCaseValue.Value,'
        || ' GlobalCaseValue.NumericValue,'
        || ' GlobalCaseValue.Culture,'
        || ' GlobalCaseValue.Start,'
        || ' GlobalCaseValue.End,'
        || ' GlobalCaseValue.Forecast,'
        || ' GlobalCaseValue.Tags,'
        || ' GlobalCaseValue.Attributes,'
        || ' (SELECT COUNT(*) FROM GlobalCaseDocument WHERE CaseValueId = GlobalCaseValue.Id) AS Documents'
        || v_attrSql
        || ' FROM GlobalCaseValue'
        || ' LEFT JOIN GlobalCaseValueChange ON GlobalCaseValue.Id = GlobalCaseValueChange.CaseValueId'
        || ' LEFT JOIN GlobalCaseChange ON GlobalCaseValueChange.CaseChangeId = GlobalCaseChange.Id'
        || ' LEFT JOIN "User" ON "User".Id = GlobalCaseChange.UserId'
        || ' WHERE GlobalCaseChange.TenantId = ' || p_parentId::TEXT;

    DROP TABLE IF EXISTS GlobalCaseChangeValuePivot;

    EXECUTE v_pivotSql;

    EXECUTE p_sql;

    DROP TABLE IF EXISTS GlobalCaseChangeValuePivot;
EXCEPTION WHEN OTHERS THEN
    DROP TABLE IF EXISTS GlobalCaseChangeValuePivot;
    RAISE;
END;
$$;

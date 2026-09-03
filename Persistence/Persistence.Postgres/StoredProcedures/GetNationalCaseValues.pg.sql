-- =============================================================================
-- GetNationalCaseValues
-- =============================================================================

CREATE OR REPLACE PROCEDURE GetNationalCaseValues(
    IN p_parentId   INTEGER,
    IN p_sql        TEXT,
    IN p_attributes TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_attrSql  TEXT;
    v_pivotSql TEXT;
BEGIN
    v_attrSql  := BuildAttributeQuery('NationalCaseValue.Attributes', p_attributes);
    v_pivotSql := 'CREATE TEMP TABLE NationalCaseValuePivot AS SELECT NationalCaseValue.*'
        || v_attrSql
        || ' FROM NationalCaseValue WHERE NationalCaseValue.TenantId = '
        || p_parentId::TEXT;

    DROP TABLE IF EXISTS NationalCaseValuePivot;

    EXECUTE v_pivotSql;

    EXECUTE p_sql;

    DROP TABLE IF EXISTS NationalCaseValuePivot;
EXCEPTION WHEN OTHERS THEN
    DROP TABLE IF EXISTS NationalCaseValuePivot;
    RAISE;
END;
$$;

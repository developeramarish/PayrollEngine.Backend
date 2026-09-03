-- =============================================================================
-- GetCompanyCaseValues
-- =============================================================================

CREATE OR REPLACE PROCEDURE GetCompanyCaseValues(
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
    v_attrSql  := BuildAttributeQuery('CompanyCaseValue.Attributes', p_attributes);
    v_pivotSql := 'CREATE TEMP TABLE CompanyCaseValuePivot AS SELECT CompanyCaseValue.*'
        || v_attrSql
        || ' FROM CompanyCaseValue WHERE CompanyCaseValue.TenantId = '
        || p_parentId::TEXT;

    DROP TABLE IF EXISTS CompanyCaseValuePivot;

    EXECUTE v_pivotSql;

    EXECUTE p_sql;

    DROP TABLE IF EXISTS CompanyCaseValuePivot;
EXCEPTION WHEN OTHERS THEN
    DROP TABLE IF EXISTS CompanyCaseValuePivot;
    RAISE;
END;
$$;

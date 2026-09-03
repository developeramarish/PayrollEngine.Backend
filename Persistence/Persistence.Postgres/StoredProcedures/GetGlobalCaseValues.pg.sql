-- =============================================================================
-- GetGlobalCaseValues
-- Creates TEMP TABLE pivot + executes caller query against it.
-- =============================================================================

CREATE OR REPLACE PROCEDURE GetGlobalCaseValues(
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
    v_attrSql  := BuildAttributeQuery('GlobalCaseValue.Attributes', p_attributes);
    v_pivotSql := 'CREATE TEMP TABLE GlobalCaseValuePivot AS SELECT GlobalCaseValue.*'
        || v_attrSql
        || ' FROM GlobalCaseValue WHERE GlobalCaseValue.TenantId = '
        || p_parentId::TEXT;

    DROP TABLE IF EXISTS GlobalCaseValuePivot;

    EXECUTE v_pivotSql;

    EXECUTE p_sql;

    DROP TABLE IF EXISTS GlobalCaseValuePivot;
EXCEPTION WHEN OTHERS THEN
    DROP TABLE IF EXISTS GlobalCaseValuePivot;
    RAISE;
END;
$$;

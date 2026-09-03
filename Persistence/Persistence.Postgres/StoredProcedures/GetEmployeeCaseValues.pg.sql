-- =============================================================================
-- GetEmployeeCaseValues
-- Filter is EmployeeId (not TenantId) -- employee-scoped pivot
-- =============================================================================

CREATE OR REPLACE PROCEDURE GetEmployeeCaseValues(
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
    v_attrSql  := BuildAttributeQuery('EmployeeCaseValue.Attributes', p_attributes);
    v_pivotSql := 'CREATE TEMP TABLE EmployeeCaseValuePivot AS SELECT EmployeeCaseValue.*'
        || v_attrSql
        || ' FROM EmployeeCaseValue WHERE EmployeeCaseValue.EmployeeId = '
        || p_parentId::TEXT;

    DROP TABLE IF EXISTS EmployeeCaseValuePivot;

    EXECUTE v_pivotSql;

    EXECUTE p_sql;

    DROP TABLE IF EXISTS EmployeeCaseValuePivot;
EXCEPTION WHEN OTHERS THEN
    DROP TABLE IF EXISTS EmployeeCaseValuePivot;
    RAISE;
END;
$$;

-- =============================================================================
-- DeleteAllEmployeeCaseValues
-- =============================================================================

CREATE OR REPLACE PROCEDURE DeleteAllEmployeeCaseValues()
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM EmployeeCaseValueChange;
    DELETE FROM EmployeeCaseDocument;
    DELETE FROM EmployeeCaseValue;
    DELETE FROM EmployeeCaseChange;
END;
$$;

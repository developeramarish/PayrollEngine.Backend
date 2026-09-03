-- =============================================================================
-- DeleteAllCaseValues
-- Delegates to the four scope-specific procedures.
-- =============================================================================

CREATE OR REPLACE PROCEDURE DeleteAllCaseValues()
LANGUAGE plpgsql
AS $$
BEGIN
    CALL DeleteAllGlobalCaseValues();
    CALL DeleteAllNationalCaseValues();
    CALL DeleteAllCompanyCaseValues();
    CALL DeleteAllEmployeeCaseValues();
END;
$$;

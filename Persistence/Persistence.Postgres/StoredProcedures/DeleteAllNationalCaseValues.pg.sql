-- =============================================================================
-- DeleteAllNationalCaseValues
-- =============================================================================

CREATE OR REPLACE PROCEDURE DeleteAllNationalCaseValues()
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM "NationalCaseValueChange";
    DELETE FROM "NationalCaseDocument";
    DELETE FROM "NationalCaseValue";
    DELETE FROM "NationalCaseChange";
END;
$$;

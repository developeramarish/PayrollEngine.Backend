-- =============================================================================
-- DeleteAllCompanyCaseValues
-- =============================================================================

CREATE OR REPLACE PROCEDURE DeleteAllCompanyCaseValues()
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM "CompanyCaseValueChange";
    DELETE FROM "CompanyCaseDocument";
    DELETE FROM "CompanyCaseValue";
    DELETE FROM "CompanyCaseChange";
END;
$$;

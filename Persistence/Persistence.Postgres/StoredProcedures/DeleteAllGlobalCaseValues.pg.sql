-- =============================================================================
-- DeleteAllGlobalCaseValues
-- =============================================================================

CREATE OR REPLACE PROCEDURE DeleteAllGlobalCaseValues()
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM "GlobalCaseValueChange";
    DELETE FROM "GlobalCaseDocument";
    DELETE FROM "GlobalCaseValue";
    DELETE FROM "GlobalCaseChange";
END;
$$;

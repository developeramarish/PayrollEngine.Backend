-- =============================================================================
-- GetAttributeNames
-- Builds a comma-separated list of attribute names from a JSON array.
-- Used by GetPayrollResultValues for the outer SELECT projection.
--
-- T-SQL: imperative WHILE + OPENJSON + string concatenation
-- MySQL: JSON_TABLE with FOR ORDINALITY + GROUP_CONCAT
-- PostgreSQL: jsonb_array_elements_text WITH ORDINALITY + STRING_AGG
--
-- Output: '' if empty, ',' + names + newline if non-empty
-- =============================================================================

CREATE OR REPLACE FUNCTION GetAttributeNames(
    p_attributes TEXT
)
RETURNS TEXT
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_parts TEXT;
    v_sql   TEXT DEFAULT '';
BEGIN
    IF p_attributes IS NULL THEN
        RETURN v_sql;
    END IF;

    IF jsonb_array_length(p_attributes::jsonb) = 0 THEN
        RETURN v_sql;
    END IF;

    SELECT STRING_AGG(j.val, ', ' ORDER BY j.idx)
    INTO v_parts
    FROM jsonb_array_elements_text(p_attributes::jsonb) WITH ORDINALITY AS j(val, idx)
    WHERE LENGTH(TRIM(j.val)) > 0;

    IF v_parts IS NOT NULL AND LENGTH(v_parts) > 0 THEN
        v_sql := ',' || v_parts || E'\n        ';
    END IF;

    RETURN v_sql;
END;
$$;

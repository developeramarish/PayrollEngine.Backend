-- =============================================================================
-- GetNumericAttributeValue
-- Returns NUMERIC(28,6) value of a JSON attribute, NULL if not numeric.
--
-- T-SQL: RETURN IIF(@type = 2, CAST(@value AS DECIMAL(28,6)), NULL)
-- MySQL: JSON_TYPE checks for 'INTEGER' or 'DOUBLE'
-- PostgreSQL: jsonb_typeof checks for 'number'
-- =============================================================================

CREATE OR REPLACE FUNCTION GetNumericAttributeValue(
    p_attributes TEXT,
    p_name       VARCHAR(255)
)
RETURNS NUMERIC(28,6)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_type TEXT;
BEGIN
    IF p_attributes IS NULL OR p_name IS NULL THEN
        RETURN NULL;
    END IF;

    v_type := jsonb_typeof(p_attributes::jsonb -> p_name);

    IF v_type = 'number' THEN
        RETURN (p_attributes::jsonb ->> p_name)::NUMERIC(28,6);
    END IF;

    RETURN NULL;
END;
$$;

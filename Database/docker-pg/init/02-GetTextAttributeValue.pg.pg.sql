-- =============================================================================
-- GetTextAttributeValue
-- Returns the string value of a JSON attribute key, NULL if type is not string.
--
-- T-SQL: RETURN IIF(@type = 1, @value, NULL)  -- type 1 = string in OPENJSON
-- MySQL: JSON_EXTRACT + JSON_TYPE check for 'STRING'
-- PostgreSQL: jsonb_typeof check for 'string'
-- =============================================================================

CREATE OR REPLACE FUNCTION GetTextAttributeValue(
    p_attributes TEXT,
    p_name       VARCHAR(255)
)
RETURNS TEXT
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

    IF v_type = 'string' THEN
        RETURN p_attributes::jsonb ->> p_name;
    END IF;

    RETURN NULL;
END;
$$;

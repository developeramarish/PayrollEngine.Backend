-- =============================================================================
-- GetDateAttributeValue
-- Returns TIMESTAMP(6) from a JSON attribute stored as ISO 8601 string.
-- NULL if attribute is not a string or not parseable as timestamp.
--
-- T-SQL: RETURN IIF(@type = 1, CAST(@value AS DATETIME2(7)), NULL)
-- MySQL: JSON_TYPE='STRING' + CAST AS DATETIME(6)
-- PostgreSQL: jsonb_typeof='string' + CAST AS TIMESTAMP(6)
-- =============================================================================

CREATE OR REPLACE FUNCTION GetDateAttributeValue(
    p_attributes TEXT,
    p_name       VARCHAR(255)
)
RETURNS TIMESTAMP(6)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_type TEXT;
    v_raw  VARCHAR(50);
BEGIN
    IF p_attributes IS NULL OR p_name IS NULL THEN
        RETURN NULL;
    END IF;

    v_type := jsonb_typeof(p_attributes::jsonb -> p_name);

    IF v_type = 'string' THEN
        v_raw := p_attributes::jsonb ->> p_name;
        RETURN v_raw::TIMESTAMP(6);
    END IF;

    RETURN NULL;
END;
$$;

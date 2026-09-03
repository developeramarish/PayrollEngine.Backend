-- =============================================================================
-- GetLocalizedValue
-- Returns the value for the given culture from a JSON localizations object.
-- Falls back to p_fallback if culture key not found.
--
-- T-SQL: SELECT @value = value FROM OPENJSON(@localizations) WHERE [key] = @culture
-- MySQL: JSON_EXTRACT with quoted key syntax $."de-CH" (handles hyphens)
-- PostgreSQL: jsonb ->> key operator (handles any key including hyphens)
--
-- IMPORTANT: Culture codes like "de-CH" contain a hyphen.
-- MySQL requires quoted path $."de-CH". PostgreSQL's ->> operator handles
-- any key natively without quoting concerns.
-- =============================================================================

CREATE OR REPLACE FUNCTION GetLocalizedValue(
    p_localizations TEXT,
    p_culture       VARCHAR(128),
    p_fallback      TEXT
)
RETURNS TEXT
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_value TEXT;
BEGIN
    IF p_localizations IS NULL OR p_culture IS NULL THEN
        RETURN p_fallback;
    END IF;

    v_value := p_localizations::jsonb ->> p_culture;

    IF v_value IS NULL THEN
        RETURN p_fallback;
    END IF;

    RETURN v_value;
END;
$$;

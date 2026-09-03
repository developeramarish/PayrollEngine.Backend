-- =============================================================================
-- BuildAttributeQuery
-- Builds a SQL fragment for dynamic attribute column projection.
-- Used by CaseValue pivot SPs and GetPayrollResultValues.
--
-- T-SQL: imperative WHILE + OPENJSON + string concatenation
-- MySQL: JSON_TABLE with FOR ORDINALITY + GROUP_CONCAT (order preserved)
-- PostgreSQL: jsonb_array_elements_text WITH ORDINALITY + STRING_AGG
--
-- Output: '' if empty, ',' + fragment + newline if attributes present
--
-- Attribute prefix convention:
--   TA_ -> GetTextAttributeValue(field, 'name') AS TA_xxx
--   NA_ -> GetNumericAttributeValue(field, 'name') AS NA_xxx
--   DA_ -> GetDateAttributeValue(field, 'name') AS DA_xxx
--   NULL field -> NULL AS xxx  (PayrunResult has no attribute field)
--
-- NOTE: Attribute JSON keys are plain names ("City"), not prefixed ("TA_City").
-- The TA_/NA_/DA_ prefix is the output column alias only.
-- =============================================================================

CREATE OR REPLACE FUNCTION BuildAttributeQuery(
    p_attributeField TEXT,
    p_attributes     TEXT
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

    SELECT STRING_AGG(
        CASE
            WHEN p_attributeField IS NULL THEN
                'NULL AS ' || j.val
            WHEN LEFT(j.val, 3) = 'TA_' THEN
                'GetTextAttributeValue(' || p_attributeField || ', ''' || SUBSTRING(j.val, 4) || ''') AS ' || j.val
            WHEN LEFT(j.val, 3) = 'DA_' THEN
                'GetDateAttributeValue(' || p_attributeField || ', ''' || SUBSTRING(j.val, 4) || ''') AS ' || j.val
            WHEN LEFT(j.val, 3) = 'NA_' THEN
                'GetNumericAttributeValue(' || p_attributeField || ', ''' || SUBSTRING(j.val, 4) || ''') AS ' || j.val
            ELSE NULL
        END
        , ', ' ORDER BY j.idx
    )
    INTO v_parts
    FROM jsonb_array_elements_text(p_attributes::jsonb) WITH ORDINALITY AS j(val, idx)
    WHERE LENGTH(TRIM(j.val)) > 0;

    IF v_parts IS NOT NULL AND LENGTH(v_parts) > 0 THEN
        v_sql := ',' || v_parts || E'\n        ';
    END IF;

    RETURN v_sql;
END;
$$;

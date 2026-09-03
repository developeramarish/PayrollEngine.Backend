-- =============================================================================
-- GetLookupRangeValue
-- =============================================================================

CREATE OR REPLACE PROCEDURE GetLookupRangeValue(
    IN p_lookupId   INTEGER,
    IN p_rangeValue DECIMAL(28,6),
    IN p_keyHash    INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_rangeSize DECIMAL(28,6) DEFAULT 0.0;
    v_minValue  DECIMAL(28,6);
    v_maxValue  DECIMAL(28,6);
BEGIN
    SELECT COALESCE(RangeSize, 0.0) INTO v_rangeSize
    FROM Lookup WHERE Id = p_lookupId;

    SELECT MIN(lv.RangeValue), MAX(lv.RangeValue) + v_rangeSize
    INTO v_minValue, v_maxValue
    FROM LookupValue lv
    INNER JOIN Lookup lk ON lv.LookupId = lk.Id
    WHERE lk.Id = p_lookupId;

    IF v_minValue IS NULL
       OR p_rangeValue < v_minValue
       OR p_rangeValue > v_maxValue THEN
        RETURN QUERY SELECT * FROM LookupValue WHERE 1 = 0;
    ELSE
        RETURN QUERY
        SELECT lv.*
        FROM LookupValue lv
        INNER JOIN Lookup lk ON lv.LookupId = lk.Id
        WHERE lk.Id = p_lookupId
          AND lv.RangeValue <= p_rangeValue
          AND (p_keyHash IS NULL OR lv.KeyHash = p_keyHash)
        ORDER BY lv.RangeValue DESC
        LIMIT 1;
    END IF;
END;
$$;

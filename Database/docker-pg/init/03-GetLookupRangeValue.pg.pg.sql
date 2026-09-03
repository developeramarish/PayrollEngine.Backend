-- =============================================================================
-- GetLookupRangeValue
-- Returns the single LookupValue row whose RangeValue <= p_rangeValue
-- (highest match), optionally filtered by KeyHash.
-- Returns an empty set when rangeValue is outside [min, max+rangeSize].
-- =============================================================================

DROP PROCEDURE IF EXISTS GetLookupRangeValue;

CREATE OR REPLACE FUNCTION "GetLookupRangeValue"(
    IN "lookupId"   INTEGER,
    IN "rangeValue" DECIMAL(28,6),
    IN "keyHash"    INTEGER
)
RETURNS TABLE(
    "Id"                 INTEGER,
    "Status"             INTEGER,
    "Created"            TIMESTAMP(6),
    "Updated"            TIMESTAMP(6),
    "LookupId"           INTEGER,
    "Key"                TEXT,
    "KeyHash"            INTEGER,
    "RangeValue"         DECIMAL(28,6),
    "Value"              TEXT,
    "ValueLocalizations" TEXT,
    "OverrideType"       INTEGER,
    "LookupHash"         INTEGER
)
LANGUAGE plpgsql STABLE AS $$
DECLARE
    v_rangeSize DECIMAL(28,6) DEFAULT 0.0;
    v_minValue  DECIMAL(28,6);
    v_maxValue  DECIMAL(28,6);
BEGIN
    SELECT COALESCE(lk."RangeSize", 0.0) INTO v_rangeSize
    FROM "Lookup" lk WHERE lk."Id" = "lookupId";

    SELECT MIN(lv."RangeValue"), MAX(lv."RangeValue") + v_rangeSize
    INTO v_minValue, v_maxValue
    FROM "LookupValue" lv
    INNER JOIN "Lookup" lk ON lv."LookupId" = lk."Id"
    WHERE lk."Id" = "lookupId";

    IF v_minValue IS NULL
       OR "rangeValue" < v_minValue
       OR "rangeValue" > v_maxValue THEN
        RETURN;
    ELSE
        RETURN QUERY
        SELECT
            lv."Id",
            lv."Status",
            lv."Created",
            lv."Updated",
            lv."LookupId",
            lv."Key",
            lv."KeyHash",
            lv."RangeValue",
            lv."Value",
            lv."ValueLocalizations",
            lv."OverrideType",
            lv."LookupHash"
        FROM "LookupValue" lv
        INNER JOIN "Lookup" lk ON lv."LookupId" = lk."Id"
        WHERE lk."Id" = "lookupId"
          AND lv."RangeValue" <= "rangeValue"
          AND ("keyHash" IS NULL OR lv."KeyHash" = "keyHash")
        ORDER BY lv."RangeValue" DESC
        LIMIT 1;
    END IF;
END;
$$;

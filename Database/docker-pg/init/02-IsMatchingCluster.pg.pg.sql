-- =============================================================================
-- IsMatchingCluster
-- Tests include/exclude cluster filters against a test cluster array.
-- All arrays are JSON arrays of VARCHAR(128).
--
-- T-SQL: imperative WHILE loop over OPENJSON
-- MySQL: set-based JSON_TABLE + EXISTS / NOT EXISTS
-- PostgreSQL: jsonb_array_elements_text + EXISTS / NOT EXISTS
--
-- Logic:
--   include: every cluster in includeClusters must appear in testClusters
--   exclude: no cluster in excludeClusters may appear in testClusters
--   returns 1 (match) or 0 (no match)
-- =============================================================================

CREATE OR REPLACE FUNCTION IsMatchingCluster(
    p_includeClusters VARCHAR(4000),
    p_excludeClusters VARCHAR(4000),
    p_testClusters    VARCHAR(4000)
)
RETURNS INTEGER
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_testClusters VARCHAR(4000);
BEGIN
    v_testClusters := COALESCE(p_testClusters, '[]');

    IF p_includeClusters IS NOT NULL AND jsonb_array_length(p_includeClusters::jsonb) > 0 THEN
        IF EXISTS (
            SELECT 1
            FROM jsonb_array_elements_text(p_includeClusters::jsonb) AS inc(val)
            WHERE LENGTH(TRIM(inc.val)) > 0
              AND NOT EXISTS (
                SELECT 1
                FROM jsonb_array_elements_text(v_testClusters::jsonb) AS tst(val)
                WHERE tst.val = inc.val)
        ) THEN
            RETURN 0;
        END IF;
    END IF;

    IF p_excludeClusters IS NOT NULL AND jsonb_array_length(p_excludeClusters::jsonb) > 0 THEN
        IF EXISTS (
            SELECT 1
            FROM jsonb_array_elements_text(p_excludeClusters::jsonb) AS exc(val)
            WHERE LENGTH(TRIM(exc.val)) > 0
              AND EXISTS (
                SELECT 1
                FROM jsonb_array_elements_text(v_testClusters::jsonb) AS tst(val)
                WHERE tst.val = exc.val)
        ) THEN
            RETURN 0;
        END IF;
    END IF;

    RETURN 1;
END;
$$;

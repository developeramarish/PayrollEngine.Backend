-- =============================================================================
-- UpdateStatistics
-- T-SQL: UPDATE STATISTICS ... WITH FULLSCAN -> MySQL: ANALYZE TABLE -> PG: ANALYZE
-- =============================================================================

CREATE OR REPLACE PROCEDURE UpdateStatistics()
LANGUAGE plpgsql
AS $$
DECLARE
    v_table TEXT;
BEGIN
    FOR v_table IN
        SELECT tablename FROM pg_catalog.pg_tables
        WHERE schemaname = 'public'
    LOOP
        EXECUTE 'ANALYZE ' || v_table;
    END LOOP;
END;
$$;

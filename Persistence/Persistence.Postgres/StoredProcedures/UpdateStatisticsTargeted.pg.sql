-- =============================================================================
-- UpdateStatisticsTargeted
-- T-SQL: UPDATE STATISTICS ... WITH FULLSCAN -> MySQL: ANALYZE TABLE -> PG: ANALYZE
-- =============================================================================

CREATE OR REPLACE PROCEDURE UpdateStatisticsTargeted()
LANGUAGE plpgsql
AS $$
BEGIN
    ANALYZE "LookupValue";
    ANALYZE "PayrollResult";
    ANALYZE "WageTypeResult";
    ANALYZE "WageTypeCustomResult";
    ANALYZE "CollectorResult";
    ANALYZE "CollectorCustomResult";
    ANALYZE "PayrunResult";
    ANALYZE "GlobalCaseValue";
    ANALYZE "NationalCaseValue";
    ANALYZE "CompanyCaseValue";
    ANALYZE "EmployeeCaseValue";
END;
$$;

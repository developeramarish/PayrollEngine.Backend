-- =============================================================================
-- GetConsolidatedCollectorCustomResults
-- =============================================================================

CREATE OR REPLACE PROCEDURE GetConsolidatedCollectorCustomResults(
    IN p_tenantId            INTEGER,
    IN p_employeeId          INTEGER,
    IN p_divisionId          INTEGER,
    IN p_collectorNameHashes TEXT,
    IN p_periodStartHashes   TEXT,
    IN p_jobStatus           INTEGER,
    IN p_forecast            TEXT,
    IN p_evaluationDate      TIMESTAMP(6),
    IN p_noRetro             BOOLEAN,
    IN p_excludeParentJobId  INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_collectorNameHash INTEGER;
    v_collectorCount    INTEGER;
    v_startHash         INTEGER;
    v_startHashCount    INTEGER;
BEGIN
    v_collectorCount := CASE WHEN p_collectorNameHashes IS NULL THEN 0 ELSE jsonb_array_length(p_collectorNameHashes::jsonb) END;
    v_startHashCount := CASE WHEN p_periodStartHashes IS NULL   THEN 0 ELSE jsonb_array_length(p_periodStartHashes::jsonb) END;

    IF v_collectorCount = 1 THEN
        SELECT CAST(jt.val AS INTEGER) INTO v_collectorNameHash
        FROM jsonb_array_elements_text(p_collectorNameHashes::jsonb) AS jt(val) LIMIT 1;
    END IF;

    IF v_startHashCount = 1 THEN
        SELECT CAST(jt.val AS INTEGER) INTO v_startHash
        FROM jsonb_array_elements_text(p_periodStartHashes::jsonb) AS jt(val) LIMIT 1;
    END IF;

    RETURN QUERY
    WITH Winners AS (
        SELECT r.Id,
            ROW_NUMBER() OVER (
                PARTITION BY r.CollectorNameHash, r.Start
                ORDER BY r.Created DESC, r.Id DESC
            ) AS RowNumber
        FROM CollectorCustomResult r
        WHERE r.TenantId = p_tenantId
          AND r.EmployeeId = p_employeeId
          AND (v_startHashCount = 0 OR
               (v_startHashCount = 1 AND r.StartHash = v_startHash) OR
               (v_startHashCount > 1 AND r.StartHash IN (
                   SELECT CAST(jt.val AS INTEGER)
                   FROM jsonb_array_elements_text(p_periodStartHashes::jsonb) AS jt(val))))
          AND (p_divisionId IS NULL OR r.DivisionId = p_divisionId)
          AND (p_collectorNameHashes IS NULL OR v_collectorCount = 0
               OR (v_collectorCount = 1 AND r.CollectorNameHash = v_collectorNameHash)
               OR (v_collectorCount > 1 AND r.CollectorNameHash IN (
                   SELECT CAST(jt.val AS INTEGER)
                   FROM jsonb_array_elements_text(p_collectorNameHashes::jsonb) AS jt(val))))
          AND (p_evaluationDate IS NULL OR r.Created <= p_evaluationDate)
          AND (p_jobStatus IS NULL OR r.PayrunJobId IN (
                   SELECT pj.Id FROM PayrunJob pj WHERE (pj.JobStatus & p_jobStatus) = pj.JobStatus))
          AND (r.Forecast IS NULL OR r.Forecast = p_forecast)
          AND (p_noRetro = FALSE OR r.ParentJobId IS NULL)
          AND (p_excludeParentJobId IS NULL OR r.ParentJobId IS NULL
               OR r.ParentJobId <> p_excludeParentJobId)
    )
    SELECT r.*
    FROM CollectorCustomResult r
    INNER JOIN Winners w ON w.Id = r.Id
    WHERE w.RowNumber = 1;
END;
$$;

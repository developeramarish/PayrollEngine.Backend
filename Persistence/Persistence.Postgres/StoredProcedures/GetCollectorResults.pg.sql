-- =============================================================================
-- GetCollectorResults
-- =============================================================================

CREATE OR REPLACE PROCEDURE GetCollectorResults(
    IN p_tenantId            INTEGER,
    IN p_employeeId          INTEGER,
    IN p_divisionId          INTEGER,
    IN p_payrunJobId         INTEGER,
    IN p_parentPayrunJobId   INTEGER,
    IN p_collectorNameHashes TEXT,
    IN p_periodStart         TIMESTAMP(6),
    IN p_periodEnd           TIMESTAMP(6),
    IN p_jobStatus           INTEGER,
    IN p_forecast            TEXT,
    IN p_evaluationDate      TIMESTAMP(6)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_collectorNameHash INTEGER;
    v_collectorCount    INTEGER;
BEGIN
    v_collectorCount := CASE WHEN p_collectorNameHashes IS NULL THEN 0
                             ELSE jsonb_array_length(p_collectorNameHashes::jsonb) END;

    IF v_collectorCount = 1 THEN
        SELECT CAST(jt.val AS INTEGER) INTO v_collectorNameHash
        FROM jsonb_array_elements_text(p_collectorNameHashes::jsonb) AS jt(val)
        LIMIT 1;
    END IF;

    RETURN QUERY
    SELECT cr.*
    FROM CollectorResult cr
    WHERE cr.TenantId = p_tenantId
      AND cr.EmployeeId = p_employeeId
      AND (p_divisionId IS NULL        OR cr.DivisionId = p_divisionId)
      AND (p_payrunJobId IS NULL       OR cr.PayrunJobId = p_payrunJobId)
      AND (p_parentPayrunJobId IS NULL OR cr.ParentJobId = p_parentPayrunJobId)
      AND (p_collectorNameHashes IS NULL OR v_collectorCount = 0
           OR (v_collectorCount = 1 AND cr.CollectorNameHash = v_collectorNameHash)
           OR (v_collectorCount > 1 AND cr.CollectorNameHash IN (
               SELECT CAST(jt.val AS INTEGER)
               FROM jsonb_array_elements_text(p_collectorNameHashes::jsonb) AS jt(val))))
      AND (p_periodStart IS NULL OR cr.Start BETWEEN p_periodStart AND p_periodEnd)
      AND (p_jobStatus IS NULL OR cr.PayrunJobId IN (
               SELECT pj.Id FROM PayrunJob pj
               WHERE pj.Id = cr.PayrunJobId
                 AND (pj.JobStatus & p_jobStatus) = pj.JobStatus))
      AND (cr.Forecast IS NULL OR cr.Forecast = p_forecast)
      AND (p_evaluationDate IS NULL OR cr.Created <= p_evaluationDate)
    ORDER BY cr.Created;
END;
$$;

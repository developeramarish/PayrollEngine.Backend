-- =============================================================================
-- GetWageTypeResults
-- =============================================================================

CREATE OR REPLACE PROCEDURE GetWageTypeResults(
    IN p_tenantId          INTEGER,
    IN p_employeeId        INTEGER,
    IN p_divisionId        INTEGER,
    IN p_payrunJobId       INTEGER,
    IN p_parentPayrunJobId INTEGER,
    IN p_wageTypeNumbers   TEXT,
    IN p_periodStart       TIMESTAMP(6),
    IN p_periodEnd         TIMESTAMP(6),
    IN p_jobStatus         INTEGER,
    IN p_forecast          TEXT,
    IN p_evaluationDate    TIMESTAMP(6)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_wageTypeNumber DECIMAL(28,6);
    v_wageTypeCount  INTEGER;
BEGIN
    v_wageTypeCount := CASE WHEN p_wageTypeNumbers IS NULL THEN 0
                            ELSE jsonb_array_length(p_wageTypeNumbers::jsonb) END;

    IF v_wageTypeCount = 1 THEN
        SELECT CAST(jt.val AS DECIMAL(28,6)) INTO v_wageTypeNumber
        FROM jsonb_array_elements_text(p_wageTypeNumbers::jsonb) AS jt(val)
        LIMIT 1;
    END IF;

    RETURN QUERY
    SELECT wtr.*
    FROM WageTypeResult wtr
    WHERE wtr.TenantId = p_tenantId
      AND wtr.EmployeeId = p_employeeId
      AND (p_divisionId IS NULL        OR wtr.DivisionId = p_divisionId)
      AND (p_payrunJobId IS NULL       OR wtr.PayrunJobId = p_payrunJobId)
      AND (p_parentPayrunJobId IS NULL OR wtr.ParentJobId = p_parentPayrunJobId)
      AND (p_wageTypeNumbers IS NULL OR v_wageTypeCount = 0
           OR (v_wageTypeCount = 1 AND wtr.WageTypeNumber = v_wageTypeNumber)
           OR (v_wageTypeCount > 1 AND wtr.WageTypeNumber IN (
               SELECT CAST(jt.val AS DECIMAL(28,6))
               FROM jsonb_array_elements_text(p_wageTypeNumbers::jsonb) AS jt(val))))
      AND (p_periodStart IS NULL OR wtr.Start BETWEEN p_periodStart AND p_periodEnd)
      AND (p_jobStatus IS NULL OR wtr.PayrunJobId IN (
               SELECT pj.Id FROM PayrunJob pj
               WHERE pj.Id = wtr.PayrunJobId
                 AND (pj.JobStatus & p_jobStatus) = pj.JobStatus))
      AND (wtr.Forecast IS NULL OR wtr.Forecast = p_forecast)
      AND (p_evaluationDate IS NULL OR wtr.Created <= p_evaluationDate)
    ORDER BY wtr.Created;
END;
$$;

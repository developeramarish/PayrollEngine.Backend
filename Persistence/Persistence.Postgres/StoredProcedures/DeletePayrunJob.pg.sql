-- =============================================================================
-- DeletePayrunJob
-- =============================================================================

CREATE OR REPLACE PROCEDURE DeletePayrunJob(
    IN p_tenantId    INTEGER,
    IN p_payrunJobId INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM PayrunResult pr
    USING PayrollResult prl
    WHERE pr.PayrollResultId = prl.Id
      AND prl.TenantId = p_tenantId AND prl.PayrunJobId = p_payrunJobId;

    DELETE FROM WageTypeCustomResult wtcr
    USING WageTypeResult wtr, PayrollResult prl
    WHERE wtcr.WageTypeResultId = wtr.Id
      AND wtr.PayrollResultId = prl.Id
      AND prl.TenantId = p_tenantId AND prl.PayrunJobId = p_payrunJobId;

    DELETE FROM WageTypeResult wtr
    USING PayrollResult prl
    WHERE wtr.PayrollResultId = prl.Id
      AND prl.TenantId = p_tenantId AND prl.PayrunJobId = p_payrunJobId;

    DELETE FROM CollectorCustomResult ccr
    USING CollectorResult cr, PayrollResult prl
    WHERE ccr.CollectorResultId = cr.Id
      AND cr.PayrollResultId = prl.Id
      AND prl.TenantId = p_tenantId AND prl.PayrunJobId = p_payrunJobId;

    DELETE FROM CollectorResult cr
    USING PayrollResult prl
    WHERE cr.PayrollResultId = prl.Id
      AND prl.TenantId = p_tenantId AND prl.PayrunJobId = p_payrunJobId;

    DELETE FROM PayrollResult WHERE TenantId = p_tenantId AND PayrunJobId = p_payrunJobId;

    DELETE FROM PayrunJobEmployee pje
    USING PayrunJob pj
    WHERE pje.PayrunJobId = pj.Id
      AND pj.TenantId = p_tenantId AND pje.PayrunJobId = p_payrunJobId;

    DELETE FROM PayrunJob WHERE TenantId = p_tenantId AND Id = p_payrunJobId;
END;
$$;

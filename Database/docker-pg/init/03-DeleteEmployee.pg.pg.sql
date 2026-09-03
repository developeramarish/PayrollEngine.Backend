-- =============================================================================
-- DeleteEmployee
-- MySQL: DELETE t FROM t INNER JOIN -> PG: DELETE FROM t USING ...
-- =============================================================================

CREATE OR REPLACE PROCEDURE DeleteEmployee(
    IN p_tenantId   INTEGER,
    IN p_employeeId INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM PayrunResult pr
    USING PayrollResult prl
    WHERE pr.PayrollResultId = prl.Id
      AND prl.TenantId = p_tenantId AND prl.EmployeeId = p_employeeId;

    DELETE FROM WageTypeCustomResult wtcr
    USING WageTypeResult wtr, PayrollResult prl
    WHERE wtcr.WageTypeResultId = wtr.Id
      AND wtr.PayrollResultId = prl.Id
      AND prl.TenantId = p_tenantId AND prl.EmployeeId = p_employeeId;

    DELETE FROM WageTypeResult wtr
    USING PayrollResult prl
    WHERE wtr.PayrollResultId = prl.Id
      AND prl.TenantId = p_tenantId AND prl.EmployeeId = p_employeeId;

    DELETE FROM CollectorCustomResult ccr
    USING CollectorResult cr, PayrollResult prl
    WHERE ccr.CollectorResultId = cr.Id
      AND cr.PayrollResultId = prl.Id
      AND prl.TenantId = p_tenantId AND prl.EmployeeId = p_employeeId;

    DELETE FROM CollectorResult cr
    USING PayrollResult prl
    WHERE cr.PayrollResultId = prl.Id
      AND prl.TenantId = p_tenantId AND prl.EmployeeId = p_employeeId;

    DELETE FROM PayrollResult WHERE TenantId = p_tenantId AND EmployeeId = p_employeeId;

    DELETE FROM PayrunJobEmployee pje
    USING PayrunJob pj
    WHERE pje.PayrunJobId = pj.Id
      AND pj.TenantId = p_tenantId AND pje.EmployeeId = p_employeeId;

    DELETE FROM EmployeeCaseValueChange ecvc
    USING EmployeeCaseChange ecc, Employee e
    WHERE ecvc.CaseChangeId = ecc.Id
      AND ecc.EmployeeId = e.Id
      AND e.TenantId = p_tenantId AND e.Id = p_employeeId;

    DELETE FROM EmployeeCaseChange ecc
    USING Employee e
    WHERE ecc.EmployeeId = e.Id
      AND e.TenantId = p_tenantId AND e.Id = p_employeeId;

    DELETE FROM EmployeeCaseDocument ecd
    USING EmployeeCaseValue ecv, Employee e
    WHERE ecd.CaseValueId = ecv.Id
      AND ecv.EmployeeId = e.Id
      AND e.TenantId = p_tenantId AND e.Id = p_employeeId;

    DELETE FROM EmployeeCaseValue ecv
    USING Employee e
    WHERE ecv.EmployeeId = e.Id
      AND e.TenantId = p_tenantId AND e.Id = p_employeeId;

    DELETE FROM EmployeeDivision ed
    USING Employee e
    WHERE ed.EmployeeId = e.Id
      AND e.TenantId = p_tenantId AND e.Id = p_employeeId;

    DELETE FROM Employee WHERE TenantId = p_tenantId AND Id = p_employeeId;
END;
$$;

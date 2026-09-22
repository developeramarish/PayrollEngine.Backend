-- =============================================================================
-- GetDerivedLookupValues
-- lv.`Key` backtick-quoted (reserved keyword in MySQL)
-- Case-sensitive key filter (no LOWER(), identical to T-SQL)
-- =============================================================================

USE PayrollEngine;

DELIMITER $$

DROP PROCEDURE IF EXISTS GetDerivedLookupValues$$
CREATE PROCEDURE GetDerivedLookupValues(
    IN p_tenantId       INT,
    IN p_payrollId      INT,
    IN p_regulationDate DATETIME(6),
    IN p_createdBefore  DATETIME(6),
    IN p_lookupNames    VARCHAR(4000),
    IN p_lookupKeys     VARCHAR(4000)
)
BEGIN
    WITH DerivedRegulations AS (
        SELECT r.Id, pl.Level, pl.Priority,
            ROW_NUMBER() OVER (
                PARTITION BY pl.Id, r.Name
                ORDER BY r.ValidFrom DESC, r.Created DESC
            ) AS RowNumber
        FROM PayrollLayer pl
        INNER JOIN Regulation r ON pl.RegulationName = r.Name
        WHERE r.Status = 0
          AND (
            r.TenantId = p_tenantId
            -- shared regulation: IsolationLevel must be >= Write to act as payroll layer.
            -- Match by regulation NAME so a single RegulationShare entry covers all
            -- ValidFrom versions of the same regulation family (e.g. 2025 and 2026).
            OR (
              r.SharedRegulation = 1
              AND EXISTS (
                SELECT 1 FROM RegulationShare rs
                INNER JOIN Regulation rp ON rs.ProviderRegulationId = rp.Id
                WHERE rp.Name             = r.Name
                  AND rs.ConsumerTenantId = p_tenantId
                  AND rs.IsolationLevel   >= 3  -- TenantIsolationLevel.Write
              )
            )
          )
          AND r.Created <= p_createdBefore
          AND (r.ValidFrom IS NULL OR r.ValidFrom <= p_regulationDate)
          AND pl.Status = 0 AND pl.PayrollId = p_payrollId
    ),
    Regulations AS (SELECT Id, Level, Priority FROM DerivedRegulations WHERE RowNumber = 1)
    SELECT
        reg.Id AS RegulationId, reg.Level, reg.Priority,
        lv.*
    FROM LookupValue lv
    INNER JOIN Lookup lk ON lv.LookupId = lk.Id
    INNER JOIN Regulations reg ON lk.RegulationId = reg.Id
    WHERE lv.Status = 0
      AND lv.Created <= p_createdBefore
      AND (p_lookupNames IS NULL
           OR LOWER(lk.Name) IN (
               SELECT LOWER(jt.val)
               FROM JSON_TABLE(p_lookupNames, '$[*]' COLUMNS (val VARCHAR(128) PATH '$')) AS jt))
      AND (p_lookupKeys IS NULL
           OR lv.`Key` IN (
               SELECT jt.val
               FROM JSON_TABLE(p_lookupKeys, '$[*]' COLUMNS (val VARCHAR(128) PATH '$')) AS jt))
    ORDER BY reg.Level DESC, reg.Priority DESC;
END$$

DELIMITER ;

-- =============================================================================
-- GetDerivedCases
-- Excludes Binary, Script, ScriptVersion (performance hint identical to T-SQL)
-- =============================================================================

USE PayrollEngine;

DELIMITER $$

DROP PROCEDURE IF EXISTS GetDerivedCases$$
CREATE PROCEDURE GetDerivedCases(
    IN p_tenantId        INT,
    IN p_payrollId       INT,
    IN p_regulationDate  DATETIME(6),
    IN p_createdBefore   DATETIME(6),
    IN p_caseType        INT,
    IN p_caseNames       VARCHAR(4000),
    IN p_includeClusters VARCHAR(4000),
    IN p_excludeClusters VARCHAR(4000),
    IN p_hidden          TINYINT(1)
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
        c.Id, c.Status, c.Created, c.Updated, c.RegulationId,
        c.CaseType, c.Name, c.NameLocalizations, c.NameSynonyms,
        c.Description, c.DescriptionLocalizations,
        c.DefaultReason, c.DefaultReasonLocalizations,
        c.BaseCase, c.BaseCaseFields,
        c.OverrideType, c.CancellationType,
        c.AvailableExpression, c.BuildExpression, c.ValidateExpression,
        c.Lookups, c.Slots,
        c.ScriptHash, c.Attributes, c.Clusters,
        c.AvailableActions, c.BuildActions, c.ValidateActions
    FROM `Case` c
    INNER JOIN Regulations reg ON c.RegulationId = reg.Id
    WHERE c.Status = 0
      AND c.Created <= p_createdBefore
      AND (p_hidden IS NULL OR c.Hidden = p_hidden)
      AND (p_caseType IS NULL OR c.CaseType = p_caseType)
      AND ((p_includeClusters IS NULL AND p_excludeClusters IS NULL)
           OR IsMatchingCluster(p_includeClusters, p_excludeClusters, c.Clusters) = 1)
      AND (p_caseNames IS NULL
           OR LOWER(c.Name) IN (
               SELECT LOWER(jt.val)
               FROM JSON_TABLE(p_caseNames, '$[*]' COLUMNS (val VARCHAR(128) PATH '$')) AS jt))
    ORDER BY reg.Level DESC, reg.Priority DESC;
END$$

DELIMITER ;

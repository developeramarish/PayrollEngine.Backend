-- =============================================================================
-- Update-Model.mysql.sql
-- Migration: PayrollEngine v1.0.0 → v1.0.1 (MySQL)
-- =============================================================================

-- =============================================================================
-- VERSION CHECK
-- Guard: abort if the schema is not at version 1.0.0
-- =============================================================================

DROP PROCEDURE IF EXISTS _PE_VersionCheck;

DELIMITER $$

CREATE PROCEDURE _PE_VersionCheck()
BEGIN
    DECLARE v_major INT DEFAULT NULL;
    DECLARE v_minor INT DEFAULT NULL;
    DECLARE v_sub   INT DEFAULT NULL;
    DECLARE v_msg   VARCHAR(200);

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.TABLES
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'Version'
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Schema not found: Version table does not exist. Run Create-Model.mysql.sql first.';
    END IF;

    SELECT MajorVersion, MinorVersion, SubVersion
    INTO v_major, v_minor, v_sub
    FROM `Version`
    ORDER BY MajorVersion DESC, MinorVersion DESC, SubVersion DESC
    LIMIT 1;

    IF v_major <> 1 OR v_minor <> 0 OR v_sub <> 0 THEN
        SET v_msg = CONCAT('Version mismatch: expected 1.0.0, found ',
                           IFNULL(v_major, -1), '.', IFNULL(v_minor, -1), '.', IFNULL(v_sub, -1));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_msg;
    END IF;
END$$

DELIMITER ;

CALL _PE_VersionCheck();
DROP PROCEDURE IF EXISTS _PE_VersionCheck;

-- =============================================================================
-- TABLE CHANGES
-- =============================================================================

-- (none in this release)

-- =============================================================================
-- INDEX CHANGES
-- =============================================================================

-- (none in this release)

-- =============================================================================
-- STORED PROCEDURE CHANGES
-- =============================================================================

-- GetDerivedPayrollRegulations: RegulationShare now matched by regulation NAME (via JOIN)
-- instead of version-specific ProviderRegulationId.
--
-- Bug: When multiple versions of a regulation exist (e.g. US.Payroll.Data.Federal.FICA
-- for 2025 and 2026), ExchangeImport creates a RegulationShare for whichever version
-- GetRegulationAsync returns first (often the older one). GetDerivedPayrollRegulations
-- then fails to find a share for the other version, silently blocking cross-tenant lookup
-- access (e.g. FicaParameters for 2026 when share points to 2025 Id).
--
-- Fix: The EXISTS subquery joins through Regulation to match by Name rather than Id.
-- A single RegulationShare entry for any version of a regulation now grants access
-- to ALL versions of that regulation family.

USE PayrollEngine;

DELIMITER $$

DROP PROCEDURE IF EXISTS GetDerivedPayrollRegulations$$
CREATE PROCEDURE GetDerivedPayrollRegulations(
    IN p_tenantId       INT,
    IN p_payrollId      INT,
    IN p_regulationDate DATETIME(6),
    IN p_createdBefore  DATETIME(6)
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
            -- Write = 3 (TenantIsolationLevel enum, PayrollEngine.Core).
            -- IMPORTANT: if TenantIsolationLevel enum values change, this literal must
            -- be updated in sync. The CK_RegulationShare_IsolationLevel check constraint
            -- enforces the allowed set and will fail on INSERT if the enum is extended.
            OR (
              r.SharedRegulation = 1
              AND EXISTS (
                -- Match by regulation NAME so a single RegulationShare entry covers all
                -- ValidFrom versions of the same regulation family (e.g. 2025 and 2026).
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
    SELECT r.*, reg.Level, reg.Priority
    FROM Regula
-- GetDerived* SPs (12): SharedRegulation access control hardened.
-- Replaced simplified 'OR r.SharedRegulation = 1' with proper RegulationShare
-- IsolationLevel >= 3 check, matched by regulation NAME (same fix as above).

-- GetDerivedCaseFields
-- =============================================================================
-- GetDerivedCaseFields
-- Filtered by case field names.
-- =============================================================================

USE PayrollEngine;

DELIMITER $$

DROP PROCEDURE IF EXISTS GetDerivedCaseFields$$
CREATE PROCEDURE GetDerivedCaseFields(
    IN p_tenantId        INT,
    IN p_payrollId       INT,
    IN p_regulationDate  DATETIME(6),
    IN p_createdBefore   DATETIME(6),
    IN p_caseFieldNames  VARCHAR(4000),
    IN p_includeClusters VARCHAR(4000),
    IN p_excludeClusters VARCHAR(4000)
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
        c.Id AS CaseId, c.CaseType,
        cf.*
    FROM CaseField cf
    INNER JOIN `Case` c ON cf.CaseId = c.Id
    INNER JOIN Regulations reg ON c.RegulationId = reg.Id
    WHERE cf.Status = 0
      AND cf.Created <= p_createdBefore
      AND ((p_includeClusters IS NULL AND p_excludeClusters IS NULL)
           OR IsMatchingCluster(p_includeClusters, p_excludeClusters, cf.Clusters) = 1)
      AND (p_caseFieldNames IS NULL
           OR LOWER(cf.Name) IN (
               SELECT LOWER(jt.val)
               FROM JSON_TABLE(p_caseFieldNames, '$[*]' COLUMNS (val VARCHAR(128) PATH '$')) AS jt))
    ORDER BY reg.Level DESC, reg.Priority DESC;
END$$

DELIMITER ;

-- GetDerivedCaseFieldsOfCase
-- =============================================================================
-- GetDerivedCaseFieldsOfCase
-- Filtered by case names (not field names).
-- =============================================================================

USE PayrollEngine;

DELIMITER $$

DROP PROCEDURE IF EXISTS GetDerivedCaseFieldsOfCase$$
CREATE PROCEDURE GetDerivedCaseFieldsOfCase(
    IN p_tenantId        INT,
    IN p_payrollId       INT,
    IN p_regulationDate  DATETIME(6),
    IN p_createdBefore   DATETIME(6),
    IN p_caseNames       VARCHAR(4000),
    IN p_includeClusters VARCHAR(4000),
    IN p_excludeClusters VARCHAR(4000)
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
        c.Id AS CaseId, c.CaseType,
        cf.*
    FROM CaseField cf
    INNER JOIN `Case` c ON cf.CaseId = c.Id
    INNER JOIN Regulations reg ON c.RegulationId = reg.Id
    WHERE cf.Status = 0
      AND cf.Created <= p_createdBefore
      AND ((p_includeClusters IS NULL AND p_excludeClusters IS NULL)
           OR IsMatchingCluster(p_includeClusters, p_excludeClusters, cf.Clusters) = 1)
      AND (p_caseNames IS NULL
           OR LOWER(c.Name) IN (
               SELECT LOWER(jt.val)
               FROM JSON_TABLE(p_caseNames, '$[*]' COLUMNS (val VARCHAR(128) PATH '$')) AS jt))
    ORDER BY reg.Level DESC, reg.Priority DESC;
END$$

DELIMITER ;

-- GetDerivedCaseRelations
-- =============================================================================
-- GetDerivedCaseRelations
-- cr.`Order` backtick-quoted (reserved keyword in MySQL)
-- Excludes Binary, Script, ScriptVersion (performance hint)
-- =============================================================================

USE PayrollEngine;

DELIMITER $$

DROP PROCEDURE IF EXISTS GetDerivedCaseRelations$$
CREATE PROCEDURE GetDerivedCaseRelations(
    IN p_tenantId        INT,
    IN p_payrollId       INT,
    IN p_regulationDate  DATETIME(6),
    IN p_createdBefore   DATETIME(6),
    IN p_sourceCaseName  VARCHAR(128),
    IN p_targetCaseName  VARCHAR(128),
    IN p_includeClusters VARCHAR(4000),
    IN p_excludeClusters VARCHAR(4000)
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
        cr.Id, cr.Status, cr.Created, cr.Updated, cr.RegulationId,
        cr.SourceCaseName, cr.SourceCaseNameLocalizations,
        cr.SourceCaseSlot, cr.SourceCaseSlotLocalizations,
        cr.TargetCaseName, cr.TargetCaseNameLocalizations,
        cr.TargetCaseSlot, cr.TargetCaseSlotLocalizations,
        cr.RelationHash, cr.BuildExpression, cr.ValidateExpression,
        cr.OverrideType, cr.`Order`,
        cr.ScriptHash, cr.Attributes, cr.Clusters,
        cr.BuildActions, cr.ValidateActions
    FROM CaseRelation cr
    INNER JOIN Regulations reg ON cr.RegulationId = reg.Id
    WHERE cr.Status = 0
      AND cr.Created <= p_createdBefore
      AND (p_sourceCaseName IS NULL
           OR LOWER(cr.SourceCaseName) = LOWER(p_sourceCaseName))
      AND (p_targetCaseName IS NULL
           OR LOWER(cr.TargetCaseName) = LOWER(p_targetCaseName))
      AND ((p_includeClusters IS NULL AND p_excludeClusters IS NULL)
           OR IsMatchingCluster(p_includeClusters, p_excludeClusters, cr.Clusters) = 1)
    ORDER BY cr.SourceCaseName, cr.TargetCaseName, reg.Level DESC, reg.Priority DESC;
END$$

DELIMITER ;

-- GetDerivedCases
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

-- GetDerivedCollectors
-- =============================================================================
-- GetDerivedCollectors
-- Excludes Binary, Script, ScriptVersion (performance hint)
-- =============================================================================

USE PayrollEngine;

DELIMITER $$

DROP PROCEDURE IF EXISTS GetDerivedCollectors$$
CREATE PROCEDURE GetDerivedCollectors(
    IN p_tenantId        INT,
    IN p_payrollId       INT,
    IN p_regulationDate  DATETIME(6),
    IN p_createdBefore   DATETIME(6),
    IN p_collectorNames  VARCHAR(4000),
    IN p_includeClusters VARCHAR(4000),
    IN p_excludeClusters VARCHAR(4000)
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
        co.Id, co.Status, co.Created, co.Updated, co.RegulationId,
        co.Name, co.NameLocalizations,
        co.CollectMode, co.Negated, co.OverrideType, co.ValueType,
        co.Culture, co.CollectorGroups,
        co.StartExpression, co.ApplyExpression, co.EndExpression,
        co.StartActions, co.ApplyActions, co.EndActions,
        co.Threshold, co.MinResult, co.MaxResult,
        co.ScriptHash, co.Attributes, co.Clusters
    FROM Collector co
    INNER JOIN Regulations reg ON co.RegulationId = reg.Id
    WHERE co.Status = 0
      AND co.Created <= p_createdBefore
      AND ((p_includeClusters IS NULL AND p_excludeClusters IS NULL)
           OR IsMatchingCluster(p_includeClusters, p_excludeClusters, co.Clusters) = 1)
      AND (p_collectorNames IS NULL
           OR LOWER(co.Name) IN (
               SELECT LOWER(jt.val)
               FROM JSON_TABLE(p_collectorNames, '$[*]' COLUMNS (val VARCHAR(128) PATH '$')) AS jt))
    ORDER BY co.Name, reg.Level DESC, reg.Priority DESC;
END$$

DELIMITER ;

-- GetDerivedLookups
-- =============================================================================
-- GetDerivedLookups
-- =============================================================================

USE PayrollEngine;

DELIMITER $$

DROP PROCEDURE IF EXISTS GetDerivedLookups$$
CREATE PROCEDURE GetDerivedLookups(
    IN p_tenantId       INT,
    IN p_payrollId      INT,
    IN p_regulationDate DATETIME(6),
    IN p_createdBefore  DATETIME(6),
    IN p_lookupNames    VARCHAR(4000)
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
        lk.*
    FROM Lookup lk
    INNER JOIN Regulations reg ON lk.RegulationId = reg.Id
    WHERE lk.Status = 0
      AND lk.Created <= p_createdBefore
      AND (p_lookupNames IS NULL
           OR LOWER(lk.Name) IN (
               SELECT LOWER(jt.val)
               FROM JSON_TABLE(p_lookupNames, '$[*]' COLUMNS (val VARCHAR(128) PATH '$')) AS jt))
    ORDER BY reg.Level DESC, reg.Priority DESC;
END$$

DELIMITER ;

-- GetDerivedLookupValues
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

-- GetDerivedReportParameters
-- =============================================================================
-- GetDerivedReportParameters
-- =============================================================================

USE PayrollEngine;

DELIMITER $$

DROP PROCEDURE IF EXISTS GetDerivedReportParameters$$
CREATE PROCEDURE GetDerivedReportParameters(
    IN p_tenantId       INT,
    IN p_payrollId      INT,
    IN p_regulationDate DATETIME(6),
    IN p_createdBefore  DATETIME(6),
    IN p_reportNames    VARCHAR(4000)
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
        rpar.*
    FROM ReportParameter rpar
    INNER JOIN Report rp ON rpar.ReportId = rp.Id
    INNER JOIN Regulations reg ON rp.RegulationId = reg.Id
    WHERE rpar.Status = 0
      AND rpar.Created <= p_createdBefore
      AND (p_reportNames IS NULL
           OR LOWER(rp.Name) IN (
               SELECT LOWER(jt.val)
               FROM JSON_TABLE(p_reportNames, '$[*]' COLUMNS (val VARCHAR(128) PATH '$')) AS jt))
    ORDER BY reg.Level DESC, reg.Priority DESC;
END$$

DELIMITER ;

-- GetDerivedReports
-- =============================================================================
-- GetDerivedReports
-- Excludes Binary, Script, ScriptVersion (performance hint)
-- =============================================================================

USE PayrollEngine;

DELIMITER $$

DROP PROCEDURE IF EXISTS GetDerivedReports$$
CREATE PROCEDURE GetDerivedReports(
    IN p_tenantId        INT,
    IN p_payrollId       INT,
    IN p_regulationDate  DATETIME(6),
    IN p_createdBefore   DATETIME(6),
    IN p_userType        INT,
    IN p_reportNames     VARCHAR(4000),
    IN p_includeClusters VARCHAR(4000),
    IN p_excludeClusters VARCHAR(4000)
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
        rp.Id, rp.Status, rp.Created, rp.Updated, rp.RegulationId,
        rp.Name, rp.NameLocalizations,
        rp.Description, rp.DescriptionLocalizations,
        rp.Category, rp.Queries, rp.Relations,
        rp.AttributeMode, rp.UserType, rp.ReportIsolation,
        rp.BuildExpression, rp.StartExpression, rp.EndExpression,
        rp.ScriptHash, rp.Attributes, rp.Clusters
    FROM Report rp
    INNER JOIN Regulations reg ON rp.RegulationId = reg.Id
    WHERE rp.Status = 0
      AND rp.Created <= p_createdBefore
      AND (p_userType IS NULL OR rp.UserType <= p_userType)
      AND ((p_includeClusters IS NULL AND p_excludeClusters IS NULL)
           OR IsMatchingCluster(p_includeClusters, p_excludeClusters, rp.Clusters) = 1)
      AND (p_reportNames IS NULL
           OR LOWER(rp.Name) IN (
               SELECT LOWER(jt.val)
               FROM JSON_TABLE(p_reportNames, '$[*]' COLUMNS (val VARCHAR(128) PATH '$')) AS jt))
    ORDER BY reg.Level DESC, reg.Priority DESC;
END$$

DELIMITER ;

-- GetDerivedReportTemplates
-- =============================================================================
-- GetDerivedReportTemplates
-- `Schema` column is backtick-quoted (reserved word in MySQL)
-- SELECT rt.* expands safely
-- =============================================================================

USE PayrollEngine;

DELIMITER $$

DROP PROCEDURE IF EXISTS GetDerivedReportTemplates$$
CREATE PROCEDURE GetDerivedReportTemplates(
    IN p_tenantId       INT,
    IN p_payrollId      INT,
    IN p_regulationDate DATETIME(6),
    IN p_createdBefore  DATETIME(6),
    IN p_reportNames    VARCHAR(4000),
    IN p_culture        VARCHAR(128)
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
        rt.*
    FROM ReportTemplate rt
    INNER JOIN Report rp ON rt.ReportId = rp.Id
    INNER JOIN Regulations reg ON rp.RegulationId = reg.Id
    WHERE rt.Status = 0
      AND rt.Created <= p_createdBefore
      AND (p_reportNames IS NULL
           OR LOWER(rp.Name) IN (
               SELECT LOWER(jt.val)
               FROM JSON_TABLE(p_reportNames, '$[*]' COLUMNS (val VARCHAR(128) PATH '$')) AS jt))
      AND (p_culture IS NULL OR rt.Culture = p_culture)
    ORDER BY reg.Level DESC, reg.Priority DESC;
END$$

DELIMITER ;

-- GetDerivedScripts
-- =============================================================================
-- GetDerivedScripts
-- OverrideType excluded from SELECT (matches T-SQL explicit column list)
-- =============================================================================

USE PayrollEngine;

DELIMITER $$

DROP PROCEDURE IF EXISTS GetDerivedScripts$$
CREATE PROCEDURE GetDerivedScripts(
    IN p_tenantId       INT,
    IN p_payrollId      INT,
    IN p_regulationDate DATETIME(6),
    IN p_createdBefore  DATETIME(6),
    IN p_scriptNames    VARCHAR(4000)
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
        s.Id, s.Status, s.Created, s.Updated, s.RegulationId,
        s.Name, s.FunctionTypeMask, s.Value
    FROM Script s
    INNER JOIN Regulations reg ON s.RegulationId = reg.Id
    WHERE s.Status = 0
      AND s.Created <= p_createdBefore
      AND (p_scriptNames IS NULL
           OR LOWER(s.Name) IN (
               SELECT LOWER(jt.val)
               FROM JSON_TABLE(p_scriptNames, '$[*]' COLUMNS (val VARCHAR(128) PATH '$')) AS jt))
    ORDER BY reg.Level DESC, reg.Priority DESC;
END$$

DELIMITER ;

-- GetDerivedWageTypes
-- =============================================================================
-- GetDerivedWageTypes
-- Excludes Binary, Script, ScriptVersion (performance hint identical to T-SQL)
-- =============================================================================

USE PayrollEngine;

DELIMITER $$

DROP PROCEDURE IF EXISTS GetDerivedWageTypes$$
CREATE PROCEDURE GetDerivedWageTypes(
    IN p_tenantId        INT,
    IN p_payrollId       INT,
    IN p_regulationDate  DATETIME(6),
    IN p_createdBefore   DATETIME(6),
    IN p_wageTypeNumbers VARCHAR(4000),
    IN p_includeClusters VARCHAR(4000),
    IN p_excludeClusters VARCHAR(4000)
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
        wt.Id, wt.Status, wt.Created, wt.Updated, wt.RegulationId,
        wt.Name, wt.NameLocalizations, wt.WageTypeNumber,
        wt.Description, wt.DescriptionLocalizations,
        wt.OverrideType, wt.ValueType, wt.Calendar, wt.Culture,
        wt.Collectors, wt.CollectorGroups,
        wt.ValueExpression, wt.ResultExpression,
        wt.ValueActions, wt.ResultActions,
        wt.ScriptHash, wt.Attributes, wt.Clusters
    FROM WageType wt
    INNER JOIN Regulations reg ON wt.RegulationId = reg.Id
    WHERE wt.Status = 0
      AND wt.Created <= p_createdBefore
      AND ((p_includeClusters IS NULL AND p_excludeClusters IS NULL)
           OR IsMatchingCluster(p_includeClusters, p_excludeClusters, wt.Clusters) = 1)
      AND (p_wageTypeNumbers IS NULL
           OR wt.WageTypeNumber IN (
               SELECT CAST(jt.val AS DECIMAL(28,6))
               FROM JSON_TABLE(p_wageTypeNumbers, '$[*]' COLUMNS (val VARCHAR(50) PATH '$')) AS jt))
    ORDER BY wt.WageTypeNumber, reg.Level DESC, reg.Priority DESC;
END$$

DELIMITER ;

tion r
    INNER JOIN Regulations reg ON r.Id = reg.Id
    ORDER BY reg.Level DESC, reg.Priority DESC;
END$$

DELIMITER ;

-- =============================================================================
-- VERSION SET
-- =============================================================================

INSERT INTO `Version` (Created, MajorVersion, MinorVersion, SubVersion, Owner, Description)
VALUES (NOW(6), 1, 0, 1, CURRENT_USER(), 'Payroll Engine: Migration v1.0.0 -> v1.0.1 (MySQL)');

SELECT CONCAT('PayrollEngine MySQL schema updated to v1.0.1 successfully.') AS Result;

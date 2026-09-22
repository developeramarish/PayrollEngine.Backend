USE [PayrollEngine];
GO

SET XACT_ABORT ON
GO

-- =============================================================================
-- VERSION CHECK
-- Guard: abort if the schema is not at version 1.0.0
-- =============================================================================
IF OBJECT_ID('dbo.Version') IS NULL BEGIN
    RAISERROR('Schema not found: dbo.Version does not exist. Run Create-Model.sql first.', 16, 1)
    SET NOEXEC ON
END
GO

DECLARE @MajorVersion int, @MinorVersion int, @SubVersion int
SELECT TOP 1
    @MajorVersion = MajorVersion,
    @MinorVersion = MinorVersion,
    @SubVersion   = SubVersion
FROM dbo.[Version]
ORDER BY MajorVersion DESC, MinorVersion DESC, SubVersion DESC

IF @MajorVersion <> 1 OR @MinorVersion <> 0 OR @SubVersion <> 0 BEGIN
    DECLARE @ActualVersion NVARCHAR(20) =
        CAST(ISNULL(@MajorVersion, -1) AS NVARCHAR) + '.' +
        CAST(ISNULL(@MinorVersion, -1) AS NVARCHAR) + '.' +
        CAST(ISNULL(@SubVersion,   -1) AS NVARCHAR)
    RAISERROR('Version mismatch: expected 1.0.0, found %s', 16, 1, @ActualVersion)
    SET NOEXEC ON
END
GO

BEGIN TRANSACTION
GO

-- =============================================================================
-- TABLE CHANGES
-- =============================================================================

-- (none in this release)

-- =============================================================================
-- INDEX CHANGES
-- =============================================================================

-- (none in this release)

-- =============================================================================
-- FUNCTION CHANGES
-- =============================================================================

-- GetDerivedRegulations: RegulationShare now matched by regulation NAME (via JOIN)
-- instead of version-specific ProviderRegulationId.
--
-- Bug: When multiple versions of a regulation exist (e.g. US.Payroll.Data.Federal.FICA
-- for 2025 and 2026), ExchangeImport creates a RegulationShare for whichever version
-- GetRegulationAsync returns first (often the older one). GetDerivedRegulations then
-- fails to find a share for the other version, silently blocking cross-tenant lookup
-- access (e.g. FicaParameters for 2026 when share points to 2025 Id).
--
-- Fix: The EXISTS subquery joins through Regulation to match by Name rather than Id.
-- A single RegulationShare entry for any version of a regulation now grants access
-- to ALL versions of that regulation family. This aligns with the business intent:
-- sharing a regulation by name, not by a specific version Id.
IF OBJECT_ID('[dbo].[GetDerivedRegulations]') IS NOT NULL
    DROP FUNCTION [dbo].[GetDerivedRegulations];
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Get all active derived regulation ids from the payroll.
-- IsolationLevel < Write (< 3) means Consolidation-only — not a payroll layer.
-- Only shares with IsolationLevel >= Write (3) are eligible as payroll layers.
-- =============================================
CREATE FUNCTION [dbo].[GetDerivedRegulations] (
  @tenantId      AS INT,
  @payrollId     AS INT,
  @regulationDate AS DATETIME2(7),
  @createdBefore  AS DATETIME2(7)
  )
RETURNS TABLE
AS
RETURN (
    WITH GroupRegulation AS (
        SELECT [Regulation].[Id],
          [PayrollLayer].[Level],
          [PayrollLayer].[Priority],
          ROW_NUMBER() OVER (
            PARTITION BY [PayrollLayer].[Id],
            [Regulation].[Name] ORDER BY [Regulation].[ValidFrom] DESC,
              [Regulation].[Created] DESC
            ) AS RowNumber
        FROM [PayrollLayer]
        INNER JOIN [Regulation]
          ON [PayrollLayer].[RegulationName] = [Regulation].[Name]
        WHERE [Regulation].[Status] = 0
          AND (
            [Regulation].[TenantId] = @tenantId
            OR (
              [Regulation].[SharedRegulation] = 1
              AND EXISTS (
                -- Match by regulation NAME so a single RegulationShare entry covers all
                -- ValidFrom versions of the same regulation family (e.g. 2025 and 2026).
                SELECT 1
                FROM [dbo].[RegulationShare] rs
                INNER JOIN [dbo].[Regulation] rp ON rs.[ProviderRegulationId] = rp.[Id]
                WHERE rp.[Name]             = [Regulation].[Name]
                  AND rs.[ConsumerTenantId] = @tenantId
                  AND rs.[IsolationLevel]   >= 3  -- TenantIsolationLevel.Write
              )
            )
          )
          AND [Regulation].[Created] <= @createdBefore
          AND (
            [Regulation].[ValidFrom] IS NULL
            OR [Regulation].[ValidFrom] <= @regulationDate
            )
          AND [PayrollLayer].[Status] = 0
          AND [PayrollLayer].[PayrollId] = @payrollId
        )
    SELECT *
    FROM GroupRegulation
    WHERE RowNumber = 1
    )
GO

-- =============================================================================
-- STORED PROCEDURE CHANGES
-- =============================================================================

-- (none in this release)

-- =============================================================================
-- VERSION SET
-- =============================================================================

DECLARE @errorID int
INSERT INTO dbo.[Version] (
    MajorVersion, MinorVersion, SubVersion, [Owner], [Description])
VALUES (
    1, 0, 1, CURRENT_USER,
    'Payroll Engine: Migration v1.0.0 -> v1.0.1')
SET @errorID = @@ERROR
IF (@errorID <> 0) BEGIN
    PRINT 'Error while updating the Payroll Engine database version.'
END ELSE BEGIN
    PRINT 'Payroll Engine database version successfully updated to release 1.0.1'
END
GO

COMMIT TRANSACTION
GO

SET NOEXEC OFF
GO

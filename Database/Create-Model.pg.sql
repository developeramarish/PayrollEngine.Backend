-- =============================================================================
-- Create-Model.pg.sql
-- PostgreSQL schema for PayrollEngine 14+ (16 LTS recommended).
-- Schema version: 1.0.0
-- NOTE: All table names are double-quoted for C# SqlKata compatibility.
-- =============================================================================

-- TABLES
-- =============================================================================

-- =============================================================================
-- NOTE: Indexes are defined after all tables in the INDEXES section below.

CREATE TABLE IF NOT EXISTS "Calendar" (
    Id INT           NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT           NOT NULL,
    Created TIMESTAMP(6)   NOT NULL,
    Updated TIMESTAMP(6)   NOT NULL,
    TenantId INT           NOT NULL,
    Name VARCHAR(128)  NOT NULL,
    NameLocalizations TEXT      NULL,
    CycleTimeUnit INT           NOT NULL,
    PeriodTimeUnit INT           NOT NULL,
    TimeMap INT           NOT NULL,
    FirstMonthOfYear INT           NULL,
    PeriodDayCount DECIMAL(28,6) NULL,
    YearWeekRule INT           NULL,
    FirstDayOfWeek INT           NULL,
    WeekMode INT           NOT NULL,
    WorkMonday BOOLEAN    NULL,
    WorkTuesday BOOLEAN    NULL,
    WorkWednesday BOOLEAN    NULL,
    WorkThursday BOOLEAN    NULL,
    WorkFriday BOOLEAN    NULL,
    WorkSaturday BOOLEAN    NULL,
    WorkSunday BOOLEAN    NULL,
    Attributes TEXT      NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "Case" (
    Id INT           NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT           NOT NULL,
    Created TIMESTAMP(6)   NOT NULL,
    Updated TIMESTAMP(6)   NOT NULL,
    RegulationId INT           NOT NULL,
    CaseType INT           NOT NULL,
    Name VARCHAR(128)  NOT NULL,
    NameLocalizations TEXT      NULL,
    NameSynonyms TEXT      NULL,
    Description TEXT      NULL,
    DescriptionLocalizations TEXT      NULL,
    DefaultReason TEXT      NULL,
    DefaultReasonLocalizations TEXT      NULL,
    BaseCase VARCHAR(128)  NULL,
    BaseCaseFields TEXT      NULL,
    OverrideType INT           NOT NULL,
    CancellationType INT           NOT NULL,
    Hidden BOOLEAN    NOT NULL,
    AvailableExpression TEXT      NULL,
    BuildExpression TEXT      NULL,
    ValidateExpression TEXT      NULL,
    Lookups TEXT      NULL,
    Slots TEXT      NULL,
    Script TEXT      NULL,
    ScriptVersion VARCHAR(128)  NULL,
    "Binary" BYTEA      NULL,
    ScriptHash INT           NULL,
    AvailableActions TEXT      NULL,
    BuildActions TEXT      NULL,
    ValidateActions TEXT      NULL,
    Attributes TEXT      NULL,
    Clusters TEXT      NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "CaseAudit" (
    Id INT           NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT           NOT NULL,
    Created TIMESTAMP(6)   NOT NULL,
    Updated TIMESTAMP(6)   NOT NULL,
    CaseId INT           NOT NULL,
    CaseChangeId INT           NULL,
    CaseType INT           NOT NULL,
    Name VARCHAR(128)  NOT NULL,
    NameLocalizations TEXT      NULL,
    NameSynonyms TEXT      NULL,
    Description TEXT      NULL,
    DescriptionLocalizations TEXT      NULL,
    DefaultReason TEXT      NULL,
    DefaultReasonLocalizations TEXT      NULL,
    BaseCase VARCHAR(128)  NULL,
    BaseCaseFields TEXT      NULL,
    OverrideType INT           NOT NULL,
    CancellationType INT           NOT NULL,
    Hidden BOOLEAN    NOT NULL,
    AvailableExpression TEXT      NULL,
    BuildExpression TEXT      NULL,
    ValidateExpression TEXT      NULL,
    Lookups TEXT      NULL,
    Slots TEXT      NULL,
    Script TEXT      NULL,
    ScriptVersion VARCHAR(128)  NULL,
    "Binary" BYTEA      NULL,
    ScriptHash INT           NULL,
    AvailableActions TEXT      NULL,
    BuildActions TEXT      NULL,
    ValidateActions TEXT      NULL,
    Attributes TEXT      NULL,
    Clusters TEXT      NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "CaseField" (
    Id INT           NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT           NOT NULL,
    Created TIMESTAMP(6)   NOT NULL,
    Updated TIMESTAMP(6)   NOT NULL,
    Name VARCHAR(128)  NOT NULL,
    NameLocalizations TEXT      NULL,
    Description TEXT      NULL,
    DescriptionLocalizations TEXT      NULL,
    CaseId INT           NOT NULL,
    ValueType INT           NOT NULL,
    ValueScope INT           NOT NULL,
    StartDateType INT           NOT NULL,
    EndDateType INT           NOT NULL,
    EndMandatory BOOLEAN    NOT NULL,
    DefaultStart VARCHAR(128)  NULL,
    DefaultEnd VARCHAR(128)  NULL,
    DefaultValue TEXT      NULL,
    LookupSettings TEXT      NULL,
    TimeType INT           NOT NULL,
    TimeUnit INT           NOT NULL,
    Culture VARCHAR(128)  NULL,
    PeriodAggregation INT           NOT NULL,
    OverrideType INT           NOT NULL,
    CancellationMode INT           NOT NULL,
    ValueCreationMode INT           NOT NULL,
    ValueMandatory BOOLEAN    NOT NULL,
    "Order" INT           NOT NULL,
    Tags TEXT      NULL,
    Clusters TEXT      NULL,
    Attributes TEXT      NULL,
    ValueAttributes TEXT      NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "CaseFieldAudit" (
    Id INT           NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT           NOT NULL,
    Created TIMESTAMP(6)   NOT NULL,
    Updated TIMESTAMP(6)   NOT NULL,
    CaseFieldId INT           NOT NULL,
    ValueType INT           NOT NULL,
    ValueScope INT           NOT NULL,
    Name VARCHAR(128)  NOT NULL,
    NameLocalizations TEXT      NULL,
    Description TEXT      NULL,
    DescriptionLocalizations TEXT      NULL,
    StartDateType INT           NOT NULL,
    EndDateType INT           NOT NULL,
    EndMandatory BOOLEAN    NOT NULL,
    DefaultStart VARCHAR(128)  NULL,
    DefaultEnd VARCHAR(128)  NULL,
    DefaultValue TEXT      NULL,
    LookupSettings TEXT      NULL,
    TimeType INT           NOT NULL,
    TimeUnit INT           NOT NULL,
    Culture VARCHAR(128)  NULL,
    PeriodAggregation INT           NOT NULL,
    OverrideType INT           NOT NULL,
    CancellationMode INT           NOT NULL,
    ValueCreationMode INT           NOT NULL,
    ValueMandatory BOOLEAN    NOT NULL,
    "Order" INT           NOT NULL,
    Tags TEXT      NULL,
    Clusters TEXT      NULL,
    Attributes TEXT      NULL,
    ValueAttributes TEXT      NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "CaseRelation" (
    Id INT           NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT           NOT NULL,
    Created TIMESTAMP(6)   NOT NULL,
    Updated TIMESTAMP(6)   NOT NULL,
    RegulationId INT           NOT NULL,
    SourceCaseName VARCHAR(128)  NOT NULL,
    SourceCaseNameLocalizations TEXT      NULL,
    SourceCaseSlot VARCHAR(128)  NULL,
    SourceCaseSlotLocalizations TEXT      NULL,
    TargetCaseName VARCHAR(128)  NOT NULL,
    TargetCaseNameLocalizations TEXT      NULL,
    TargetCaseSlot VARCHAR(128)  NULL,
    TargetCaseSlotLocalizations TEXT      NULL,
    RelationHash INT           NOT NULL,
    BuildExpression TEXT      NULL,
    ValidateExpression TEXT      NULL,
    OverrideType INT           NOT NULL,
    "Order" INT           NOT NULL,
    Script TEXT      NULL,
    ScriptVersion VARCHAR(128)  NULL,
    "Binary" BYTEA      NULL,
    ScriptHash INT           NULL,
    BuildActions TEXT      NULL,
    ValidateActions TEXT      NULL,
    Attributes TEXT      NULL,
    Clusters TEXT      NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "CaseRelationAudit" (
    Id INT           NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT           NOT NULL,
    Created TIMESTAMP(6)   NOT NULL,
    Updated TIMESTAMP(6)   NOT NULL,
    CaseRelationId INT           NOT NULL,
    SourceCaseName VARCHAR(128)  NOT NULL,
    SourceCaseNameLocalizations TEXT      NULL,
    SourceCaseSlot VARCHAR(128)  NULL,
    SourceCaseSlotLocalizations TEXT      NULL,
    TargetCaseName VARCHAR(128)  NOT NULL,
    TargetCaseNameLocalizations TEXT      NULL,
    TargetCaseSlot VARCHAR(128)  NULL,
    TargetCaseSlotLocalizations TEXT      NULL,
    RelationHash INT           NOT NULL,
    BuildExpression TEXT      NULL,
    ValidateExpression TEXT      NULL,
    OverrideType INT           NOT NULL,
    "Order" INT           NOT NULL,
    Script TEXT      NULL,
    ScriptVersion VARCHAR(128)  NULL,
    "Binary" BYTEA      NULL,
    ScriptHash INT           NULL,
    BuildActions TEXT      NULL,
    ValidateActions TEXT      NULL,
    Attributes TEXT      NULL,
    Clusters TEXT      NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "Collector" (
    Id INT           NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT           NOT NULL,
    Created TIMESTAMP(6)   NOT NULL,
    Updated TIMESTAMP(6)   NOT NULL,
    CollectMode INT           NOT NULL,
    Negated BOOLEAN    NOT NULL,
    RegulationId INT           NOT NULL,
    Name VARCHAR(128)  NOT NULL,
    NameLocalizations TEXT      NULL,
    OverrideType INT           NOT NULL,
    ValueType INT           NOT NULL,
    Culture VARCHAR(128)  NULL,
    CollectorGroups TEXT      NULL,
    StartExpression TEXT      NULL,
    ApplyExpression TEXT      NULL,
    EndExpression TEXT      NULL,
    StartActions TEXT      NULL,
    ApplyActions TEXT      NULL,
    EndActions TEXT      NULL,
    Threshold DECIMAL(28,6) NULL,
    MinResult DECIMAL(28,6) NULL,
    MaxResult DECIMAL(28,6) NULL,
    Script TEXT      NULL,
    ScriptVersion VARCHAR(128)  NULL,
    "Binary" BYTEA      NULL,
    ScriptHash INT           NULL,
    Attributes TEXT      NULL,
    Clusters TEXT      NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "CollectorAudit" (
    Id INT           NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT           NOT NULL,
    Created TIMESTAMP(6)   NOT NULL,
    Updated TIMESTAMP(6)   NOT NULL,
    CollectorId INT           NOT NULL,
    CollectMode INT           NOT NULL,
    Negated BOOLEAN    NOT NULL,
    Name VARCHAR(128)  NOT NULL,
    NameLocalizations TEXT      NULL,
    OverrideType INT           NOT NULL,
    ValueType INT           NOT NULL,
    Culture VARCHAR(128)  NULL,
    CollectorGroups TEXT      NULL,
    StartExpression TEXT      NULL,
    ApplyExpression TEXT      NULL,
    EndExpression TEXT      NULL,
    StartActions TEXT      NULL,
    ApplyActions TEXT      NULL,
    EndActions TEXT      NULL,
    Threshold DECIMAL(28,6) NULL,
    MinResult DECIMAL(28,6) NULL,
    MaxResult DECIMAL(28,6) NULL,
    Script TEXT      NULL,
    ScriptVersion VARCHAR(128)  NULL,
    "Binary" BYTEA      NULL,
    ScriptHash INT           NULL,
    Attributes TEXT      NULL,
    Clusters TEXT      NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "CollectorCustomResult" (
    Id INT           NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT           NOT NULL,
    Created TIMESTAMP(6)   NOT NULL,
    Updated TIMESTAMP(6)   NOT NULL,
    CollectorResultId INT           NOT NULL,
    TenantId INT           NOT NULL,
    EmployeeId INT           NOT NULL,
    DivisionId INT           NULL,
    CollectorName VARCHAR(128)  NOT NULL,
    CollectorNameHash INT           NOT NULL,
    CollectorNameLocalizations TEXT      NULL,
    Source VARCHAR(128)  NOT NULL,
    ValueType INT           NOT NULL,
    Value DECIMAL(28,6) NOT NULL,
    Culture VARCHAR(128)  NOT NULL,
    Start TIMESTAMP(6)   NOT NULL,
    StartHash INT           NOT NULL,
    "End" TIMESTAMP(6)   NOT NULL,
    PayrunJobId INT           NOT NULL,
    Forecast VARCHAR(128)  NULL,
    ParentJobId INT           NULL,
    Tags TEXT      NULL,
    Attributes TEXT      NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "CollectorResult" (
    Id INT           NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT           NOT NULL,
    Created TIMESTAMP(6)   NOT NULL,
    Updated TIMESTAMP(6)   NOT NULL,
    PayrollResultId INT           NOT NULL,
    TenantId INT           NOT NULL,
    EmployeeId INT           NOT NULL,
    DivisionId INT           NULL,
    CollectorId INT           NOT NULL,
    CollectorName VARCHAR(128)  NOT NULL,
    CollectorNameHash INT           NOT NULL,
    CollectorNameLocalizations TEXT      NULL,
    CollectMode INT           NOT NULL,
    Negated BOOLEAN    NOT NULL,
    ValueType INT           NOT NULL,
    Value DECIMAL(28,6) NOT NULL,
    Culture VARCHAR(128)  NOT NULL,
    Start TIMESTAMP(6)   NOT NULL,
    StartHash INT           NOT NULL,
    "End" TIMESTAMP(6)   NOT NULL,
    PayrunJobId INT           NOT NULL,
    Forecast VARCHAR(128)  NULL,
    ParentJobId INT           NULL,
    Tags TEXT      NULL,
    Attributes TEXT      NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "CompanyCaseChange" (
    Id INT           NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT           NOT NULL,
    Created TIMESTAMP(6)   NOT NULL,
    Updated TIMESTAMP(6)   NOT NULL,
    TenantId INT           NOT NULL,
    UserId INT           NOT NULL,
    DivisionId INT           NULL,
    CancellationType INT           NOT NULL,
    CancellationId INT           NULL,
    CancellationDate TIMESTAMP(6)   NULL,
    Reason TEXT      NOT NULL,
    ValidationCaseName VARCHAR(128)  NULL,
    Forecast VARCHAR(128)  NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "CompanyCaseDocument" (
    Id INT          NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT          NOT NULL,
    Created TIMESTAMP(6)  NOT NULL,
    Updated TIMESTAMP(6)  NOT NULL,
    CaseValueId INT          NOT NULL,
    Name VARCHAR(256) NOT NULL,
    Content TEXT     NOT NULL,
    ContentType VARCHAR(128) NOT NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "CompanyCaseValue" (
    Id INT           NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT           NOT NULL,
    Created TIMESTAMP(6)   NOT NULL,
    Updated TIMESTAMP(6)   NOT NULL,
    TenantId INT           NOT NULL,
    DivisionId INT           NULL,
    CaseName VARCHAR(128)  NOT NULL,
    CaseNameLocalizations TEXT      NULL,
    CaseFieldName VARCHAR(128)  NOT NULL,
    CaseFieldNameLocalizations TEXT      NULL,
    CaseSlot VARCHAR(128)  NULL,
    CaseSlotLocalizations TEXT      NULL,
    ValueType INT           NOT NULL,
    Value TEXT      NOT NULL,
    NumericValue DECIMAL(28,6) NULL,
    Culture VARCHAR(128)  NOT NULL,
    CaseRelation TEXT      NULL,
    CancellationDate TIMESTAMP(6)   NULL,
    Start TIMESTAMP(6)   NULL,
    "End" TIMESTAMP(6)   NULL,
    Forecast VARCHAR(128)  NULL,
    Tags TEXT      NULL,
    Attributes TEXT      NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "CompanyCaseValueChange" (
    Id INT         NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT         NOT NULL,
    Created TIMESTAMP(6) NOT NULL,
    Updated TIMESTAMP(6) NOT NULL,
    CaseChangeId INT         NOT NULL,
    CaseValueId INT         NOT NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "Division" (
    Id INT          NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT          NOT NULL,
    Created TIMESTAMP(6)  NOT NULL,
    Updated TIMESTAMP(6)  NOT NULL,
    TenantId INT          NOT NULL,
    Name VARCHAR(128) NOT NULL,
    NameLocalizations TEXT     NULL,
    Culture VARCHAR(128) NULL,
    Calendar VARCHAR(128) NULL,
    Attributes TEXT     NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "Employee" (
    Id INT          NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT          NOT NULL,
    Created TIMESTAMP(6)  NOT NULL,
    Updated TIMESTAMP(6)  NOT NULL,
    TenantId INT          NOT NULL,
    Identifier VARCHAR(128) NOT NULL,
    FirstName VARCHAR(128) NOT NULL,
    LastName VARCHAR(128) NOT NULL,
    Culture VARCHAR(128) NULL,
    Calendar VARCHAR(128) NULL,
    Attributes TEXT     NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "EmployeeCaseChange" (
    Id INT          NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT          NOT NULL,
    Created TIMESTAMP(6)  NOT NULL,
    Updated TIMESTAMP(6)  NOT NULL,
    EmployeeId INT          NOT NULL,
    UserId INT          NOT NULL,
    DivisionId INT          NULL,
    CancellationType INT          NOT NULL,
    CancellationId INT          NULL,
    CancellationDate TIMESTAMP(6)  NULL,
    Reason TEXT     NOT NULL,
    ValidationCaseName VARCHAR(128) NULL,
    Forecast VARCHAR(128) NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "EmployeeCaseDocument" (
    Id INT          NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT          NOT NULL,
    Created TIMESTAMP(6)  NOT NULL,
    Updated TIMESTAMP(6)  NOT NULL,
    CaseValueId INT          NOT NULL,
    Name VARCHAR(256) NOT NULL,
    Content TEXT     NOT NULL,
    ContentType VARCHAR(128) NOT NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "EmployeeCaseValue" (
    Id INT           NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT           NOT NULL,
    Created TIMESTAMP(6)   NOT NULL,
    Updated TIMESTAMP(6)   NOT NULL,
    EmployeeId INT           NOT NULL,
    DivisionId INT           NULL,
    CaseName VARCHAR(128)  NOT NULL,
    CaseNameLocalizations TEXT      NULL,
    CaseFieldName VARCHAR(128)  NOT NULL,
    CaseFieldNameLocalizations TEXT      NULL,
    CaseSlot VARCHAR(128)  NULL,
    CaseSlotLocalizations TEXT      NULL,
    ValueType INT           NOT NULL,
    Value TEXT      NOT NULL,
    NumericValue DECIMAL(28,6) NULL,
    Culture VARCHAR(128)  NOT NULL,
    CaseRelation TEXT      NULL,
    CancellationDate TIMESTAMP(6)   NULL,
    Start TIMESTAMP(6)   NULL,
    "End" TIMESTAMP(6)   NULL,
    Forecast VARCHAR(128)  NULL,
    Tags TEXT      NULL,
    Attributes TEXT      NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "EmployeeCaseValueChange" (
    Id INT         NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT         NOT NULL,
    Created TIMESTAMP(6) NOT NULL,
    Updated TIMESTAMP(6) NOT NULL,
    CaseChangeId INT         NOT NULL,
    CaseValueId INT         NOT NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "EmployeeDivision" (
    Id INT         NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT         NOT NULL,
    Created TIMESTAMP(6) NOT NULL,
    Updated TIMESTAMP(6) NOT NULL,
    EmployeeId INT         NOT NULL,
    DivisionId INT         NOT NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "GlobalCaseChange" (
    Id INT          NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT          NOT NULL,
    Created TIMESTAMP(6)  NOT NULL,
    Updated TIMESTAMP(6)  NOT NULL,
    TenantId INT          NOT NULL,
    UserId INT          NOT NULL,
    DivisionId INT          NULL,
    CancellationType INT          NOT NULL,
    CancellationId INT          NULL,
    CancellationDate TIMESTAMP(6)  NULL,
    Reason TEXT     NOT NULL,
    ValidationCaseName VARCHAR(128) NULL,
    Forecast VARCHAR(128) NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "GlobalCaseDocument" (
    Id INT          NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT          NOT NULL,
    Created TIMESTAMP(6)  NOT NULL,
    Updated TIMESTAMP(6)  NOT NULL,
    CaseValueId INT          NOT NULL,
    Name VARCHAR(256) NOT NULL,
    Content TEXT     NOT NULL,
    ContentType VARCHAR(128) NOT NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "GlobalCaseValue" (
    Id INT           NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT           NOT NULL,
    Created TIMESTAMP(6)   NOT NULL,
    Updated TIMESTAMP(6)   NOT NULL,
    TenantId INT           NOT NULL,
    DivisionId INT           NULL,
    CaseName VARCHAR(128)  NOT NULL,
    CaseNameLocalizations TEXT      NULL,
    CaseFieldName VARCHAR(128)  NOT NULL,
    CaseFieldNameLocalizations TEXT      NULL,
    CaseSlot VARCHAR(128)  NULL,
    CaseSlotLocalizations TEXT      NULL,
    ValueType INT           NOT NULL,
    Value TEXT      NOT NULL,
    NumericValue DECIMAL(28,6) NULL,
    Culture VARCHAR(128)  NOT NULL,
    CaseRelation TEXT      NULL,
    CancellationDate TIMESTAMP(6)   NULL,
    Start TIMESTAMP(6)   NULL,
    "End" TIMESTAMP(6)   NULL,
    Forecast VARCHAR(128)  NULL,
    Tags TEXT      NULL,
    Attributes TEXT      NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "GlobalCaseValueChange" (
    Id INT         NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT         NOT NULL,
    Created TIMESTAMP(6) NOT NULL,
    Updated TIMESTAMP(6) NOT NULL,
    CaseChangeId INT         NOT NULL,
    CaseValueId INT         NOT NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "Log" (
    Id INT          NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT          NOT NULL,
    Created TIMESTAMP(6)  NOT NULL,
    Updated TIMESTAMP(6)  NOT NULL,
    TenantId INT          NOT NULL,
    Level INT          NOT NULL,
    Message TEXT     NOT NULL,
    "User" VARCHAR(128) NOT NULL,
    Error TEXT     NULL,
    Comment TEXT     NULL,
    Owner VARCHAR(128) NULL,
    OwnerType VARCHAR(128) NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "Lookup" (
    Id INT           NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT           NOT NULL,
    Created TIMESTAMP(6)   NOT NULL,
    Updated TIMESTAMP(6)   NOT NULL,
    RegulationId INT           NOT NULL,
    Name VARCHAR(128)  NOT NULL,
    NameLocalizations TEXT      NULL,
    Description TEXT      NULL,
    DescriptionLocalizations TEXT      NULL,
    OverrideType INT           NOT NULL,
    RangeSize DECIMAL(28,6) NULL,
    Attributes TEXT      NULL,
    RangeMode INT           NOT NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "LookupAudit" (
    Id INT           NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT           NOT NULL,
    Created TIMESTAMP(6)   NOT NULL,
    Updated TIMESTAMP(6)   NOT NULL,
    LookupId INT           NOT NULL,
    Name VARCHAR(128)  NOT NULL,
    NameLocalizations TEXT      NULL,
    Description TEXT      NULL,
    DescriptionLocalizations TEXT      NULL,
    OverrideType INT           NOT NULL,
    RangeSize DECIMAL(28,6) NULL,
    Attributes TEXT      NULL,
    RangeMode INT           NOT NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "LookupValue" (
    Id INT           NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT           NOT NULL,
    Created TIMESTAMP(6)   NOT NULL,
    Updated TIMESTAMP(6)   NOT NULL,
    LookupId INT           NOT NULL,
    "Key" TEXT      NOT NULL,
    KeyHash INT           NOT NULL,
    RangeValue DECIMAL(28,6) NULL,
    Value TEXT      NOT NULL,
    ValueLocalizations TEXT      NULL,
    OverrideType INT           NOT NULL,
    LookupHash INT           NOT NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "LookupValueAudit" (
    Id INT           NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT           NOT NULL,
    Created TIMESTAMP(6)   NOT NULL,
    Updated TIMESTAMP(6)   NOT NULL,
    LookupValueId INT           NOT NULL,
    "Key" TEXT      NOT NULL,
    KeyHash INT           NOT NULL,
    RangeValue DECIMAL(28,6) NULL,
    Value TEXT      NOT NULL,
    ValueLocalizations TEXT      NULL,
    OverrideType INT           NOT NULL,
    LookupHash INT           NOT NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "NationalCaseChange" (
    Id INT          NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT          NOT NULL,
    Created TIMESTAMP(6)  NOT NULL,
    Updated TIMESTAMP(6)  NOT NULL,
    TenantId INT          NOT NULL,
    UserId INT          NOT NULL,
    DivisionId INT          NULL,
    CancellationType INT          NOT NULL,
    CancellationId INT          NULL,
    CancellationDate TIMESTAMP(6)  NULL,
    Reason TEXT     NOT NULL,
    ValidationCaseName VARCHAR(128) NULL,
    Forecast VARCHAR(128) NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "NationalCaseDocument" (
    Id INT          NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT          NOT NULL,
    Created TIMESTAMP(6)  NOT NULL,
    Updated TIMESTAMP(6)  NOT NULL,
    CaseValueId INT          NOT NULL,
    Name VARCHAR(256) NOT NULL,
    Content TEXT     NOT NULL,
    ContentType VARCHAR(128) NOT NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "NationalCaseValue" (
    Id INT           NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT           NOT NULL,
    Created TIMESTAMP(6)   NOT NULL,
    Updated TIMESTAMP(6)   NOT NULL,
    TenantId INT           NOT NULL,
    DivisionId INT           NULL,
    CaseName VARCHAR(128)  NOT NULL,
    CaseNameLocalizations TEXT      NULL,
    CaseFieldName VARCHAR(128)  NOT NULL,
    CaseFieldNameLocalizations TEXT      NULL,
    CaseSlot VARCHAR(128)  NULL,
    CaseSlotLocalizations TEXT      NULL,
    ValueType INT           NOT NULL,
    Value TEXT      NOT NULL,
    NumericValue DECIMAL(28,6) NULL,
    Culture VARCHAR(128)  NOT NULL,
    CaseRelation TEXT      NULL,
    CancellationDate TIMESTAMP(6)   NULL,
    Start TIMESTAMP(6)   NULL,
    "End" TIMESTAMP(6)   NULL,
    Forecast VARCHAR(128)  NULL,
    Tags TEXT      NULL,
    Attributes TEXT      NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "NationalCaseValueChange" (
    Id INT         NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT         NOT NULL,
    Created TIMESTAMP(6) NOT NULL,
    Updated TIMESTAMP(6) NOT NULL,
    CaseChangeId INT         NOT NULL,
    CaseValueId INT         NOT NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "Payroll" (
    Id INT          NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT          NOT NULL,
    Created TIMESTAMP(6)  NOT NULL,
    Updated TIMESTAMP(6)  NOT NULL,
    TenantId INT          NOT NULL,
    DivisionId INT          NOT NULL,
    Name VARCHAR(128) NOT NULL,
    NameLocalizations TEXT     NULL,
    Description TEXT     NULL,
    DescriptionLocalizations TEXT     NULL,
    ClusterSet JSON         NULL,
    ClusterSets TEXT     NULL,
    Attributes TEXT     NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "PayrollLayer" (
    Id INT          NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT          NOT NULL,
    Created TIMESTAMP(6)  NOT NULL,
    Updated TIMESTAMP(6)  NOT NULL,
    PayrollId INT          NOT NULL,
    RegulationName VARCHAR(128) NOT NULL,
    Level INT          NOT NULL,
    Priority INT          NOT NULL,
    Attributes TEXT     NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "PayrollResult" (
    Id INT          NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT          NOT NULL,
    Created TIMESTAMP(6)  NOT NULL,
    Updated TIMESTAMP(6)  NOT NULL,
    TenantId INT          NOT NULL,
    PayrollId INT          NOT NULL,
    PayrollName VARCHAR(128) NULL,
    PayrunId INT          NOT NULL,
    PayrunName VARCHAR(128) NULL,
    PayrunJobId INT          NOT NULL,
    PayrunJobName VARCHAR(128) NULL,
    EmployeeId INT          NOT NULL,
    EmployeeIdentifier VARCHAR(128) NULL,
    DivisionId INT          NOT NULL,
    DivisionName VARCHAR(128) NULL,
    CycleName VARCHAR(128) NOT NULL,
    CycleStart TIMESTAMP(6)  NOT NULL,
    CycleEnd TIMESTAMP(6)  NOT NULL,
    PeriodName VARCHAR(128) NOT NULL,
    PeriodStart TIMESTAMP(6)  NOT NULL,
    PeriodEnd TIMESTAMP(6)  NOT NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "Payrun" (
    Id INT          NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT          NOT NULL,
    Created TIMESTAMP(6)  NOT NULL,
    Updated TIMESTAMP(6)  NOT NULL,
    TenantId INT          NOT NULL,
    PayrollId INT          NOT NULL,
    Name VARCHAR(128) NOT NULL,
    NameLocalizations TEXT     NULL,
    DefaultReason TEXT     NULL,
    DefaultReasonLocalizations TEXT     NULL,
    StartExpression TEXT     NULL,
    EmployeeAvailableExpression TEXT     NULL,
    EmployeeStartExpression TEXT     NULL,
    EmployeeEndExpression TEXT     NULL,
    WageTypeAvailableExpression TEXT     NULL,
    EndExpression TEXT     NULL,
    RetroBackCycles INT          NOT NULL,
    Script TEXT     NULL,
    ScriptVersion VARCHAR(128) NULL,
    "Binary" BYTEA     NULL,
    ScriptHash INT          NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "PayrunJob" (
    Id INT          NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT          NOT NULL,
    Created TIMESTAMP(6)  NOT NULL,
    Updated TIMESTAMP(6)  NOT NULL,
    TenantId INT          NOT NULL,
    PayrunId INT          NOT NULL,
    PayrollId INT          NOT NULL,
    DivisionId INT          NOT NULL,
    ParentJobId INT          NULL,
    CreatedUserId INT          NOT NULL,
    ReleasedUserId INT          NULL,
    ProcessedUserId INT          NULL,
    FinishedUserId INT          NULL,
    RetroPayMode INT          NOT NULL,
    JobStatus INT          NOT NULL,
    JobResult INT          NOT NULL,
    Name VARCHAR(128) NOT NULL,
    Owner VARCHAR(128) NULL,
    Forecast VARCHAR(128) NULL,
    CycleName VARCHAR(128) NOT NULL,
    CycleStart TIMESTAMP(6)  NOT NULL,
    CycleEnd TIMESTAMP(6)  NOT NULL,
    PeriodName VARCHAR(128) NOT NULL,
    PeriodStart TIMESTAMP(6)  NOT NULL,
    PeriodEnd TIMESTAMP(6)  NOT NULL,
    EvaluationDate TIMESTAMP(6)  NOT NULL,
    Released TIMESTAMP(6)  NULL,
    Processed TIMESTAMP(6)  NULL,
    Finished TIMESTAMP(6)  NULL,
    CreatedReason TEXT     NOT NULL,
    ReleasedReason TEXT     NULL,
    ProcessedReason TEXT     NULL,
    FinishedReason TEXT     NULL,
    TotalEmployeeCount INT          NOT NULL,
    ProcessedEmployeeCount INT          NOT NULL,
    JobStart TIMESTAMP(6)  NOT NULL,
    JobEnd TIMESTAMP(6)  NULL,
    Message TEXT     NULL,
    ErrorMessage TEXT     NULL,
    Tags TEXT     NULL,
    Attributes TEXT     NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "PayrunJobEmployee" (
    Id INT         NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT         NOT NULL,
    Created TIMESTAMP(6) NOT NULL,
    Updated TIMESTAMP(6) NOT NULL,
    PayrunJobId INT         NOT NULL,
    EmployeeId INT         NOT NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "PayrunParameter" (
    Id INT          NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT          NOT NULL,
    Created TIMESTAMP(6)  NOT NULL,
    Updated TIMESTAMP(6)  NOT NULL,
    PayrunId INT          NOT NULL,
    Name VARCHAR(128) NOT NULL,
    NameLocalizations TEXT     NULL,
    Description TEXT     NULL,
    DescriptionLocalizations TEXT     NULL,
    Mandatory BOOLEAN   NOT NULL,
    Value TEXT     NULL,
    ValueType INT          NOT NULL,
    Attributes TEXT     NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "PayrunResult" (
    Id INT           NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT           NOT NULL,
    Created TIMESTAMP(6)   NOT NULL,
    Updated TIMESTAMP(6)   NOT NULL,
    PayrollResultId INT           NOT NULL,
    TenantId INT           NOT NULL,
    EmployeeId INT           NOT NULL,
    DivisionId INT           NULL,
    Source VARCHAR(128)  NOT NULL,
    Name VARCHAR(128)  NOT NULL,
    NameLocalizations TEXT      NULL,
    Slot VARCHAR(128)  NULL,
    ValueType INT           NOT NULL,
    Value TEXT      NULL,
    NumericValue DECIMAL(28,6) NULL,
    Culture VARCHAR(128)  NOT NULL,
    Start TIMESTAMP(6)   NULL,
    StartHash INT           NOT NULL,
    "End" TIMESTAMP(6)   NULL,
    PayrunJobId INT           NOT NULL,
    Forecast VARCHAR(128)  NULL,
    ParentJobId INT           NULL,
    Tags TEXT      NULL,
    Attributes TEXT      NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "PayrunTrace" (
    Id INT          NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT          NOT NULL,
    Created TIMESTAMP(6)  NOT NULL,
    Updated TIMESTAMP(6)  NOT NULL,
    PayrollResultId INT          NOT NULL,
    TenantId INT          NOT NULL,
    EmployeeId INT          NOT NULL,
    DivisionId INT          NULL,
    Level INT          NOT NULL,
    Text TEXT     NOT NULL,
    PayrunJobId INT          NOT NULL,
    Forecast VARCHAR(128) NULL,
    ParentJobId INT          NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "Regulation" (
    Id INT          NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT          NOT NULL,
    Created TIMESTAMP(6)  NOT NULL,
    Updated TIMESTAMP(6)  NOT NULL,
    TenantId INT          NOT NULL,
    Name VARCHAR(128) NOT NULL,
    NameLocalizations TEXT     NULL,
    Namespace VARCHAR(128) NULL,
    Version INT          NOT NULL,
    SharedRegulation BOOLEAN   NOT NULL,
    ValidFrom TIMESTAMP(6)  NULL,
    Owner VARCHAR(128) NULL,
    Description TEXT     NULL,
    DescriptionLocalizations TEXT     NULL,
    BaseRegulations TEXT     NULL,
    Attributes TEXT     NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "RegulationShare" (
    Id INT         NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT         NOT NULL,
    Created TIMESTAMP(6) NOT NULL,
    Updated TIMESTAMP(6) NOT NULL,
    ProviderTenantId INT         NOT NULL,
    ProviderRegulationId INT         NOT NULL,
    ConsumerTenantId INT         NOT NULL,
    ConsumerDivisionId INT         NULL,
    IsolationLevel INT         NOT NULL DEFAULT 3,
    Attributes TEXT    NULL,
    PRIMARY KEY (Id),
    CONSTRAINT CK_RegulationShare_IsolationLevel CHECK (IsolationLevel IN (0, 1, 2, 3))
);

CREATE TABLE IF NOT EXISTS "Report" (
    Id INT          NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT          NOT NULL,
    Created TIMESTAMP(6)  NOT NULL,
    Updated TIMESTAMP(6)  NOT NULL,
    RegulationId INT          NOT NULL,
    Name VARCHAR(128) NOT NULL,
    NameLocalizations TEXT     NULL,
    Description TEXT     NULL,
    DescriptionLocalizations TEXT     NULL,
    Category VARCHAR(128) NULL,
    Queries TEXT     NULL,
    Relations TEXT     NULL,
    OverrideType INT          NOT NULL,
    AttributeMode INT          NOT NULL,
    UserType INT          NOT NULL,
    ReportIsolation INT          NOT NULL,
    BuildExpression TEXT     NULL,
    StartExpression TEXT     NULL,
    EndExpression TEXT     NULL,
    Script TEXT     NULL,
    ScriptVersion VARCHAR(128) NULL,
    "Binary" BYTEA     NULL,
    ScriptHash INT          NOT NULL,
    Attributes TEXT     NULL,
    Clusters TEXT     NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "ReportAudit" (
    Id INT          NOT NULL GENERATED ALWAYS AS IDENTITY,
    ReportId INT          NOT NULL,
    Status INT          NOT NULL,
    Created TIMESTAMP(6)  NOT NULL,
    Updated TIMESTAMP(6)  NOT NULL,
    Name VARCHAR(128) NOT NULL,
    NameLocalizations TEXT     NULL,
    Description TEXT     NULL,
    DescriptionLocalizations TEXT     NULL,
    Category VARCHAR(128) NULL,
    Queries TEXT     NULL,
    Relations TEXT     NULL,
    AttributeMode INT          NOT NULL,
    OverrideType INT          NOT NULL,
    UserType INT          NOT NULL,
    ReportIsolation INT          NOT NULL,
    BuildExpression TEXT     NULL,
    StartExpression TEXT     NULL,
    EndExpression TEXT     NULL,
    Script TEXT     NULL,
    ScriptVersion VARCHAR(128) NULL,
    "Binary" BYTEA     NULL,
    ScriptHash INT          NOT NULL,
    Attributes TEXT     NULL,
    Clusters TEXT     NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "ReportLog" (
    Id INT          NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT          NOT NULL,
    Created TIMESTAMP(6)  NOT NULL,
    Updated TIMESTAMP(6)  NOT NULL,
    TenantId INT          NOT NULL,
    ReportName VARCHAR(128) NOT NULL,
    ReportDate TIMESTAMP(6)  NOT NULL,
    Message TEXT     NULL,
    "Key" VARCHAR(128) NULL,
    "User" VARCHAR(128) NOT NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "ReportParameter" (
    Id INT          NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT          NOT NULL,
    Created TIMESTAMP(6)  NOT NULL,
    Updated TIMESTAMP(6)  NOT NULL,
    ReportId INT          NOT NULL,
    Name VARCHAR(128) NOT NULL,
    NameLocalizations TEXT     NULL,
    Description TEXT     NULL,
    DescriptionLocalizations TEXT     NULL,
    Mandatory BOOLEAN   NOT NULL,
    Hidden BOOLEAN   NOT NULL,
    Value TEXT     NULL,
    ValueType INT          NOT NULL,
    ParameterType INT          NOT NULL,
    OverrideType INT          NOT NULL,
    Attributes TEXT     NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "ReportParameterAudit" (
    Id INT          NOT NULL GENERATED ALWAYS AS IDENTITY,
    ReportParameterId INT          NOT NULL,
    Status INT          NOT NULL,
    Created TIMESTAMP(6)  NOT NULL,
    Updated TIMESTAMP(6)  NOT NULL,
    Name VARCHAR(128) NOT NULL,
    NameLocalizations TEXT     NULL,
    Description TEXT     NULL,
    DescriptionLocalizations TEXT     NULL,
    Mandatory BOOLEAN   NOT NULL,
    Hidden BOOLEAN   NOT NULL,
    Value TEXT     NULL,
    ValueType INT          NOT NULL,
    ParameterType INT          NOT NULL,
    OverrideType INT          NOT NULL,
    Attributes TEXT     NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "ReportTemplate" (
    Id INT          NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT          NOT NULL,
    Created TIMESTAMP(6)  NOT NULL,
    Updated TIMESTAMP(6)  NOT NULL,
    ReportId INT          NOT NULL,
    Name VARCHAR(128) NOT NULL,
    Culture VARCHAR(128) NOT NULL,
    Content TEXT     NOT NULL,
    ContentType VARCHAR(128) NULL,
    "Schema" TEXT     NULL,
    Resource VARCHAR(256) NULL,
    OverrideType INT          NOT NULL,
    Attributes TEXT     NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "ReportTemplateAudit" (
    Id INT          NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT          NOT NULL,
    Created TIMESTAMP(6)  NOT NULL,
    Updated TIMESTAMP(6)  NOT NULL,
    ReportTemplateId INT          NOT NULL,
    Name VARCHAR(128) NOT NULL,
    Culture VARCHAR(128) NOT NULL,
    Content TEXT     NOT NULL,
    ContentType VARCHAR(128) NULL,
    "Schema" TEXT     NULL,
    Resource VARCHAR(256) NULL,
    OverrideType INT          NOT NULL,
    Attributes TEXT     NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "Script" (
    Id INT          NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT          NOT NULL,
    Created TIMESTAMP(6)  NOT NULL,
    Updated TIMESTAMP(6)  NOT NULL,
    RegulationId INT          NOT NULL,
    Name VARCHAR(128) NOT NULL,
    FunctionTypeMask BIGINT       NOT NULL,
    Value TEXT     NOT NULL,
    OverrideType INT          NOT NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "ScriptAudit" (
    Id INT          NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT          NOT NULL,
    Created TIMESTAMP(6)  NOT NULL,
    Updated TIMESTAMP(6)  NOT NULL,
    ScriptId INT          NOT NULL,
    Name VARCHAR(128) NOT NULL,
    FunctionTypeMask BIGINT       NOT NULL,
    Value TEXT     NOT NULL,
    OverrideType INT          NOT NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "Task" (
    Id INT          NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT          NOT NULL,
    Created TIMESTAMP(6)  NOT NULL,
    Updated TIMESTAMP(6)  NOT NULL,
    TenantId INT          NOT NULL,
    Name VARCHAR(128) NOT NULL,
    NameLocalizations TEXT     NULL,
    Category VARCHAR(128) NULL,
    Instruction TEXT     NOT NULL,
    ScheduledUserId INT          NOT NULL,
    Scheduled TIMESTAMP(6)  NOT NULL,
    CompletedUserId INT          NULL,
    Completed TIMESTAMP(6)  NULL,
    Attributes TEXT     NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "Tenant" (
    Id INT          NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT          NOT NULL,
    Created TIMESTAMP(6)  NOT NULL,
    Updated TIMESTAMP(6)  NOT NULL,
    Identifier VARCHAR(128) NOT NULL,
    Culture VARCHAR(128) NULL,
    Calendar VARCHAR(128) NULL,
    Attributes TEXT     NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "User" (
    Id INT          NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT          NOT NULL,
    Created TIMESTAMP(6)  NOT NULL,
    Updated TIMESTAMP(6)  NOT NULL,
    TenantId INT          NOT NULL,
    Identifier VARCHAR(128) NOT NULL,
    UserType INT          NOT NULL,
    Password VARCHAR(128) NULL,
    StoredSalt BYTEA     NULL,
    FirstName VARCHAR(128) NOT NULL,
    LastName VARCHAR(128) NOT NULL,
    Culture VARCHAR(128) NULL,
    Attributes TEXT     NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "Version" (
    Id INT          NOT NULL GENERATED ALWAYS AS IDENTITY,
    Created TIMESTAMP(6)  NOT NULL,
    MajorVersion INT          NOT NULL,
    MinorVersion INT          NOT NULL,
    SubVersion INT          NOT NULL,
    Owner VARCHAR(128) NOT NULL,
    Description TEXT     NOT NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "WageType" (
    Id INT           NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT           NOT NULL,
    Created TIMESTAMP(6)   NOT NULL,
    Updated TIMESTAMP(6)   NOT NULL,
    RegulationId INT           NOT NULL,
    Name VARCHAR(128)  NOT NULL,
    NameLocalizations TEXT      NULL,
    WageTypeNumber DECIMAL(28,6) NOT NULL,
    Description TEXT      NULL,
    DescriptionLocalizations TEXT      NULL,
    OverrideType INT           NOT NULL,
    ValueType INT           NOT NULL,
    Calendar VARCHAR(128)  NULL,
    Culture VARCHAR(128)  NULL,
    Collectors TEXT      NULL,
    CollectorGroups TEXT      NULL,
    ValueExpression TEXT      NULL,
    ResultExpression TEXT      NULL,
    ValueActions TEXT      NULL,
    ResultActions TEXT      NULL,
    Script TEXT      NULL,
    ScriptVersion VARCHAR(128)  NULL,
    "Binary" BYTEA      NULL,
    ScriptHash INT           NULL,
    Attributes TEXT      NULL,
    Clusters TEXT      NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "WageTypeAudit" (
    Id INT           NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT           NOT NULL,
    Created TIMESTAMP(6)   NOT NULL,
    Updated TIMESTAMP(6)   NOT NULL,
    WageTypeId INT           NOT NULL,
    Name VARCHAR(128)  NOT NULL,
    NameLocalizations TEXT      NULL,
    WageTypeNumber DECIMAL(28,6) NOT NULL,
    Description TEXT      NULL,
    DescriptionLocalizations TEXT      NULL,
    OverrideType INT           NOT NULL,
    ValueType INT           NOT NULL,
    Calendar VARCHAR(128)  NULL,
    Culture VARCHAR(128)  NULL,
    Collectors TEXT      NULL,
    CollectorGroups TEXT      NULL,
    ValueExpression TEXT      NULL,
    ResultExpression TEXT      NULL,
    ValueActions TEXT      NULL,
    ResultActions TEXT      NULL,
    Script TEXT      NULL,
    ScriptVersion VARCHAR(128)  NULL,
    "Binary" BYTEA      NULL,
    ScriptHash INT           NULL,
    Attributes TEXT      NULL,
    Clusters TEXT      NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "WageTypeCustomResult" (
    Id INT           NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT           NOT NULL,
    Created TIMESTAMP(6)   NOT NULL,
    Updated TIMESTAMP(6)   NOT NULL,
    WageTypeResultId INT           NOT NULL,
    TenantId INT           NOT NULL,
    EmployeeId INT           NOT NULL,
    DivisionId INT           NULL,
    WageTypeNumber DECIMAL(28,6) NOT NULL,
    WageTypeName VARCHAR(128)  NOT NULL,
    WageTypeNameLocalizations TEXT      NULL,
    Source VARCHAR(128)  NOT NULL,
    ValueType INT           NOT NULL,
    Value DECIMAL(28,6) NOT NULL,
    Culture VARCHAR(128)  NOT NULL,
    Start TIMESTAMP(6)   NOT NULL,
    StartHash INT           NOT NULL,
    "End" TIMESTAMP(6)   NOT NULL,
    PayrunJobId INT           NOT NULL,
    Forecast VARCHAR(128)  NULL,
    ParentJobId INT           NULL,
    Tags TEXT      NULL,
    Attributes TEXT      NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "WageTypeResult" (
    Id INT           NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT           NOT NULL,
    Created TIMESTAMP(6)   NOT NULL,
    Updated TIMESTAMP(6)   NOT NULL,
    PayrollResultId INT           NOT NULL,
    TenantId INT           NOT NULL,
    EmployeeId INT           NOT NULL,
    DivisionId INT           NULL,
    WageTypeId INT           NOT NULL,
    WageTypeNumber DECIMAL(28,6) NOT NULL,
    WageTypeName VARCHAR(128)  NOT NULL,
    WageTypeNameLocalizations TEXT      NULL,
    ValueType INT           NOT NULL,
    Value DECIMAL(28,6) NOT NULL,
    Culture VARCHAR(128)  NOT NULL,
    Start TIMESTAMP(6)   NOT NULL,
    StartHash INT           NOT NULL,
    "End" TIMESTAMP(6)   NOT NULL,
    PayrunJobId INT           NOT NULL,
    Forecast VARCHAR(128)  NULL,
    ParentJobId INT           NULL,
    Tags TEXT      NULL,
    Attributes TEXT      NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "Webhook" (
    Id INT          NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT          NOT NULL,
    Created TIMESTAMP(6)  NOT NULL,
    Updated TIMESTAMP(6)  NOT NULL,
    TenantId INT          NOT NULL,
    Name VARCHAR(128) NOT NULL,
    ReceiverAddress VARCHAR(128) NOT NULL,
    Action INT          NOT NULL,
    Attributes TEXT     NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS "WebhookMessage" (
    Id INT          NOT NULL GENERATED ALWAYS AS IDENTITY,
    Status INT          NOT NULL,
    Created TIMESTAMP(6)  NOT NULL,
    Updated TIMESTAMP(6)  NOT NULL,
    WebhookId INT          NOT NULL,
    ActionName VARCHAR(128) NOT NULL,
    ReceiverAddress VARCHAR(128) NOT NULL,
    RequestDate TIMESTAMP(6)  NOT NULL,
    RequestMessage TEXT     NULL,
    RequestOperation TEXT     NULL,
    ResponseDate TIMESTAMP(6)  NULL,
    ResponseStatus INT          NULL,
    ResponseMessage TEXT     NULL,
    PRIMARY KEY (Id)
);


-- =============================================================================

-- INDEXES
-- =============================================================================

-- =============================================================================

CREATE UNIQUE INDEX IX_Calendar_UniquePerTenant             ON "Calendar" (Name, TenantId);
CREATE UNIQUE INDEX IX_Case_UniqueNamePerRegulation         ON "Case" (RegulationId, Name);
CREATE UNIQUE INDEX IX_CaseField_UniqueNamePerCase          ON "CaseField" (CaseId, Name);
CREATE        INDEX IX_CaseField_ValueType                  ON "CaseField" (ValueType);
CREATE        INDEX IX_CaseRelation_SourceCaseName          ON "CaseRelation" (RegulationId, SourceCaseName);
CREATE        INDEX IX_CaseRelation_TargetCaseName          ON "CaseRelation" (RegulationId, TargetCaseName);
CREATE        INDEX IX_CaseRelation_TargetSlot              ON "CaseRelation" (RegulationId, TargetCaseSlot);
CREATE UNIQUE INDEX IX_CaseRelation_UniqueRelation          ON "CaseRelation" (RegulationId, RelationHash);
CREATE        INDEX IX_Collector_CollectMode                ON "Collector" (CollectMode);
CREATE UNIQUE INDEX IX_Collector_UniquePerReg               ON "Collector" (Name, RegulationId);
CREATE        INDEX IX_CollectorCustomResult_ResultId       ON "CollectorCustomResult" (CollectorResultId);
CREATE        INDEX IX_CollectorCustomResult_Employee_Coll  ON "CollectorCustomResult" (TenantId, EmployeeId, StartHash, CollectorNameHash);
CREATE        INDEX IX_CollectorResult_PayrollResultId      ON "CollectorResult" (PayrollResultId);
CREATE        INDEX IX_CollectorResult_Employee_Collector   ON "CollectorResult" (TenantId, EmployeeId, StartHash, CollectorNameHash);
CREATE UNIQUE INDEX IX_CompanyCaseValue_Unique              ON "CompanyCaseValue" (TenantId, DivisionId, CaseFieldName, CaseSlot, Created);
CREATE        INDEX IX_CompanyCaseValue_CaseFieldName       ON "CompanyCaseValue" (CaseFieldName);
CREATE        INDEX IX_CompanyCaseValue_Slot                ON "CompanyCaseValue" (CaseSlot);
CREATE        INDEX IX_CompanyCaseValue_TenantId            ON "CompanyCaseValue" (TenantId, CaseFieldName);
CREATE UNIQUE INDEX IX_CompanyCaseValueChange_Unique        ON "CompanyCaseValueChange" (CaseValueId, CaseChangeId);
CREATE UNIQUE INDEX IX_Division_UniquePerTenant             ON "Division" (Name, TenantId);
CREATE        INDEX IX_Employee_TenantId                    ON "Employee" (TenantId, Status);
CREATE        INDEX IX_EmployeeCaseValue_EmployeeId         ON "EmployeeCaseValue" (EmployeeId);
CREATE        INDEX IX_EmployeeCaseValue_CaseFieldName      ON "EmployeeCaseValue" (CaseFieldName);
CREATE        INDEX IX_EmployeeCaseValue_Slot               ON "EmployeeCaseValue" (CaseSlot);
CREATE UNIQUE INDEX IX_EmployeeCaseValue_Unique             ON "EmployeeCaseValue" (EmployeeId, DivisionId, CaseFieldName, CaseSlot, Created);
CREATE UNIQUE INDEX IX_EmployeeCaseValueChange_Unique       ON "EmployeeCaseValueChange" (CaseValueId, CaseChangeId);
CREATE        INDEX IX_GlobalCaseValue_TenantId             ON "GlobalCaseValue" (TenantId);
CREATE        INDEX IX_GlobalCaseValue_CaseFieldName        ON "GlobalCaseValue" (CaseFieldName);
CREATE        INDEX IX_GlobalCaseValue_Slot                 ON "GlobalCaseValue" (CaseSlot);
CREATE UNIQUE INDEX IX_GlobalCaseValue_Unique               ON "GlobalCaseValue" (TenantId, DivisionId, CaseFieldName, CaseSlot, Created);
CREATE UNIQUE INDEX IX_GlobalCaseValueChange_Unique         ON "GlobalCaseValueChange" (CaseValueId, CaseChangeId);
CREATE UNIQUE INDEX IX_Lookup_UniquePerReg                  ON "Lookup" (Name, RegulationId);
CREATE UNIQUE INDEX IX_LookupValue_UniqueValueKeyPerLookup  ON "LookupValue" (LookupId, LookupHash);
CREATE        INDEX IX_NationalCaseValue_TenantId           ON "NationalCaseValue" (TenantId);
CREATE        INDEX IX_NationalCaseValue_CaseFieldName      ON "NationalCaseValue" (CaseFieldName);
CREATE        INDEX IX_NationalCaseValue_Slot               ON "NationalCaseValue" (CaseSlot);
CREATE UNIQUE INDEX IX_NationalCaseValue_Unique             ON "NationalCaseValue" (TenantId, DivisionId, CaseFieldName, CaseSlot, Created);
CREATE UNIQUE INDEX IX_NationalCaseValueChange_Unique       ON "NationalCaseValueChange" (CaseValueId, CaseChangeId);
CREATE UNIQUE INDEX IX_Payroll_UniquePerTenant              ON "Payroll" (TenantId, Name);
CREATE        INDEX IX_PayrollLayer_PayrollId               ON "PayrollLayer" (PayrollId);
CREATE        INDEX IX_PayrollLayer_RegName                 ON "PayrollLayer" (RegulationName);
CREATE        INDEX IX_PayrollResult_TenantId               ON "PayrollResult" (TenantId, EmployeeId);
CREATE        INDEX IX_PayrollResult_PayrunJobId            ON "PayrollResult" (PayrunJobId);
CREATE UNIQUE INDEX IX_Payrun_UniquePerTenant               ON "Payrun" (TenantId, Name);
CREATE        INDEX IX_PayrunJob_TenantId                   ON "PayrunJob" (TenantId, JobStatus);
CREATE        INDEX IX_PayrunJob_PayrunId                   ON "PayrunJob" (PayrunId);
CREATE        INDEX IX_PayrunJob_PeriodStart                ON "PayrunJob" (PeriodStart);
CREATE UNIQUE INDEX IX_PayrunJobEmployee_Unique             ON "PayrunJobEmployee" (PayrunJobId, EmployeeId);
CREATE        INDEX IX_PayrunResult_PayrollResultId         ON "PayrunResult" (PayrollResultId);
CREATE        INDEX IX_PayrunResult_Employee                ON "PayrunResult" (TenantId, EmployeeId);
CREATE        INDEX IX_Regulation_TenantId                  ON "Regulation" (TenantId);
CREATE        INDEX IX_Regulation_Name                      ON "Regulation" (Name);
CREATE UNIQUE INDEX IX_Report_UniquePerReg                  ON "Report" (RegulationId, Name);
CREATE UNIQUE INDEX IX_ReportParameter_UniquePerReport      ON "ReportParameter" (ReportId, Name);
CREATE UNIQUE INDEX IX_ReportTemplate_UniquePerReport       ON "ReportTemplate" (ReportId, Name, Culture);
CREATE UNIQUE INDEX IX_Script_UniquePerReg                  ON "Script" (RegulationId, Name);
CREATE UNIQUE INDEX IX_Tenant_Identifier                    ON "Tenant" (Identifier);
CREATE UNIQUE INDEX IX_User_UniquePerTenant                 ON "User" (TenantId, Identifier);
CREATE UNIQUE INDEX IX_WageType_UniqueNumberPerReg          ON "WageType" (RegulationId, WageTypeNumber);
CREATE        INDEX IX_WageTypeCustomResult_ResultId        ON "WageTypeCustomResult" (WageTypeResultId);
CREATE        INDEX IX_WageTypeCustomResult_Employee_WT     ON "WageTypeCustomResult" (TenantId, EmployeeId, StartHash, WageTypeNumber);
CREATE        INDEX IX_WageTypeResult_PayrollResultId       ON "WageTypeResult" (PayrollResultId);
CREATE        INDEX IX_WageTypeResult_Employee_WT           ON "WageTypeResult" (TenantId, EmployeeId, StartHash, WageTypeNumber);
CREATE UNIQUE INDEX IX_Webhook_UniquePerTenant              ON "Webhook" (TenantId, Name);


-- =============================================================================

-- FUNCTIONS (7)
-- =============================================================================

-- BuildAttributeQuery.pg.sql
-- ----------------------------------------------------------------------
-- =============================================================================
-- BuildAttributeQuery
-- Builds a SQL fragment for dynamic attribute column projection.
-- Used by CaseValue pivot SPs and GetPayrollResultValues.
--
-- T-SQL: imperative WHILE + OPENJSON + string concatenation
-- MySQL: JSON_TABLE with FOR ORDINALITY + GROUP_CONCAT (order preserved)
-- PostgreSQL: jsonb_array_elements_text WITH ORDINALITY + STRING_AGG
--
-- Output: '' if empty, ',' + fragment + newline if attributes present
--
-- Attribute prefix convention:
--   TA_ -> GetTextAttributeValue(field, 'name') AS TA_xxx
--   NA_ -> GetNumericAttributeValue(field, 'name') AS NA_xxx
--   DA_ -> GetDateAttributeValue(field, 'name') AS DA_xxx
--   NULL field -> NULL AS xxx  ("PayrunResult" has no attribute field)
--
-- NOTE: Attribute JSON keys are plain names ("City"), not prefixed ("TA_City").
-- The TA_/NA_/DA_ prefix is the output column alias only.
-- =============================================================================

CREATE OR REPLACE FUNCTION BuildAttributeQuery(
    p_attributeField TEXT,
    p_attributes     TEXT
)
RETURNS TEXT
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_parts TEXT;
    v_sql   TEXT DEFAULT '';
BEGIN
    IF p_attributes IS NULL THEN
        RETURN v_sql;
    END IF;

    IF jsonb_array_length(p_attributes::jsonb) = 0 THEN
        RETURN v_sql;
    END IF;

    SELECT STRING_AGG(
        CASE
            WHEN p_attributeField IS NULL THEN
                'NULL AS ' || j.val
            WHEN LEFT(j.val, 3) = 'TA_' THEN
                'GetTextAttributeValue(' || p_attributeField || ', ''' || SUBSTRING(j.val, 4) || ''') AS ' || j.val
            WHEN LEFT(j.val, 3) = 'DA_' THEN
                'GetDateAttributeValue(' || p_attributeField || ', ''' || SUBSTRING(j.val, 4) || ''') AS ' || j.val
            WHEN LEFT(j.val, 3) = 'NA_' THEN
                'GetNumericAttributeValue(' || p_attributeField || ', ''' || SUBSTRING(j.val, 4) || ''') AS ' || j.val
            ELSE NULL
        END
        , ', ' ORDER BY j.idx
    )
    INTO v_parts
    FROM jsonb_array_elements_text(p_attributes::jsonb) WITH ORDINALITY AS j(val, idx)
    WHERE LENGTH(TRIM(j.val)) > 0;

    IF v_parts IS NOT NULL AND LENGTH(v_parts) > 0 THEN
        v_sql := ',' || v_parts || E'\n        ';
    END IF;

    RETURN v_sql;
END;
$$;

-- GetAttributeNames.pg.sql
-- ----------------------------------------------------------------------
-- =============================================================================
-- GetAttributeNames
-- Builds a comma-separated list of attribute names from a JSON array.
-- Used by GetPayrollResultValues for the outer SELECT projection.
--
-- T-SQL: imperative WHILE + OPENJSON + string concatenation
-- MySQL: JSON_TABLE with FOR ORDINALITY + GROUP_CONCAT
-- PostgreSQL: jsonb_array_elements_text WITH ORDINALITY + STRING_AGG
--
-- Output: '' if empty, ',' + names + newline if non-empty
-- =============================================================================

CREATE OR REPLACE FUNCTION GetAttributeNames(
    p_attributes TEXT
)
RETURNS TEXT
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_parts TEXT;
    v_sql   TEXT DEFAULT '';
BEGIN
    IF p_attributes IS NULL THEN
        RETURN v_sql;
    END IF;

    IF jsonb_array_length(p_attributes::jsonb) = 0 THEN
        RETURN v_sql;
    END IF;

    SELECT STRING_AGG(j.val, ', ' ORDER BY j.idx)
    INTO v_parts
    FROM jsonb_array_elements_text(p_attributes::jsonb) WITH ORDINALITY AS j(val, idx)
    WHERE LENGTH(TRIM(j.val)) > 0;

    IF v_parts IS NOT NULL AND LENGTH(v_parts) > 0 THEN
        v_sql := ',' || v_parts || E'\n        ';
    END IF;

    RETURN v_sql;
END;
$$;

-- GetDateAttributeValue.pg.sql
-- ----------------------------------------------------------------------
-- =============================================================================
-- GetDateAttributeValue
-- Returns TIMESTAMP(6) from a JSON attribute stored as ISO 8601 string.
-- NULL if attribute is not a string or not parseable as timestamp.
--
-- T-SQL: RETURN IIF(@type = 1, CAST(@value AS DATETIME2(7)), NULL)
-- MySQL: JSON_TYPE='STRING' + CAST AS DATETIME(6)
-- PostgreSQL: jsonb_typeof='string' + CAST AS TIMESTAMP(6)
-- =============================================================================

CREATE OR REPLACE FUNCTION GetDateAttributeValue(
    p_attributes TEXT,
    p_name       VARCHAR(255)
)
RETURNS TIMESTAMP(6)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_type TEXT;
    v_raw  VARCHAR(50);
BEGIN
    IF p_attributes IS NULL OR p_name IS NULL THEN
        RETURN NULL;
    END IF;

    v_type := jsonb_typeof(p_attributes::jsonb -> p_name);

    IF v_type = 'string' THEN
        v_raw := p_attributes::jsonb ->> p_name;
        RETURN v_raw::TIMESTAMP(6);
    END IF;

    RETURN NULL;
END;
$$;

-- GetLocalizedValue.pg.sql
-- ----------------------------------------------------------------------
-- =============================================================================
-- GetLocalizedValue
-- Returns the value for the given culture from a JSON localizations object.
-- Falls back to p_fallback if culture key not found.
--
-- T-SQL: SELECT @value = value FROM OPENJSON(@localizations) WHERE [key] = @culture
-- MySQL: JSON_EXTRACT with quoted key syntax $."de-CH" (handles hyphens)
-- PostgreSQL: jsonb ->> key operator (handles any key including hyphens)
--
-- IMPORTANT: Culture codes like "de-CH" contain a hyphen.
-- MySQL requires quoted path $."de-CH". PostgreSQL's ->> operator handles
-- any key natively without quoting concerns.
-- =============================================================================

CREATE OR REPLACE FUNCTION GetLocalizedValue(
    p_localizations TEXT,
    p_culture       VARCHAR(128),
    p_fallback      TEXT
)
RETURNS TEXT
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_value TEXT;
BEGIN
    IF p_localizations IS NULL OR p_culture IS NULL THEN
        RETURN p_fallback;
    END IF;

    v_value := p_localizations::jsonb ->> p_culture;

    IF v_value IS NULL THEN
        RETURN p_fallback;
    END IF;

    RETURN v_value;
END;
$$;

-- GetNumericAttributeValue.pg.sql
-- ----------------------------------------------------------------------
-- =============================================================================
-- GetNumericAttributeValue
-- Returns NUMERIC(28,6) value of a JSON attribute, NULL if not numeric.
--
-- T-SQL: RETURN IIF(@type = 2, CAST(@value AS DECIMAL(28,6)), NULL)
-- MySQL: JSON_TYPE checks for 'INTEGER' or 'DOUBLE'
-- PostgreSQL: jsonb_typeof checks for 'number'
-- =============================================================================

CREATE OR REPLACE FUNCTION GetNumericAttributeValue(
    p_attributes TEXT,
    p_name       VARCHAR(255)
)
RETURNS NUMERIC(28,6)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_type TEXT;
BEGIN
    IF p_attributes IS NULL OR p_name IS NULL THEN
        RETURN NULL;
    END IF;

    v_type := jsonb_typeof(p_attributes::jsonb -> p_name);

    IF v_type = 'number' THEN
        RETURN (p_attributes::jsonb ->> p_name)::NUMERIC(28,6);
    END IF;

    RETURN NULL;
END;
$$;

-- GetTextAttributeValue.pg.sql
-- ----------------------------------------------------------------------
-- =============================================================================
-- GetTextAttributeValue
-- Returns the string value of a JSON attribute key, NULL if type is not string.
--
-- T-SQL: RETURN IIF(@type = 1, @value, NULL)  -- type 1 = string in OPENJSON
-- MySQL: JSON_EXTRACT + JSON_TYPE check for 'STRING'
-- PostgreSQL: jsonb_typeof check for 'string'
-- =============================================================================

CREATE OR REPLACE FUNCTION GetTextAttributeValue(
    p_attributes TEXT,
    p_name       VARCHAR(255)
)
RETURNS TEXT
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_type TEXT;
BEGIN
    IF p_attributes IS NULL OR p_name IS NULL THEN
        RETURN NULL;
    END IF;

    v_type := jsonb_typeof(p_attributes::jsonb -> p_name);

    IF v_type = 'string' THEN
        RETURN p_attributes::jsonb ->> p_name;
    END IF;

    RETURN NULL;
END;
$$;

-- IsMatchingCluster.pg.sql
-- ----------------------------------------------------------------------
-- =============================================================================
-- IsMatchingCluster
-- Tests include/exclude cluster filters against a test cluster array.
-- All arrays are JSON arrays of VARCHAR(128).
--
-- T-SQL: imperative WHILE loop over OPENJSON
-- MySQL: set-based JSON_TABLE + EXISTS / NOT EXISTS
-- PostgreSQL: jsonb_array_elements_text + EXISTS / NOT EXISTS
--
-- Logic:
--   include: every cluster in includeClusters must appear in testClusters
--   exclude: no cluster in excludeClusters may appear in testClusters
--   returns 1 (match) or 0 (no match)
-- =============================================================================

CREATE OR REPLACE FUNCTION IsMatchingCluster(
    p_includeClusters VARCHAR(4000),
    p_excludeClusters VARCHAR(4000),
    p_testClusters    VARCHAR(4000)
)
RETURNS INTEGER
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_testClusters VARCHAR(4000);
BEGIN
    v_testClusters := COALESCE(p_testClusters, '[]');

    IF p_includeClusters IS NOT NULL AND jsonb_array_length(p_includeClusters::jsonb) > 0 THEN
        IF EXISTS (
            SELECT 1
            FROM jsonb_array_elements_text(p_includeClusters::jsonb) AS inc(val)
            WHERE LENGTH(TRIM(inc.val)) > 0
              AND NOT EXISTS (
                SELECT 1
                FROM jsonb_array_elements_text(v_testClusters::jsonb) AS tst(val)
                WHERE tst.val = inc.val)
        ) THEN
            RETURN 0;
        END IF;
    END IF;

    IF p_excludeClusters IS NOT NULL AND jsonb_array_length(p_excludeClusters::jsonb) > 0 THEN
        IF EXISTS (
            SELECT 1
            FROM jsonb_array_elements_text(p_excludeClusters::jsonb) AS exc(val)
            WHERE LENGTH(TRIM(exc.val)) > 0
              AND EXISTS (
                SELECT 1
                FROM jsonb_array_elements_text(v_testClusters::jsonb) AS tst(val)
                WHERE tst.val = exc.val)
        ) THEN
            RETURN 0;
        END IF;
    END IF;

    RETURN 1;
END;
$$;


-- STORED PROCEDURES (44)
-- =============================================================================

-- DeleteAllCaseValues.pg.sql
-- ----------------------------------------------------------------------
-- =============================================================================
-- DeleteAllCaseValues
-- Delegates to the four scope-specific procedures.
-- =============================================================================

CREATE OR REPLACE PROCEDURE DeleteAllCaseValues()
LANGUAGE plpgsql
AS $$
BEGIN
    CALL DeleteAllGlobalCaseValues();
    CALL DeleteAllNationalCaseValues();
    CALL DeleteAllCompanyCaseValues();
    CALL DeleteAllEmployeeCaseValues();
END;
$$;

-- DeleteAllCompanyCaseValues.pg.sql
-- ----------------------------------------------------------------------
-- =============================================================================
-- DeleteAllCompanyCaseValues
-- =============================================================================

CREATE OR REPLACE PROCEDURE DeleteAllCompanyCaseValues()
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM "CompanyCaseValueChange";
    DELETE FROM "CompanyCaseDocument";
    DELETE FROM "CompanyCaseValue";
    DELETE FROM "CompanyCaseChange";
END;
$$;

-- DeleteAllEmployeeCaseValues.pg.sql
-- ----------------------------------------------------------------------
-- =============================================================================
-- DeleteAllEmployeeCaseValues
-- =============================================================================

CREATE OR REPLACE PROCEDURE DeleteAllEmployeeCaseValues()
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM "EmployeeCaseValueChange";
    DELETE FROM "EmployeeCaseDocument";
    DELETE FROM "EmployeeCaseValue";
    DELETE FROM "EmployeeCaseChange";
END;
$$;

-- DeleteAllGlobalCaseValues.pg.sql
-- ----------------------------------------------------------------------
-- =============================================================================
-- DeleteAllGlobalCaseValues
-- =============================================================================

CREATE OR REPLACE PROCEDURE DeleteAllGlobalCaseValues()
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM "GlobalCaseValueChange";
    DELETE FROM "GlobalCaseDocument";
    DELETE FROM "GlobalCaseValue";
    DELETE FROM "GlobalCaseChange";
END;
$$;

-- DeleteAllNationalCaseValues.pg.sql
-- ----------------------------------------------------------------------
-- =============================================================================
-- DeleteAllNationalCaseValues
-- =============================================================================

CREATE OR REPLACE PROCEDURE DeleteAllNationalCaseValues()
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM "NationalCaseValueChange";
    DELETE FROM "NationalCaseDocument";
    DELETE FROM "NationalCaseValue";
    DELETE FROM "NationalCaseChange";
END;
$$;

-- DeleteEmployee.pg.sql
-- ----------------------------------------------------------------------
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
    DELETE FROM "PayrunResult" pr
    USING "PayrollResult" prl
    WHERE pr.PayrollResultId = prl.Id
      AND prl.TenantId = p_tenantId AND prl.EmployeeId = p_employeeId;

    DELETE FROM "WageTypeCustomResult" wtcr
    USING "WageTypeResult" wtr, "PayrollResult" prl
    WHERE wtcr.WageTypeResultId = wtr.Id
      AND wtr.PayrollResultId = prl.Id
      AND prl.TenantId = p_tenantId AND prl.EmployeeId = p_employeeId;

    DELETE FROM "WageTypeResult" wtr
    USING "PayrollResult" prl
    WHERE wtr.PayrollResultId = prl.Id
      AND prl.TenantId = p_tenantId AND prl.EmployeeId = p_employeeId;

    DELETE FROM "CollectorCustomResult" ccr
    USING "CollectorResult" cr, "PayrollResult" prl
    WHERE ccr.CollectorResultId = cr.Id
      AND cr.PayrollResultId = prl.Id
      AND prl.TenantId = p_tenantId AND prl.EmployeeId = p_employeeId;

    DELETE FROM "CollectorResult" cr
    USING "PayrollResult" prl
    WHERE cr.PayrollResultId = prl.Id
      AND prl.TenantId = p_tenantId AND prl.EmployeeId = p_employeeId;

    DELETE FROM "PayrollResult" WHERE TenantId = p_tenantId AND EmployeeId = p_employeeId;

    DELETE FROM "PayrunJobEmployee" pje
    USING "PayrunJob" pj
    WHERE pje.PayrunJobId = pj.Id
      AND pj.TenantId = p_tenantId AND pje.EmployeeId = p_employeeId;

    DELETE FROM "EmployeeCaseValueChange" ecvc
    USING "EmployeeCaseChange" ecc, "Employee" e
    WHERE ecvc.CaseChangeId = ecc.Id
      AND ecc.EmployeeId = e.Id
      AND e.TenantId = p_tenantId AND e.Id = p_employeeId;

    DELETE FROM "EmployeeCaseChange" ecc
    USING "Employee" e
    WHERE ecc.EmployeeId = e.Id
      AND e.TenantId = p_tenantId AND e.Id = p_employeeId;

    DELETE FROM "EmployeeCaseDocument" ecd
    USING "EmployeeCaseValue" ecv, "Employee" e
    WHERE ecd.CaseValueId = ecv.Id
      AND ecv.EmployeeId = e.Id
      AND e.TenantId = p_tenantId AND e.Id = p_employeeId;

    DELETE FROM "EmployeeCaseValue" ecv
    USING "Employee" e
    WHERE ecv.EmployeeId = e.Id
      AND e.TenantId = p_tenantId AND e.Id = p_employeeId;

    DELETE FROM "EmployeeDivision" ed
    USING "Employee" e
    WHERE ed.EmployeeId = e.Id
      AND e.TenantId = p_tenantId AND e.Id = p_employeeId;

    DELETE FROM "Employee" WHERE TenantId = p_tenantId AND Id = p_employeeId;
END;
$$;

-- DeleteLookup.pg.sql
-- ----------------------------------------------------------------------
-- =============================================================================
-- DeleteLookup
-- =============================================================================

CREATE OR REPLACE PROCEDURE DeleteLookup(
    IN p_tenantId INTEGER,
    IN p_lookupId INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM "LookupValueAudit" lva
    USING "LookupValue" lv, "Lookup" lk, "Regulation" r
    WHERE lva.LookupValueId = lv.Id
      AND lv.LookupId = lk.Id
      AND lk.RegulationId = r.Id
      AND r.TenantId = p_tenantId AND lk.Id = p_lookupId;

    DELETE FROM "LookupValue" lv
    USING "Lookup" lk, "Regulation" r
    WHERE lv.LookupId = lk.Id
      AND lk.RegulationId = r.Id
      AND r.TenantId = p_tenantId AND lk.Id = p_lookupId;

    DELETE FROM "LookupAudit" la
    USING "Lookup" lk, "Regulation" r
    WHERE la.LookupId = lk.Id
      AND lk.RegulationId = r.Id
      AND r.TenantId = p_tenantId AND lk.Id = p_lookupId;

    DELETE FROM "Lookup" lk
    USING "Regulation" r
    WHERE lk.RegulationId = r.Id
      AND r.TenantId = p_tenantId AND lk.Id = p_lookupId;
END;
$$;

-- DeletePayrunJob.pg.sql
-- ----------------------------------------------------------------------
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
    DELETE FROM "PayrunResult" pr
    USING "PayrollResult" prl
    WHERE pr.PayrollResultId = prl.Id
      AND prl.TenantId = p_tenantId AND prl.PayrunJobId = p_payrunJobId;

    DELETE FROM "WageTypeCustomResult" wtcr
    USING "WageTypeResult" wtr, "PayrollResult" prl
    WHERE wtcr.WageTypeResultId = wtr.Id
      AND wtr.PayrollResultId = prl.Id
      AND prl.TenantId = p_tenantId AND prl.PayrunJobId = p_payrunJobId;

    DELETE FROM "WageTypeResult" wtr
    USING "PayrollResult" prl
    WHERE wtr.PayrollResultId = prl.Id
      AND prl.TenantId = p_tenantId AND prl.PayrunJobId = p_payrunJobId;

    DELETE FROM "CollectorCustomResult" ccr
    USING "CollectorResult" cr, "PayrollResult" prl
    WHERE ccr.CollectorResultId = cr.Id
      AND cr.PayrollResultId = prl.Id
      AND prl.TenantId = p_tenantId AND prl.PayrunJobId = p_payrunJobId;

    DELETE FROM "CollectorResult" cr
    USING "PayrollResult" prl
    WHERE cr.PayrollResultId = prl.Id
      AND prl.TenantId = p_tenantId AND prl.PayrunJobId = p_payrunJobId;

    DELETE FROM "PayrollResult" WHERE TenantId = p_tenantId AND PayrunJobId = p_payrunJobId;

    DELETE FROM "PayrunJobEmployee" pje
    USING "PayrunJob" pj
    WHERE pje.PayrunJobId = pj.Id
      AND pj.TenantId = p_tenantId AND pje.PayrunJobId = p_payrunJobId;

    DELETE FROM "PayrunJob" WHERE TenantId = p_tenantId AND Id = p_payrunJobId;
END;
$$;

-- DeleteTenant.pg.sql
-- ----------------------------------------------------------------------
-- =============================================================================
-- DeleteTenant
-- PostgreSQL: DELETE FROM t USING ... (all joins in USING clause)
-- =============================================================================

CREATE OR REPLACE PROCEDURE DeleteTenant(
    IN p_tenantId INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM "PayrunResult" pr
    USING "PayrollResult" prl
    WHERE pr.PayrollResultId = prl.Id
      AND prl.TenantId = p_tenantId;

    DELETE FROM "WageTypeCustomResult" wtcr
    USING "WageTypeResult" wtr, "PayrollResult" prl
    WHERE wtcr.WageTypeResultId = wtr.Id
      AND wtr.PayrollResultId = prl.Id
      AND prl.TenantId = p_tenantId;

    DELETE FROM "WageTypeResult" wtr
    USING "PayrollResult" prl
    WHERE wtr.PayrollResultId = prl.Id
      AND prl.TenantId = p_tenantId;

    DELETE FROM "CollectorCustomResult" ccr
    USING "CollectorResult" cr, "PayrollResult" prl
    WHERE ccr.CollectorResultId = cr.Id
      AND cr.PayrollResultId = prl.Id
      AND prl.TenantId = p_tenantId;

    DELETE FROM "CollectorResult" cr
    USING "PayrollResult" prl
    WHERE cr.PayrollResultId = prl.Id
      AND prl.TenantId = p_tenantId;

    DELETE FROM "PayrollResult" WHERE TenantId = p_tenantId;

    DELETE FROM "PayrunJobEmployee" pje
    USING "PayrunJob" pj
    WHERE pje.PayrunJobId = pj.Id
      AND pj.TenantId = p_tenantId;

    DELETE FROM "PayrunJob" WHERE TenantId = p_tenantId;

    DELETE FROM "PayrunParameter" pp
    USING "Payrun" pay
    WHERE pp.PayrunId = pay.Id
      AND pay.TenantId = p_tenantId;

    DELETE FROM "Payrun" WHERE TenantId = p_tenantId;

    DELETE FROM "PayrollLayer" pl
    USING "Payroll" pay
    WHERE pl.PayrollId = pay.Id
      AND pay.TenantId = p_tenantId;

    DELETE FROM "Payroll" WHERE TenantId = p_tenantId;

    DELETE FROM "RegulationShare" WHERE ProviderTenantId = p_tenantId OR ConsumerTenantId = p_tenantId;

    DELETE FROM "ReportTemplateAudit" rta
    USING "ReportTemplate" rt, "Report" rp, "Regulation" r
    WHERE rta.ReportTemplateId = rt.Id
      AND rt.ReportId = rp.Id
      AND rp.RegulationId = r.Id
      AND r.TenantId = p_tenantId;

    DELETE FROM "ReportTemplate" rt
    USING "Report" rp, "Regulation" r
    WHERE rt.ReportId = rp.Id
      AND rp.RegulationId = r.Id
      AND r.TenantId = p_tenantId;

    DELETE FROM "ReportParameterAudit" rpa
    USING "ReportParameter" rpar, "Report" rp, "Regulation" r
    WHERE rpa.ReportParameterId = rpar.Id
      AND rpar.ReportId = rp.Id
      AND rp.RegulationId = r.Id
      AND r.TenantId = p_tenantId;

    DELETE FROM "ReportParameter" rpar
    USING "Report" rp, "Regulation" r
    WHERE rpar.ReportId = rp.Id
      AND rp.RegulationId = r.Id
      AND r.TenantId = p_tenantId;

    DELETE FROM "ReportAudit" ra
    USING "Report" rp, "Regulation" r
    WHERE ra.ReportId = rp.Id
      AND rp.RegulationId = r.Id
      AND r.TenantId = p_tenantId;

    DELETE FROM "Report" rp
    USING "Regulation" r
    WHERE rp.RegulationId = r.Id
      AND r.TenantId = p_tenantId;

    DELETE FROM "ScriptAudit" sa
    USING "Script" s, "Regulation" r
    WHERE sa.ScriptId = s.Id
      AND s.RegulationId = r.Id
      AND r.TenantId = p_tenantId;

    DELETE FROM "Script" s
    USING "Regulation" r
    WHERE s.RegulationId = r.Id
      AND r.TenantId = p_tenantId;

    DELETE FROM "LookupValueAudit" lva
    USING "LookupValue" lv, "Lookup" lk, "Regulation" r
    WHERE lva.LookupValueId = lv.Id
      AND lv.LookupId = lk.Id
      AND lk.RegulationId = r.Id
      AND r.TenantId = p_tenantId;

    DELETE FROM "LookupValue" lv
    USING "Lookup" lk, "Regulation" r
    WHERE lv.LookupId = lk.Id
      AND lk.RegulationId = r.Id
      AND r.TenantId = p_tenantId;

    DELETE FROM "LookupAudit" la
    USING "Lookup" lk, "Regulation" r
    WHERE la.LookupId = lk.Id
      AND lk.RegulationId = r.Id
      AND r.TenantId = p_tenantId;

    DELETE FROM "Lookup" lk
    USING "Regulation" r
    WHERE lk.RegulationId = r.Id
      AND r.TenantId = p_tenantId;

    DELETE FROM "CollectorAudit" coa
    USING "Collector" co, "Regulation" r
    WHERE coa.CollectorId = co.Id
      AND co.RegulationId = r.Id
      AND r.TenantId = p_tenantId;

    DELETE FROM "Collector" co
    USING "Regulation" r
    WHERE co.RegulationId = r.Id
      AND r.TenantId = p_tenantId;

    DELETE FROM "WageTypeAudit" wta
    USING "WageType" wt, "Regulation" r
    WHERE wta.WageTypeId = wt.Id
      AND wt.RegulationId = r.Id
      AND r.TenantId = p_tenantId;

    DELETE FROM "WageType" wt
    USING "Regulation" r
    WHERE wt.RegulationId = r.Id
      AND r.TenantId = p_tenantId;

    DELETE FROM "CaseRelationAudit" cra
    USING "CaseRelation" cr, "Regulation" r
    WHERE cra.CaseRelationId = cr.Id
      AND cr.RegulationId = r.Id
      AND r.TenantId = p_tenantId;

    DELETE FROM "CaseRelation" cr
    USING "Regulation" r
    WHERE cr.RegulationId = r.Id
      AND r.TenantId = p_tenantId;

    DELETE FROM "CaseFieldAudit" cfa
    USING "CaseField" cf, "Case" c, "Regulation" r
    WHERE cfa.CaseFieldId = cf.Id
      AND cf.CaseId = c.Id
      AND c.RegulationId = r.Id
      AND r.TenantId = p_tenantId;

    DELETE FROM "CaseField" cf
    USING "Case" c, "Regulation" r
    WHERE cf.CaseId = c.Id
      AND c.RegulationId = r.Id
      AND r.TenantId = p_tenantId;

    DELETE FROM "CaseAudit" ca
    USING "Case" c, "Regulation" r
    WHERE ca.CaseId = c.Id
      AND c.RegulationId = r.Id
      AND r.TenantId = p_tenantId;

    DELETE FROM "Case" c
    USING "Regulation" r
    WHERE c.RegulationId = r.Id
      AND r.TenantId = p_tenantId;

    DELETE FROM "Regulation" WHERE TenantId = p_tenantId;

    DELETE FROM "EmployeeCaseValueChange" ecvc
    USING "EmployeeCaseChange" ecc, "Employee" e
    WHERE ecvc.CaseChangeId = ecc.Id
      AND ecc.EmployeeId = e.Id
      AND e.TenantId = p_tenantId;

    DELETE FROM "EmployeeCaseChange" ecc
    USING "Employee" e
    WHERE ecc.EmployeeId = e.Id
      AND e.TenantId = p_tenantId;

    DELETE FROM "EmployeeCaseDocument" ecd
    USING "EmployeeCaseValue" ecv, "Employee" e
    WHERE ecd.CaseValueId = ecv.Id
      AND ecv.EmployeeId = e.Id
      AND e.TenantId = p_tenantId;

    DELETE FROM "EmployeeCaseValue" ecv
    USING "Employee" e
    WHERE ecv.EmployeeId = e.Id
      AND e.TenantId = p_tenantId;

    DELETE FROM "EmployeeDivision" ed
    USING "Employee" e
    WHERE ed.EmployeeId = e.Id
      AND e.TenantId = p_tenantId;

    DELETE FROM "Employee" WHERE TenantId = p_tenantId;

    DELETE FROM "CompanyCaseValueChange" ccvc
    USING "CompanyCaseChange" ccc
    WHERE ccvc.CaseChangeId = ccc.Id
      AND ccc.TenantId = p_tenantId;

    DELETE FROM "CompanyCaseChange" WHERE TenantId = p_tenantId;

    DELETE FROM "CompanyCaseDocument" ccd
    USING "CompanyCaseValue" ccv
    WHERE ccd.CaseValueId = ccv.Id
      AND ccv.TenantId = p_tenantId;

    DELETE FROM "CompanyCaseValue" WHERE TenantId = p_tenantId;

    DELETE FROM "NationalCaseValueChange" ncvc
    USING "NationalCaseChange" ncc
    WHERE ncvc.CaseChangeId = ncc.Id
      AND ncc.TenantId = p_tenantId;

    DELETE FROM "NationalCaseChange" WHERE TenantId = p_tenantId;

    DELETE FROM "NationalCaseDocument" ncd
    USING "NationalCaseValue" ncv
    WHERE ncd.CaseValueId = ncv.Id
      AND ncv.TenantId = p_tenantId;

    DELETE FROM "NationalCaseValue" WHERE TenantId = p_tenantId;

    DELETE FROM "GlobalCaseValueChange" gcvc
    USING "GlobalCaseChange" gcc
    WHERE gcvc.CaseChangeId = gcc.Id
      AND gcc.TenantId = p_tenantId;

    DELETE FROM "GlobalCaseChange" WHERE TenantId = p_tenantId;

    DELETE FROM "GlobalCaseDocument" gcd
    USING "GlobalCaseValue" gcv
    WHERE gcd.CaseValueId = gcv.Id
      AND gcv.TenantId = p_tenantId;

    DELETE FROM "GlobalCaseValue" WHERE TenantId = p_tenantId;

    DELETE FROM "WebhookMessage" wm
    USING "Webhook" wh
    WHERE wm.WebhookId = wh.Id
      AND wh.TenantId = p_tenantId;

    DELETE FROM "Webhook" WHERE TenantId = p_tenantId;
    DELETE FROM "Task" WHERE TenantId = p_tenantId;
    DELETE FROM "Log" WHERE TenantId = p_tenantId;
    DELETE FROM "ReportLog" WHERE TenantId = p_tenantId;
    DELETE FROM "User" WHERE TenantId = p_tenantId;
    DELETE FROM "Division" WHERE TenantId = p_tenantId;
    DELETE FROM "Calendar" WHERE TenantId = p_tenantId;
    DELETE FROM "Tenant" WHERE Id = p_tenantId;
END;
$$;

-- GetCollectorCustomResults.pg.sql
-- ----------------------------------------------------------------------
-- =============================================================================
-- GetCollectorCustomResults
-- =============================================================================

CREATE OR REPLACE PROCEDURE GetCollectorCustomResults(
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

        SELECT ccr.*
    FROM "CollectorCustomResult" ccr
    WHERE ccr.TenantId = p_tenantId
      AND ccr.EmployeeId = p_employeeId
      AND (p_divisionId IS NULL        OR ccr.DivisionId = p_divisionId)
      AND (p_payrunJobId IS NULL       OR ccr.PayrunJobId = p_payrunJobId)
      AND (p_parentPayrunJobId IS NULL OR ccr.ParentJobId = p_parentPayrunJobId)
      AND (p_collectorNameHashes IS NULL OR v_collectorCount = 0
           OR (v_collectorCount = 1 AND ccr.CollectorNameHash = v_collectorNameHash)
           OR (v_collectorCount > 1 AND ccr.CollectorNameHash IN (
               SELECT CAST(jt.val AS INTEGER)
               FROM jsonb_array_elements_text(p_collectorNameHashes::jsonb) AS jt(val))))
      AND (p_periodStart IS NULL OR ccr.Start BETWEEN p_periodStart AND p_periodEnd)
      AND (p_jobStatus IS NULL OR ccr.PayrunJobId IN (
               SELECT pj.Id FROM "PayrunJob" pj
               WHERE pj.Id = ccr.PayrunJobId
                 AND (pj.JobStatus & p_jobStatus) = pj.JobStatus))
      AND (ccr.Forecast IS NULL OR ccr.Forecast = p_forecast)
      AND (p_evaluationDate IS NULL OR ccr.Created <= p_evaluationDate)
    ORDER BY ccr.Created;
END;
$$;

-- GetCollectorResults.pg.sql
-- ----------------------------------------------------------------------
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

        SELECT cr.*
    FROM "CollectorResult" cr
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
               SELECT pj.Id FROM "PayrunJob" pj
               WHERE pj.Id = cr.PayrunJobId
                 AND (pj.JobStatus & p_jobStatus) = pj.JobStatus))
      AND (cr.Forecast IS NULL OR cr.Forecast = p_forecast)
      AND (p_evaluationDate IS NULL OR cr.Created <= p_evaluationDate)
    ORDER BY cr.Created;
END;
$$;

-- GetCompanyCaseChangeValues.pg.sql
-- ----------------------------------------------------------------------
-- =============================================================================
-- GetCompanyCaseChangeValues
-- =============================================================================

CREATE OR REPLACE PROCEDURE GetCompanyCaseChangeValues(
    IN p_parentId   INTEGER,
    IN p_sql        TEXT,
    IN p_attributes TEXT,
    IN p_culture    TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_attrSql       TEXT;
    v_pivotSql      TEXT;
    v_caseName      TEXT;
    v_caseFieldName TEXT;
    v_caseSlot      TEXT;
BEGIN
    IF p_culture IS NULL THEN
        v_caseName      := '"CompanyCaseValue".CaseName';
        v_caseFieldName := '"CompanyCaseValue".CaseFieldName';
        v_caseSlot      := '"CompanyCaseValue".CaseSlot';
    ELSE
        v_caseName      := 'GetLocalizedValue("CompanyCaseValue".CaseNameLocalizations, ''' || p_culture || ''', "CompanyCaseValue".CaseName)';
        v_caseFieldName := 'GetLocalizedValue("CompanyCaseValue".CaseFieldNameLocalizations, ''' || p_culture || ''', "CompanyCaseValue".CaseFieldName)';
        v_caseSlot      := 'GetLocalizedValue("CompanyCaseValue".CaseSlotLocalizations, ''' || p_culture || ''', "CompanyCaseValue".CaseSlot)';
    END IF;

    v_attrSql  := BuildAttributeQuery('"CompanyCaseValue".Attributes', p_attributes);
    v_pivotSql := 'CREATE TEMP TABLE CompanyCaseChangeValuePivot AS SELECT'
        || ' "CompanyCaseChange".TenantId,'
        || ' "CompanyCaseChange".Id AS CaseChangeId,'
        || ' "CompanyCaseChange".Created AS CaseChangeCreated,'
        || ' "CompanyCaseChange".Reason,'
        || ' "CompanyCaseChange".ValidationCaseName,'
        || ' "CompanyCaseChange".CancellationType,'
        || ' "CompanyCaseChange".CancellationId,'
        || ' "CompanyCaseChange".CancellationDate,'
        || ' NULL AS EmployeeId,'
        || ' "CompanyCaseChange".UserId,'
        || ' "User".Identifier AS UserIdentifier,'
        || ' "CompanyCaseChange".DivisionId,'
        || ' "CompanyCaseValue".Id,'
        || ' "CompanyCaseValue".Created,'
        || ' "CompanyCaseValue".Updated,'
        || ' "CompanyCaseValue".Status,'
        || ' ' || v_caseName      || ' AS CaseName,'
        || ' ' || v_caseFieldName || ' AS CaseFieldName,'
        || ' ' || v_caseSlot      || ' AS CaseSlot,'
        || ' "CompanyCaseValue"."CaseRelation",'
        || ' "CompanyCaseValue".ValueType,'
        || ' "CompanyCaseValue".Value,'
        || ' "CompanyCaseValue".NumericValue,'
        || ' "CompanyCaseValue".Culture,'
        || ' "CompanyCaseValue".Start,'
        || ' "CompanyCaseValue"."End",'
        || ' "CompanyCaseValue".Forecast,'
        || ' "CompanyCaseValue".Tags,'
        || ' "CompanyCaseValue".Attributes,'
        || ' (SELECT COUNT(*) FROM "CompanyCaseDocument" WHERE CaseValueId = "CompanyCaseValue".Id) AS Documents'
        || v_attrSql
        || ' FROM "CompanyCaseValue"'
        || ' LEFT JOIN "CompanyCaseValueChange" ON "CompanyCaseValue".Id = "CompanyCaseValueChange".CaseValueId'
        || ' LEFT JOIN "CompanyCaseChange" ON "CompanyCaseValueChange".CaseChangeId = "CompanyCaseChange".Id'
        || ' LEFT JOIN "User" ON "User".Id = "CompanyCaseChange".UserId'
        || ' WHERE "CompanyCaseChange".TenantId = ' || p_parentId::TEXT;

    DROP TABLE IF EXISTS CompanyCaseChangeValuePivot;

    EXECUTE v_pivotSql;

    EXECUTE p_sql;

    DROP TABLE IF EXISTS CompanyCaseChangeValuePivot;
EXCEPTION WHEN OTHERS THEN
    DROP TABLE IF EXISTS CompanyCaseChangeValuePivot;
    RAISE;
END;
$$;

-- GetCompanyCaseValues.pg.sql
-- ----------------------------------------------------------------------
-- =============================================================================
-- GetCompanyCaseValues
-- =============================================================================

CREATE OR REPLACE PROCEDURE GetCompanyCaseValues(
    IN p_parentId   INTEGER,
    IN p_sql        TEXT,
    IN p_attributes TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_attrSql  TEXT;
    v_pivotSql TEXT;
BEGIN
    v_attrSql  := BuildAttributeQuery('"CompanyCaseValue".Attributes', p_attributes);
    v_pivotSql := 'CREATE TEMP TABLE CompanyCaseValuePivot AS SELECT "CompanyCaseValue".*'
        || v_attrSql
        || ' FROM "CompanyCaseValue" WHERE "CompanyCaseValue".TenantId = '
        || p_parentId::TEXT;

    DROP TABLE IF EXISTS CompanyCaseValuePivot;

    EXECUTE v_pivotSql;

    EXECUTE p_sql;

    DROP TABLE IF EXISTS CompanyCaseValuePivot;
EXCEPTION WHEN OTHERS THEN
    DROP TABLE IF EXISTS CompanyCaseValuePivot;
    RAISE;
END;
$$;

-- GetConsolidatedCollectorCustomResults.pg.sql
-- ----------------------------------------------------------------------
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

        WITH Winners AS (
        SELECT r.Id,
            ROW_NUMBER() OVER (
                PARTITION BY r.CollectorNameHash, r.Start
                ORDER BY r.Created DESC, r.Id DESC
            ) AS RowNumber
        FROM "CollectorCustomResult" r
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
                   SELECT pj.Id FROM "PayrunJob" pj WHERE (pj.JobStatus & p_jobStatus) = pj.JobStatus))
          AND (r.Forecast IS NULL OR r.Forecast = p_forecast)
          AND (p_noRetro = FALSE OR r.ParentJobId IS NULL)
          AND (p_excludeParentJobId IS NULL OR r.ParentJobId IS NULL
               OR r.ParentJobId <> p_excludeParentJobId)
    )
    SELECT r.*
    FROM "CollectorCustomResult" r
    INNER JOIN Winners w ON w.Id = r.Id
    WHERE w.RowNumber = 1;
END;
$$;

-- GetConsolidatedCollectorResults.pg.sql
-- ----------------------------------------------------------------------
-- =============================================================================
-- GetConsolidatedCollectorResults
-- =============================================================================

CREATE OR REPLACE PROCEDURE GetConsolidatedCollectorResults(
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

        WITH Winners AS (
        SELECT r.Id,
            ROW_NUMBER() OVER (
                PARTITION BY r.CollectorNameHash, r.Start
                ORDER BY r.Created DESC, r.Id DESC
            ) AS RowNumber
        FROM "CollectorResult" r
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
                   SELECT pj.Id FROM "PayrunJob" pj WHERE (pj.JobStatus & p_jobStatus) = pj.JobStatus))
          AND (r.Forecast IS NULL OR r.Forecast = p_forecast)
          AND (p_noRetro = FALSE OR r.ParentJobId IS NULL)
          AND (p_excludeParentJobId IS NULL OR r.ParentJobId IS NULL
               OR r.ParentJobId <> p_excludeParentJobId)
    )
    SELECT r.*
    FROM "CollectorResult" r
    INNER JOIN Winners w ON w.Id = r.Id
    WHERE w.RowNumber = 1;
END;
$$;

-- GetConsolidatedPayrunResults.pg.sql
-- ----------------------------------------------------------------------
-- =============================================================================
-- GetConsolidatedPayrunResults
-- =============================================================================

CREATE OR REPLACE PROCEDURE GetConsolidatedPayrunResults(
    IN p_tenantId           INTEGER,
    IN p_employeeId         INTEGER,
    IN p_divisionId         INTEGER,
    IN p_names              TEXT,
    IN p_periodStartHashes  TEXT,
    IN p_jobStatus          INTEGER,
    IN p_forecast           TEXT,
    IN p_evaluationDate     TIMESTAMP(6),
    IN p_noRetro            BOOLEAN,
    IN p_excludeParentJobId INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_name           TEXT;
    v_nameCount      INTEGER;
    v_startHash      INTEGER;
    v_startHashCount INTEGER;
BEGIN
    v_nameCount      := CASE WHEN p_names IS NULL             THEN 0 ELSE jsonb_array_length(p_names::jsonb) END;
    v_startHashCount := CASE WHEN p_periodStartHashes IS NULL THEN 0 ELSE jsonb_array_length(p_periodStartHashes::jsonb) END;

    IF v_nameCount = 1 THEN
        SELECT jt.val INTO v_name
        FROM jsonb_array_elements_text(p_names::jsonb) AS jt(val) LIMIT 1;
    END IF;

    -- single-hash fast path: equality seek on StartHash
    IF v_startHashCount = 1 THEN
        SELECT CAST(jt.val AS INTEGER) INTO v_startHash
        FROM jsonb_array_elements_text(p_periodStartHashes::jsonb) AS jt(val) LIMIT 1;
    END IF;

    -- Phase 1: select winning IDs via index-only scan
    WITH Winners AS (
        SELECT r.Id,
            ROW_NUMBER() OVER (
                PARTITION BY r.Name, r.Start
                ORDER BY r.Created DESC, r.Id DESC
            ) AS RowNumber
        FROM "PayrunResult" r
        WHERE r.TenantId = p_tenantId
          AND r.EmployeeId = p_employeeId
          AND (v_startHashCount = 0 OR
               (v_startHashCount = 1 AND r.StartHash = v_startHash) OR
               (v_startHashCount > 1 AND r.StartHash IN (
                   SELECT CAST(jt.val AS INTEGER)
                   FROM jsonb_array_elements_text(p_periodStartHashes::jsonb) AS jt(val))))
          AND (p_divisionId IS NULL OR r.DivisionId = p_divisionId)
          AND (p_names IS NULL OR v_nameCount = 0
               OR (v_nameCount = 1 AND r.Name = v_name)
               OR (v_nameCount > 1 AND r.Name IN (
                   SELECT jt.val
                   FROM jsonb_array_elements_text(p_names::jsonb) AS jt(val))))
          AND (p_evaluationDate IS NULL OR r.Created <= p_evaluationDate)
          AND (p_jobStatus IS NULL OR r.PayrunJobId IN (
                   SELECT pj.Id FROM "PayrunJob" pj WHERE (pj.JobStatus & p_jobStatus) = pj.JobStatus))
          AND (r.Forecast IS NULL OR r.Forecast = p_forecast)
          AND (p_noRetro = FALSE OR r.ParentJobId IS NULL)
          AND (p_excludeParentJobId IS NULL OR r.ParentJobId IS NULL
               OR r.ParentJobId <> p_excludeParentJobId)
    )
    -- Phase 2: key lookup only for winning rows
    SELECT r.*
    FROM "PayrunResult" r
    INNER JOIN Winners w ON w.Id = r.Id
    WHERE w.RowNumber = 1;
END;
$$;

-- GetConsolidatedWageTypeCustomResults.pg.sql
-- ----------------------------------------------------------------------
-- =============================================================================
-- GetConsolidatedWageTypeCustomResults
-- =============================================================================

CREATE OR REPLACE PROCEDURE GetConsolidatedWageTypeCustomResults(
    IN p_tenantId           INTEGER,
    IN p_employeeId         INTEGER,
    IN p_divisionId         INTEGER,
    IN p_wageTypeNumbers    TEXT,
    IN p_periodStartHashes  TEXT,
    IN p_jobStatus          INTEGER,
    IN p_forecast           TEXT,
    IN p_evaluationDate     TIMESTAMP(6),
    IN p_noRetro            BOOLEAN,
    IN p_excludeParentJobId INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_wageTypeNumber  DECIMAL(28,6);
    v_wageTypeCount   INTEGER;
    v_startHash       INTEGER;
    v_startHashCount  INTEGER;
BEGIN
    v_wageTypeCount  := CASE WHEN p_wageTypeNumbers IS NULL   THEN 0 ELSE jsonb_array_length(p_wageTypeNumbers::jsonb) END;
    v_startHashCount := CASE WHEN p_periodStartHashes IS NULL THEN 0 ELSE jsonb_array_length(p_periodStartHashes::jsonb) END;

    IF v_wageTypeCount = 1 THEN
        SELECT CAST(jt.val AS DECIMAL(28,6)) INTO v_wageTypeNumber
        FROM jsonb_array_elements_text(p_wageTypeNumbers::jsonb) AS jt(val) LIMIT 1;
    END IF;

    IF v_startHashCount = 1 THEN
        SELECT CAST(jt.val AS INTEGER) INTO v_startHash
        FROM jsonb_array_elements_text(p_periodStartHashes::jsonb) AS jt(val) LIMIT 1;
    END IF;

        WITH Winners AS (
        SELECT r.Id,
            ROW_NUMBER() OVER (
                PARTITION BY r.WageTypeNumber, r.Start
                ORDER BY r.Created DESC, r.Id DESC
            ) AS RowNumber
        FROM "WageTypeCustomResult" r
        WHERE r.TenantId = p_tenantId
          AND r.EmployeeId = p_employeeId
          AND (v_startHashCount = 0 OR
               (v_startHashCount = 1 AND r.StartHash = v_startHash) OR
               (v_startHashCount > 1 AND r.StartHash IN (
                   SELECT CAST(jt.val AS INTEGER)
                   FROM jsonb_array_elements_text(p_periodStartHashes::jsonb) AS jt(val))))
          AND (p_divisionId IS NULL OR r.DivisionId = p_divisionId)
          AND (p_wageTypeNumbers IS NULL OR v_wageTypeCount = 0
               OR (v_wageTypeCount = 1 AND r.WageTypeNumber = v_wageTypeNumber)
               OR (v_wageTypeCount > 1 AND r.WageTypeNumber IN (
                   SELECT CAST(jt.val AS DECIMAL(28,6))
                   FROM jsonb_array_elements_text(p_wageTypeNumbers::jsonb) AS jt(val))))
          AND (p_evaluationDate IS NULL OR r.Created <= p_evaluationDate)
          AND (p_jobStatus IS NULL OR r.PayrunJobId IN (
                   SELECT pj.Id FROM "PayrunJob" pj WHERE (pj.JobStatus & p_jobStatus) = pj.JobStatus))
          AND (r.Forecast IS NULL OR r.Forecast = p_forecast)
          AND (p_noRetro = FALSE OR r.ParentJobId IS NULL)
          AND (p_excludeParentJobId IS NULL OR r.ParentJobId IS NULL
               OR r.ParentJobId <> p_excludeParentJobId)
    )
    SELECT r.*
    FROM "WageTypeCustomResult" r
    INNER JOIN Winners w ON w.Id = r.Id
    WHERE w.RowNumber = 1;
END;
$$;

-- GetConsolidatedWageTypeResults.pg.sql
-- ----------------------------------------------------------------------
-- =============================================================================
-- GetConsolidatedWageTypeResults
-- =============================================================================

CREATE OR REPLACE PROCEDURE GetConsolidatedWageTypeResults(
    IN p_tenantId           INTEGER,
    IN p_employeeId         INTEGER,
    IN p_divisionId         INTEGER,
    IN p_wageTypeNumbers    TEXT,
    IN p_periodStartHashes  TEXT,
    IN p_jobStatus          INTEGER,
    IN p_forecast           TEXT,
    IN p_evaluationDate     TIMESTAMP(6),
    IN p_noRetro            BOOLEAN,
    IN p_excludeParentJobId INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_wageTypeNumber  DECIMAL(28,6);
    v_wageTypeCount   INTEGER;
    v_startHash       INTEGER;
    v_startHashCount  INTEGER;
BEGIN
    v_wageTypeCount  := CASE WHEN p_wageTypeNumbers IS NULL   THEN 0 ELSE jsonb_array_length(p_wageTypeNumbers::jsonb) END;
    v_startHashCount := CASE WHEN p_periodStartHashes IS NULL THEN 0 ELSE jsonb_array_length(p_periodStartHashes::jsonb) END;

    IF v_wageTypeCount = 1 THEN
        SELECT CAST(jt.val AS DECIMAL(28,6)) INTO v_wageTypeNumber
        FROM jsonb_array_elements_text(p_wageTypeNumbers::jsonb) AS jt(val) LIMIT 1;
    END IF;

    IF v_startHashCount = 1 THEN
        SELECT CAST(jt.val AS INTEGER) INTO v_startHash
        FROM jsonb_array_elements_text(p_periodStartHashes::jsonb) AS jt(val) LIMIT 1;
    END IF;

        WITH Winners AS (
        SELECT r.Id,
            ROW_NUMBER() OVER (
                PARTITION BY r.WageTypeNumber, r.Start
                ORDER BY r.Created DESC, r.Id DESC
            ) AS RowNumber
        FROM "WageTypeResult" r
        WHERE r.TenantId = p_tenantId
          AND r.EmployeeId = p_employeeId
          AND (v_startHashCount = 0 OR
               (v_startHashCount = 1 AND r.StartHash = v_startHash) OR
               (v_startHashCount > 1 AND r.StartHash IN (
                   SELECT CAST(jt.val AS INTEGER)
                   FROM jsonb_array_elements_text(p_periodStartHashes::jsonb) AS jt(val))))
          AND (p_divisionId IS NULL OR r.DivisionId = p_divisionId)
          AND (p_wageTypeNumbers IS NULL OR v_wageTypeCount = 0
               OR (v_wageTypeCount = 1 AND r.WageTypeNumber = v_wageTypeNumber)
               OR (v_wageTypeCount > 1 AND r.WageTypeNumber IN (
                   SELECT CAST(jt.val AS DECIMAL(28,6))
                   FROM jsonb_array_elements_text(p_wageTypeNumbers::jsonb) AS jt(val))))
          AND (p_evaluationDate IS NULL OR r.Created <= p_evaluationDate)
          AND (p_jobStatus IS NULL OR r.PayrunJobId IN (
                   SELECT pj.Id FROM "PayrunJob" pj WHERE (pj.JobStatus & p_jobStatus) = pj.JobStatus))
          AND (r.Forecast IS NULL OR r.Forecast = p_forecast)
          AND (p_noRetro = FALSE OR r.ParentJobId IS NULL)
          AND (p_excludeParentJobId IS NULL OR r.ParentJobId IS NULL
               OR r.ParentJobId <> p_excludeParentJobId)
    )
    SELECT r.*
    FROM "WageTypeResult" r
    INNER JOIN Winners w ON w.Id = r.Id
    WHERE w.RowNumber = 1;
END;
$$;

-- GetDerivedCaseFields.pg.sql
-- ----------------------------------------------------------------------
-- =============================================================================
-- GetDerivedCaseFields
-- Filtered by case field names.
-- =============================================================================

CREATE OR REPLACE PROCEDURE GetDerivedCaseFields(
    IN p_tenantId        INTEGER,
    IN p_payrollId       INTEGER,
    IN p_regulationDate  TIMESTAMP(6),
    IN p_createdBefore   TIMESTAMP(6),
    IN p_caseFieldNames  TEXT,
    IN p_includeClusters TEXT,
    IN p_excludeClusters TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
        WITH DerivedRegulations AS (
        SELECT r.Id, pl.Level, pl.Priority,
            ROW_NUMBER() OVER (
                PARTITION BY pl.Id, r.Name
                ORDER BY r.ValidFrom DESC, r.Created DESC
            ) AS RowNumber
        FROM "PayrollLayer" pl
        INNER JOIN "Regulation" r ON pl.RegulationName = r.Name
        WHERE r.Status = 0
          AND (r.TenantId = p_tenantId OR r.SharedRegulation = 1)
          AND r.Created <= p_createdBefore
          AND (r.ValidFrom IS NULL OR r.ValidFrom <= p_regulationDate)
          AND pl.Status = 0 AND pl.PayrollId = p_payrollId
    ),
    Regulations AS (SELECT Id, Level, Priority FROM DerivedRegulations WHERE RowNumber = 1)
    SELECT
        reg.Id AS RegulationId, reg.Level, reg.Priority,
        c.Id AS CaseId, c.CaseType,
        cf.*
    FROM "CaseField" cf
    INNER JOIN "Case" c ON cf.CaseId = c.Id
    INNER JOIN Regulations reg ON c.RegulationId = reg.Id
    WHERE cf.Status = 0
      AND cf.Created <= p_createdBefore
      AND ((p_includeClusters IS NULL AND p_excludeClusters IS NULL)
           OR IsMatchingCluster(p_includeClusters, p_excludeClusters, cf.Clusters) = 1)
      AND (p_caseFieldNames IS NULL
           OR LOWER(cf.Name) IN (
               SELECT LOWER(jt.val)
               FROM jsonb_array_elements_text(p_caseFieldNames::jsonb) AS jt(val)))
    ORDER BY reg.Level DESC, reg.Priority DESC;
END;
$$;

-- GetDerivedCaseFieldsOfCase.pg.sql
-- ----------------------------------------------------------------------
-- =============================================================================
-- GetDerivedCaseFieldsOfCase
-- Filtered by case names (not field names).
-- =============================================================================

CREATE OR REPLACE PROCEDURE GetDerivedCaseFieldsOfCase(
    IN p_tenantId        INTEGER,
    IN p_payrollId       INTEGER,
    IN p_regulationDate  TIMESTAMP(6),
    IN p_createdBefore   TIMESTAMP(6),
    IN p_caseNames       TEXT,
    IN p_includeClusters TEXT,
    IN p_excludeClusters TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
        WITH DerivedRegulations AS (
        SELECT r.Id, pl.Level, pl.Priority,
            ROW_NUMBER() OVER (
                PARTITION BY pl.Id, r.Name
                ORDER BY r.ValidFrom DESC, r.Created DESC
            ) AS RowNumber
        FROM "PayrollLayer" pl
        INNER JOIN "Regulation" r ON pl.RegulationName = r.Name
        WHERE r.Status = 0
          AND (r.TenantId = p_tenantId OR r.SharedRegulation = 1)
          AND r.Created <= p_createdBefore
          AND (r.ValidFrom IS NULL OR r.ValidFrom <= p_regulationDate)
          AND pl.Status = 0 AND pl.PayrollId = p_payrollId
    ),
    Regulations AS (SELECT Id, Level, Priority FROM DerivedRegulations WHERE RowNumber = 1)
    SELECT
        reg.Id AS RegulationId, reg.Level, reg.Priority,
        c.Id AS CaseId, c.CaseType,
        cf.*
    FROM "CaseField" cf
    INNER JOIN "Case" c ON cf.CaseId = c.Id
    INNER JOIN Regulations reg ON c.RegulationId = reg.Id
    WHERE cf.Status = 0
      AND cf.Created <= p_createdBefore
      AND ((p_includeClusters IS NULL AND p_excludeClusters IS NULL)
           OR IsMatchingCluster(p_includeClusters, p_excludeClusters, cf.Clusters) = 1)
      AND (p_caseNames IS NULL
           OR LOWER(c.Name) IN (
               SELECT LOWER(jt.val)
               FROM jsonb_array_elements_text(p_caseNames::jsonb) AS jt(val)))
    ORDER BY reg.Level DESC, reg.Priority DESC;
END;
$$;

-- GetDerivedCaseRelations.pg.sql
-- ----------------------------------------------------------------------
-- =============================================================================
-- GetDerivedCaseRelations
-- cr."Order" double-quoted (reserved keyword in PG)
-- Excludes Binary, "Script", ScriptVersion (performance hint)
-- =============================================================================

CREATE OR REPLACE PROCEDURE GetDerivedCaseRelations(
    IN p_tenantId        INTEGER,
    IN p_payrollId       INTEGER,
    IN p_regulationDate  TIMESTAMP(6),
    IN p_createdBefore   TIMESTAMP(6),
    IN p_sourceCaseName  TEXT,
    IN p_targetCaseName  TEXT,
    IN p_includeClusters TEXT,
    IN p_excludeClusters TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
        WITH DerivedRegulations AS (
        SELECT r.Id, pl.Level, pl.Priority,
            ROW_NUMBER() OVER (
                PARTITION BY pl.Id, r.Name
                ORDER BY r.ValidFrom DESC, r.Created DESC
            ) AS RowNumber
        FROM "PayrollLayer" pl
        INNER JOIN "Regulation" r ON pl.RegulationName = r.Name
        WHERE r.Status = 0
          AND (r.TenantId = p_tenantId OR r.SharedRegulation = 1)
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
        cr.OverrideType, cr."Order",
        cr.ScriptHash, cr.Attributes, cr.Clusters,
        cr.BuildActions, cr.ValidateActions
    FROM "CaseRelation" cr
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
END;
$$;

-- GetDerivedCases.pg.sql
-- ----------------------------------------------------------------------
-- =============================================================================
-- GetDerivedCases
-- Excludes Binary, "Script", ScriptVersion (performance hint identical to T-SQL)
-- =============================================================================

CREATE OR REPLACE PROCEDURE GetDerivedCases(
    IN p_tenantId        INTEGER,
    IN p_payrollId       INTEGER,
    IN p_regulationDate  TIMESTAMP(6),
    IN p_createdBefore   TIMESTAMP(6),
    IN p_caseType        INTEGER,
    IN p_caseNames       TEXT,
    IN p_includeClusters TEXT,
    IN p_excludeClusters TEXT,
    IN p_hidden          BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
        WITH DerivedRegulations AS (
        SELECT r.Id, pl.Level, pl.Priority,
            ROW_NUMBER() OVER (
                PARTITION BY pl.Id, r.Name
                ORDER BY r.ValidFrom DESC, r.Created DESC
            ) AS RowNumber
        FROM "PayrollLayer" pl
        INNER JOIN "Regulation" r ON pl.RegulationName = r.Name
        WHERE r.Status = 0
          AND (r.TenantId = p_tenantId OR r.SharedRegulation = 1)
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
    FROM "Case" c
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
               FROM jsonb_array_elements_text(p_caseNames::jsonb) AS jt(val)))
    ORDER BY reg.Level DESC, reg.Priority DESC;
END;
$$;

-- GetDerivedCollectors.pg.sql
-- ----------------------------------------------------------------------
-- =============================================================================
-- GetDerivedCollectors
-- Excludes Binary, "Script", ScriptVersion (performance hint)
-- =============================================================================

CREATE OR REPLACE PROCEDURE GetDerivedCollectors(
    IN p_tenantId        INTEGER,
    IN p_payrollId       INTEGER,
    IN p_regulationDate  TIMESTAMP(6),
    IN p_createdBefore   TIMESTAMP(6),
    IN p_collectorNames  TEXT,
    IN p_includeClusters TEXT,
    IN p_excludeClusters TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
        WITH DerivedRegulations AS (
        SELECT r.Id, pl.Level, pl.Priority,
            ROW_NUMBER() OVER (
                PARTITION BY pl.Id, r.Name
                ORDER BY r.ValidFrom DESC, r.Created DESC
            ) AS RowNumber
        FROM "PayrollLayer" pl
        INNER JOIN "Regulation" r ON pl.RegulationName = r.Name
        WHERE r.Status = 0
          AND (r.TenantId = p_tenantId OR r.SharedRegulation = 1)
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
    FROM "Collector" co
    INNER JOIN Regulations reg ON co.RegulationId = reg.Id
    WHERE co.Status = 0
      AND co.Created <= p_createdBefore
      AND ((p_includeClusters IS NULL AND p_excludeClusters IS NULL)
           OR IsMatchingCluster(p_includeClusters, p_excludeClusters, co.Clusters) = 1)
      AND (p_collectorNames IS NULL
           OR LOWER(co.Name) IN (
               SELECT LOWER(jt.val)
               FROM jsonb_array_elements_text(p_collectorNames::jsonb) AS jt(val)))
    ORDER BY co.Name, reg.Level DESC, reg.Priority DESC;
END;
$$;

-- GetDerivedLookupValues.pg.sql
-- ----------------------------------------------------------------------
-- =============================================================================
-- GetDerivedLookupValues
-- lv."Key" double-quoted (reserved keyword in PG)
-- "Case"-sensitive key filter (no LOWER(), identical to T-SQL)
-- =============================================================================

CREATE OR REPLACE PROCEDURE GetDerivedLookupValues(
    IN p_tenantId       INTEGER,
    IN p_payrollId      INTEGER,
    IN p_regulationDate TIMESTAMP(6),
    IN p_createdBefore  TIMESTAMP(6),
    IN p_lookupNames    TEXT,
    IN p_lookupKeys     TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
        WITH DerivedRegulations AS (
        SELECT r.Id, pl.Level, pl.Priority,
            ROW_NUMBER() OVER (
                PARTITION BY pl.Id, r.Name
                ORDER BY r.ValidFrom DESC, r.Created DESC
            ) AS RowNumber
        FROM "PayrollLayer" pl
        INNER JOIN "Regulation" r ON pl.RegulationName = r.Name
        WHERE r.Status = 0
          AND (r.TenantId = p_tenantId OR r.SharedRegulation = 1)
          AND r.Created <= p_createdBefore
          AND (r.ValidFrom IS NULL OR r.ValidFrom <= p_regulationDate)
          AND pl.Status = 0 AND pl.PayrollId = p_payrollId
    ),
    Regulations AS (SELECT Id, Level, Priority FROM DerivedRegulations WHERE RowNumber = 1)
    SELECT
        reg.Id AS RegulationId, reg.Level, reg.Priority,
        lv.*
    FROM "LookupValue" lv
    INNER JOIN "Lookup" lk ON lv.LookupId = lk.Id
    INNER JOIN Regulations reg ON lk.RegulationId = reg.Id
    WHERE lv.Status = 0
      AND lv.Created <= p_createdBefore
      AND (p_lookupNames IS NULL
           OR LOWER(lk.Name) IN (
               SELECT LOWER(jt.val)
               FROM jsonb_array_elements_text(p_lookupNames::jsonb) AS jt(val)))
      AND (p_lookupKeys IS NULL
           OR lv."Key" IN (
               SELECT jt.val
               FROM jsonb_array_elements_text(p_lookupKeys::jsonb) AS jt(val)))
    ORDER BY reg.Level DESC, reg.Priority DESC;
END;
$$;

-- GetDerivedLookups.pg.sql
-- ----------------------------------------------------------------------
-- =============================================================================
-- GetDerivedLookups
-- =============================================================================

CREATE OR REPLACE PROCEDURE GetDerivedLookups(
    IN p_tenantId       INTEGER,
    IN p_payrollId      INTEGER,
    IN p_regulationDate TIMESTAMP(6),
    IN p_createdBefore  TIMESTAMP(6),
    IN p_lookupNames    TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
        WITH DerivedRegulations AS (
        SELECT r.Id, pl.Level, pl.Priority,
            ROW_NUMBER() OVER (
                PARTITION BY pl.Id, r.Name
                ORDER BY r.ValidFrom DESC, r.Created DESC
            ) AS RowNumber
        FROM "PayrollLayer" pl
        INNER JOIN "Regulation" r ON pl.RegulationName = r.Name
        WHERE r.Status = 0
          AND (r.TenantId = p_tenantId OR r.SharedRegulation = 1)
          AND r.Created <= p_createdBefore
          AND (r.ValidFrom IS NULL OR r.ValidFrom <= p_regulationDate)
          AND pl.Status = 0 AND pl.PayrollId = p_payrollId
    ),
    Regulations AS (SELECT Id, Level, Priority FROM DerivedRegulations WHERE RowNumber = 1)
    SELECT
        reg.Id AS RegulationId, reg.Level, reg.Priority,
        lk.*
    FROM "Lookup" lk
    INNER JOIN Regulations reg ON lk.RegulationId = reg.Id
    WHERE lk.Status = 0
      AND lk.Created <= p_createdBefore
      AND (p_lookupNames IS NULL
           OR LOWER(lk.Name) IN (
               SELECT LOWER(jt.val)
               FROM jsonb_array_elements_text(p_lookupNames::jsonb) AS jt(val)))
    ORDER BY reg.Level DESC, reg.Priority DESC;
END;
$$;

-- GetDerivedPayrollRegulations.pg.sql
-- ----------------------------------------------------------------------
-- =============================================================================
-- GetDerivedPayrollRegulations
-- Inlined CTE replaces GetDerivedRegulations helper.
-- IsolationLevel >= 3 (Write) required for shared regulations as payroll layers.
-- =============================================================================

CREATE OR REPLACE PROCEDURE GetDerivedPayrollRegulations(
    IN p_tenantId       INTEGER,
    IN p_payrollId      INTEGER,
    IN p_regulationDate TIMESTAMP(6),
    IN p_createdBefore  TIMESTAMP(6)
)
LANGUAGE plpgsql
AS $$
BEGIN
        WITH DerivedRegulations AS (
        SELECT r.Id, pl.Level, pl.Priority,
            ROW_NUMBER() OVER (
                PARTITION BY pl.Id, r.Name
                ORDER BY r.ValidFrom DESC, r.Created DESC
            ) AS RowNumber
        FROM "PayrollLayer" pl
        INNER JOIN "Regulation" r ON pl.RegulationName = r.Name
        WHERE r.Status = 0
          AND (
            r.TenantId = p_tenantId
            OR (
              r.SharedRegulation = 1
              AND EXISTS (
                SELECT 1 FROM "RegulationShare" rs
                WHERE rs.ProviderRegulationId = r.Id
                  AND rs.ConsumerTenantId     = p_tenantId
                  AND rs.IsolationLevel       >= 3
              )
            )
          )
          AND r.Created <= p_createdBefore
          AND (r.ValidFrom IS NULL OR r.ValidFrom <= p_regulationDate)
          AND pl.Status = 0 AND pl.PayrollId = p_payrollId
    ),
    Regulations AS (SELECT Id, Level, Priority FROM DerivedRegulations WHERE RowNumber = 1)
    SELECT r.*, reg.Level, reg.Priority
    FROM "Regulation" r
    INNER JOIN Regulations reg ON r.Id = reg.Id
    ORDER BY reg.Level DESC, reg.Priority DESC;
END;
$$;

-- GetDerivedReportParameters.pg.sql
-- ----------------------------------------------------------------------
-- =============================================================================
-- GetDerivedReportParameters
-- =============================================================================

CREATE OR REPLACE PROCEDURE GetDerivedReportParameters(
    IN p_tenantId       INTEGER,
    IN p_payrollId      INTEGER,
    IN p_regulationDate TIMESTAMP(6),
    IN p_createdBefore  TIMESTAMP(6),
    IN p_reportNames    TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
        WITH DerivedRegulations AS (
        SELECT r.Id, pl.Level, pl.Priority,
            ROW_NUMBER() OVER (
                PARTITION BY pl.Id, r.Name
                ORDER BY r.ValidFrom DESC, r.Created DESC
            ) AS RowNumber
        FROM "PayrollLayer" pl
        INNER JOIN "Regulation" r ON pl.RegulationName = r.Name
        WHERE r.Status = 0
          AND (r.TenantId = p_tenantId OR r.SharedRegulation = 1)
          AND r.Created <= p_createdBefore
          AND (r.ValidFrom IS NULL OR r.ValidFrom <= p_regulationDate)
          AND pl.Status = 0 AND pl.PayrollId = p_payrollId
    ),
    Regulations AS (SELECT Id, Level, Priority FROM DerivedRegulations WHERE RowNumber = 1)
    SELECT
        reg.Id AS RegulationId, reg.Level, reg.Priority,
        rpar.*
    FROM "ReportParameter" rpar
    INNER JOIN "Report" rp ON rpar.ReportId = rp.Id
    INNER JOIN Regulations reg ON rp.RegulationId = reg.Id
    WHERE rpar.Status = 0
      AND rpar.Created <= p_createdBefore
      AND (p_reportNames IS NULL
           OR LOWER(rp.Name) IN (
               SELECT LOWER(jt.val)
               FROM jsonb_array_elements_text(p_reportNames::jsonb) AS jt(val)))
    ORDER BY reg.Level DESC, reg.Priority DESC;
END;
$$;

-- GetDerivedReportTemplates.pg.sql
-- ----------------------------------------------------------------------
-- =============================================================================
-- GetDerivedReportTemplates
-- =============================================================================

CREATE OR REPLACE PROCEDURE GetDerivedReportTemplates(
    IN p_tenantId       INTEGER,
    IN p_payrollId      INTEGER,
    IN p_regulationDate TIMESTAMP(6),
    IN p_createdBefore  TIMESTAMP(6),
    IN p_reportNames    TEXT,
    IN p_culture        TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
        WITH DerivedRegulations AS (
        SELECT r.Id, pl.Level, pl.Priority,
            ROW_NUMBER() OVER (
                PARTITION BY pl.Id, r.Name
                ORDER BY r.ValidFrom DESC, r.Created DESC
            ) AS RowNumber
        FROM "PayrollLayer" pl
        INNER JOIN "Regulation" r ON pl.RegulationName = r.Name
        WHERE r.Status = 0
          AND (r.TenantId = p_tenantId OR r.SharedRegulation = 1)
          AND r.Created <= p_createdBefore
          AND (r.ValidFrom IS NULL OR r.ValidFrom <= p_regulationDate)
          AND pl.Status = 0 AND pl.PayrollId = p_payrollId
    ),
    Regulations AS (SELECT Id, Level, Priority FROM DerivedRegulations WHERE RowNumber = 1)
    SELECT
        reg.Id AS RegulationId, reg.Level, reg.Priority,
        rt.*
    FROM "ReportTemplate" rt
    INNER JOIN "Report" rp ON rt.ReportId = rp.Id
    INNER JOIN Regulations reg ON rp.RegulationId = reg.Id
    WHERE rt.Status = 0
      AND rt.Created <= p_createdBefore
      AND (p_reportNames IS NULL
           OR LOWER(rp.Name) IN (
               SELECT LOWER(jt.val)
               FROM jsonb_array_elements_text(p_reportNames::jsonb) AS jt(val)))
      AND (p_culture IS NULL OR rt.Culture = p_culture)
    ORDER BY reg.Level DESC, reg.Priority DESC;
END;
$$;

-- GetDerivedReports.pg.sql
-- ----------------------------------------------------------------------
-- =============================================================================
-- GetDerivedReports
-- Excludes Binary, "Script", ScriptVersion (performance hint)
-- =============================================================================

CREATE OR REPLACE PROCEDURE GetDerivedReports(
    IN p_tenantId        INTEGER,
    IN p_payrollId       INTEGER,
    IN p_regulationDate  TIMESTAMP(6),
    IN p_createdBefore   TIMESTAMP(6),
    IN p_userType        INTEGER,
    IN p_reportNames     TEXT,
    IN p_includeClusters TEXT,
    IN p_excludeClusters TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
        WITH DerivedRegulations AS (
        SELECT r.Id, pl.Level, pl.Priority,
            ROW_NUMBER() OVER (
                PARTITION BY pl.Id, r.Name
                ORDER BY r.ValidFrom DESC, r.Created DESC
            ) AS RowNumber
        FROM "PayrollLayer" pl
        INNER JOIN "Regulation" r ON pl.RegulationName = r.Name
        WHERE r.Status = 0
          AND (r.TenantId = p_tenantId OR r.SharedRegulation = 1)
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
    FROM "Report" rp
    INNER JOIN Regulations reg ON rp.RegulationId = reg.Id
    WHERE rp.Status = 0
      AND rp.Created <= p_createdBefore
      AND (p_userType IS NULL OR rp.UserType <= p_userType)
      AND ((p_includeClusters IS NULL AND p_excludeClusters IS NULL)
           OR IsMatchingCluster(p_includeClusters, p_excludeClusters, rp.Clusters) = 1)
      AND (p_reportNames IS NULL
           OR LOWER(rp.Name) IN (
               SELECT LOWER(jt.val)
               FROM jsonb_array_elements_text(p_reportNames::jsonb) AS jt(val)))
    ORDER BY reg.Level DESC, reg.Priority DESC;
END;
$$;

-- GetDerivedScripts.pg.sql
-- ----------------------------------------------------------------------
-- =============================================================================
-- GetDerivedScripts
-- OverrideType excluded from SELECT (matches T-SQL explicit column list)
-- =============================================================================

CREATE OR REPLACE PROCEDURE GetDerivedScripts(
    IN p_tenantId       INTEGER,
    IN p_payrollId      INTEGER,
    IN p_regulationDate TIMESTAMP(6),
    IN p_createdBefore  TIMESTAMP(6),
    IN p_scriptNames    TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
        WITH DerivedRegulations AS (
        SELECT r.Id, pl.Level, pl.Priority,
            ROW_NUMBER() OVER (
                PARTITION BY pl.Id, r.Name
                ORDER BY r.ValidFrom DESC, r.Created DESC
            ) AS RowNumber
        FROM "PayrollLayer" pl
        INNER JOIN "Regulation" r ON pl.RegulationName = r.Name
        WHERE r.Status = 0
          AND (r.TenantId = p_tenantId OR r.SharedRegulation = 1)
          AND r.Created <= p_createdBefore
          AND (r.ValidFrom IS NULL OR r.ValidFrom <= p_regulationDate)
          AND pl.Status = 0 AND pl.PayrollId = p_payrollId
    ),
    Regulations AS (SELECT Id, Level, Priority FROM DerivedRegulations WHERE RowNumber = 1)
    SELECT
        reg.Id AS RegulationId, reg.Level, reg.Priority,
        s.Id, s.Status, s.Created, s.Updated, s.RegulationId,
        s.Name, s.FunctionTypeMask, s.Value
    FROM "Script" s
    INNER JOIN Regulations reg ON s.RegulationId = reg.Id
    WHERE s.Status = 0
      AND s.Created <= p_createdBefore
      AND (p_scriptNames IS NULL
           OR LOWER(s.Name) IN (
               SELECT LOWER(jt.val)
               FROM jsonb_array_elements_text(p_scriptNames::jsonb) AS jt(val)))
    ORDER BY reg.Level DESC, reg.Priority DESC;
END;
$$;

-- GetDerivedWageTypes.pg.sql
-- ----------------------------------------------------------------------
-- =============================================================================
-- GetDerivedWageTypes
-- Excludes Binary, "Script", ScriptVersion (performance hint identical to T-SQL)
-- =============================================================================

CREATE OR REPLACE PROCEDURE GetDerivedWageTypes(
    IN p_tenantId        INTEGER,
    IN p_payrollId       INTEGER,
    IN p_regulationDate  TIMESTAMP(6),
    IN p_createdBefore   TIMESTAMP(6),
    IN p_wageTypeNumbers TEXT,
    IN p_includeClusters TEXT,
    IN p_excludeClusters TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
        WITH DerivedRegulations AS (
        SELECT r.Id, pl.Level, pl.Priority,
            ROW_NUMBER() OVER (
                PARTITION BY pl.Id, r.Name
                ORDER BY r.ValidFrom DESC, r.Created DESC
            ) AS RowNumber
        FROM "PayrollLayer" pl
        INNER JOIN "Regulation" r ON pl.RegulationName = r.Name
        WHERE r.Status = 0
          AND (r.TenantId = p_tenantId OR r.SharedRegulation = 1)
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
        wt.OverrideType, wt.ValueType, wt."Calendar", wt.Culture,
        wt.Collectors, wt.CollectorGroups,
        wt.ValueExpression, wt.ResultExpression,
        wt.ValueActions, wt.ResultActions,
        wt.ScriptHash, wt.Attributes, wt.Clusters
    FROM "WageType" wt
    INNER JOIN Regulations reg ON wt.RegulationId = reg.Id
    WHERE wt.Status = 0
      AND wt.Created <= p_createdBefore
      AND ((p_includeClusters IS NULL AND p_excludeClusters IS NULL)
           OR IsMatchingCluster(p_includeClusters, p_excludeClusters, wt.Clusters) = 1)
      AND (p_wageTypeNumbers IS NULL
           OR wt.WageTypeNumber IN (
               SELECT CAST(jt.val AS DECIMAL(28,6))
               FROM jsonb_array_elements_text(p_wageTypeNumbers::jsonb) AS jt(val)))
    ORDER BY wt.WageTypeNumber, reg.Level DESC, reg.Priority DESC;
END;
$$;

-- GetEmployeeCaseChangeValues.pg.sql
-- ----------------------------------------------------------------------
-- =============================================================================
-- GetEmployeeCaseChangeValues
-- Filter is EmployeeId (not TenantId); extra JOIN to "Employee" for TenantId
-- =============================================================================

CREATE OR REPLACE PROCEDURE GetEmployeeCaseChangeValues(
    IN p_parentId   INTEGER,
    IN p_sql        TEXT,
    IN p_attributes TEXT,
    IN p_culture    TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_attrSql       TEXT;
    v_pivotSql      TEXT;
    v_caseName      TEXT;
    v_caseFieldName TEXT;
    v_caseSlot      TEXT;
BEGIN
    IF p_culture IS NULL THEN
        v_caseName      := '"EmployeeCaseValue".CaseName';
        v_caseFieldName := '"EmployeeCaseValue".CaseFieldName';
        v_caseSlot      := '"EmployeeCaseValue".CaseSlot';
    ELSE
        v_caseName      := 'GetLocalizedValue("EmployeeCaseValue".CaseNameLocalizations, ''' || p_culture || ''', "EmployeeCaseValue".CaseName)';
        v_caseFieldName := 'GetLocalizedValue("EmployeeCaseValue".CaseFieldNameLocalizations, ''' || p_culture || ''', "EmployeeCaseValue".CaseFieldName)';
        v_caseSlot      := 'GetLocalizedValue("EmployeeCaseValue".CaseSlotLocalizations, ''' || p_culture || ''', "EmployeeCaseValue".CaseSlot)';
    END IF;

    v_attrSql  := BuildAttributeQuery('"EmployeeCaseValue".Attributes', p_attributes);
    v_pivotSql := 'CREATE TEMP TABLE EmployeeCaseChangeValuePivot AS SELECT'
        || ' "Employee".TenantId,'
        || ' "EmployeeCaseChange".Id AS CaseChangeId,'
        || ' "EmployeeCaseChange".Created AS CaseChangeCreated,'
        || ' "EmployeeCaseChange".Reason,'
        || ' "EmployeeCaseChange".ValidationCaseName,'
        || ' "EmployeeCaseChange".CancellationType,'
        || ' "EmployeeCaseChange".CancellationId,'
        || ' "EmployeeCaseChange".CancellationDate,'
        || ' "EmployeeCaseChange".EmployeeId,'
        || ' "EmployeeCaseChange".UserId,'
        || ' "User".Identifier AS UserIdentifier,'
        || ' "EmployeeCaseChange".DivisionId,'
        || ' "EmployeeCaseValue".Id,'
        || ' "EmployeeCaseValue".Created,'
        || ' "EmployeeCaseValue".Updated,'
        || ' "EmployeeCaseValue".Status,'
        || ' ' || v_caseName      || ' AS CaseName,'
        || ' ' || v_caseFieldName || ' AS CaseFieldName,'
        || ' ' || v_caseSlot      || ' AS CaseSlot,'
        || ' "EmployeeCaseValue"."CaseRelation",'
        || ' "EmployeeCaseValue".ValueType,'
        || ' "EmployeeCaseValue".Value,'
        || ' "EmployeeCaseValue".NumericValue,'
        || ' "EmployeeCaseValue".Culture,'
        || ' "EmployeeCaseValue".Start,'
        || ' "EmployeeCaseValue"."End",'
        || ' "EmployeeCaseValue".Forecast,'
        || ' "EmployeeCaseValue".Tags,'
        || ' "EmployeeCaseValue".Attributes,'
        || ' (SELECT COUNT(*) FROM "EmployeeCaseDocument" WHERE CaseValueId = "EmployeeCaseValue".Id) AS Documents'
        || v_attrSql
        || ' FROM "EmployeeCaseValue"'
        || ' LEFT JOIN "EmployeeCaseValueChange" ON "EmployeeCaseValue".Id = "EmployeeCaseValueChange".CaseValueId'
        || ' LEFT JOIN "EmployeeCaseChange" ON "EmployeeCaseValueChange".CaseChangeId = "EmployeeCaseChange".Id'
        || ' LEFT JOIN "User" ON "User".Id = "EmployeeCaseChange".UserId'
        || ' LEFT JOIN "Employee" ON "Employee".Id = "EmployeeCaseChange".EmployeeId'
        || ' WHERE "EmployeeCaseChange".EmployeeId = ' || p_parentId::TEXT;

    DROP TABLE IF EXISTS EmployeeCaseChangeValuePivot;

    EXECUTE v_pivotSql;

    EXECUTE p_sql;

    DROP TABLE IF EXISTS EmployeeCaseChangeValuePivot;
EXCEPTION WHEN OTHERS THEN
    DROP TABLE IF EXISTS EmployeeCaseChangeValuePivot;
    RAISE;
END;
$$;

-- GetEmployeeCaseValues.pg.sql
-- ----------------------------------------------------------------------
-- =============================================================================
-- GetEmployeeCaseValues
-- Filter is EmployeeId (not TenantId) -- employee-scoped pivot
-- =============================================================================

CREATE OR REPLACE PROCEDURE GetEmployeeCaseValues(
    IN p_parentId   INTEGER,
    IN p_sql        TEXT,
    IN p_attributes TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_attrSql  TEXT;
    v_pivotSql TEXT;
BEGIN
    v_attrSql  := BuildAttributeQuery('"EmployeeCaseValue".Attributes', p_attributes);
    v_pivotSql := 'CREATE TEMP TABLE EmployeeCaseValuePivot AS SELECT "EmployeeCaseValue".*'
        || v_attrSql
        || ' FROM "EmployeeCaseValue" WHERE "EmployeeCaseValue".EmployeeId = '
        || p_parentId::TEXT;

    DROP TABLE IF EXISTS EmployeeCaseValuePivot;

    EXECUTE v_pivotSql;

    EXECUTE p_sql;

    DROP TABLE IF EXISTS EmployeeCaseValuePivot;
EXCEPTION WHEN OTHERS THEN
    DROP TABLE IF EXISTS EmployeeCaseValuePivot;
    RAISE;
END;
$$;

-- GetEmployeeCaseValuesByTenant.pg.sql
-- ----------------------------------------------------------------------
-- =============================================================================
-- GetEmployeeCaseValuesByTenant
-- Direct JOIN query -- no pivot, no temp table needed.
-- =============================================================================

CREATE OR REPLACE PROCEDURE GetEmployeeCaseValuesByTenant(
    IN p_tenantId       INTEGER,
    IN p_valueDate      TIMESTAMP(6),
    IN p_evaluationDate TIMESTAMP(6),
    IN p_fieldNames     TEXT,
    IN p_forecast       TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
        SELECT
        ecv.Id, ecv.Status, ecv.Created, ecv.Updated,
        ecv.EmployeeId, ecv.DivisionId,
        ecv.CaseName, ecv.CaseNameLocalizations,
        ecv.CaseFieldName, ecv.CaseFieldNameLocalizations,
        ecv.CaseSlot, ecv.CaseSlotLocalizations,
        ecv.ValueType, ecv.Value, ecv.NumericValue, ecv.Culture,
        ecv."CaseRelation", ecv.CancellationDate, ecv.Start, ecv."End",
        ecv.Forecast, ecv.Tags, ecv.Attributes
    FROM "EmployeeCaseValue" ecv
    INNER JOIN "Employee" e ON e.Id = ecv.EmployeeId
    WHERE e.TenantId = p_tenantId
      AND e.Status = 0
      AND ecv.CancellationDate IS NULL
      AND (p_evaluationDate IS NULL OR ecv.Created <= p_evaluationDate)
      AND (p_valueDate IS NULL OR ecv.Start IS NULL OR ecv.Start <= p_valueDate)
      AND (p_valueDate IS NULL OR ecv.End   IS NULL OR ecv.End   >  p_valueDate)
      AND (
          (p_forecast IS NULL     AND ecv.Forecast IS NULL)
          OR (p_forecast IS NOT NULL AND (ecv.Forecast IS NULL OR ecv.Forecast = p_forecast))
      )
      AND (
          p_fieldNames IS NULL
          OR ecv.CaseFieldName IN (
              SELECT jt.val
              FROM jsonb_array_elements_text(p_fieldNames::jsonb) AS jt(val)
          )
      )
    ORDER BY ecv.EmployeeId ASC, ecv.CaseFieldName ASC, ecv.Created DESC;
END;
$$;

-- GetGlobalCaseChangeValues.pg.sql
-- ----------------------------------------------------------------------
-- =============================================================================
-- GetGlobalCaseChangeValues
-- =============================================================================

CREATE OR REPLACE PROCEDURE GetGlobalCaseChangeValues(
    IN p_parentId   INTEGER,
    IN p_sql        TEXT,
    IN p_attributes TEXT,
    IN p_culture    TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_attrSql       TEXT;
    v_pivotSql      TEXT;
    v_caseName      TEXT;
    v_caseFieldName TEXT;
    v_caseSlot      TEXT;
BEGIN
    IF p_culture IS NULL THEN
        v_caseName      := '"GlobalCaseValue".CaseName';
        v_caseFieldName := '"GlobalCaseValue".CaseFieldName';
        v_caseSlot      := '"GlobalCaseValue".CaseSlot';
    ELSE
        v_caseName      := 'GetLocalizedValue("GlobalCaseValue".CaseNameLocalizations, ''' || p_culture || ''', "GlobalCaseValue".CaseName)';
        v_caseFieldName := 'GetLocalizedValue("GlobalCaseValue".CaseFieldNameLocalizations, ''' || p_culture || ''', "GlobalCaseValue".CaseFieldName)';
        v_caseSlot      := 'GetLocalizedValue("GlobalCaseValue".CaseSlotLocalizations, ''' || p_culture || ''', "GlobalCaseValue".CaseSlot)';
    END IF;

    v_attrSql  := BuildAttributeQuery('"GlobalCaseValue".Attributes', p_attributes);
    v_pivotSql := 'CREATE TEMP TABLE GlobalCaseChangeValuePivot AS SELECT'
        || ' "GlobalCaseChange".TenantId,'
        || ' "GlobalCaseChange".Id AS CaseChangeId,'
        || ' "GlobalCaseChange".Created AS CaseChangeCreated,'
        || ' "GlobalCaseChange".Reason,'
        || ' "GlobalCaseChange".ValidationCaseName,'
        || ' "GlobalCaseChange".CancellationType,'
        || ' "GlobalCaseChange".CancellationId,'
        || ' "GlobalCaseChange".CancellationDate,'
        || ' NULL AS EmployeeId,'
        || ' "GlobalCaseChange".UserId,'
        || ' "User".Identifier AS UserIdentifier,'
        || ' "GlobalCaseChange".DivisionId,'
        || ' "GlobalCaseValue".Id,'
        || ' "GlobalCaseValue".Created,'
        || ' "GlobalCaseValue".Updated,'
        || ' "GlobalCaseValue".Status,'
        || ' ' || v_caseName      || ' AS CaseName,'
        || ' ' || v_caseFieldName || ' AS CaseFieldName,'
        || ' ' || v_caseSlot      || ' AS CaseSlot,'
        || ' "GlobalCaseValue"."CaseRelation",'
        || ' "GlobalCaseValue".ValueType,'
        || ' "GlobalCaseValue".Value,'
        || ' "GlobalCaseValue".NumericValue,'
        || ' "GlobalCaseValue".Culture,'
        || ' "GlobalCaseValue".Start,'
        || ' "GlobalCaseValue"."End",'
        || ' "GlobalCaseValue".Forecast,'
        || ' "GlobalCaseValue".Tags,'
        || ' "GlobalCaseValue".Attributes,'
        || ' (SELECT COUNT(*) FROM "GlobalCaseDocument" WHERE CaseValueId = "GlobalCaseValue".Id) AS Documents'
        || v_attrSql
        || ' FROM "GlobalCaseValue"'
        || ' LEFT JOIN "GlobalCaseValueChange" ON "GlobalCaseValue".Id = "GlobalCaseValueChange".CaseValueId'
        || ' LEFT JOIN "GlobalCaseChange" ON "GlobalCaseValueChange".CaseChangeId = "GlobalCaseChange".Id'
        || ' LEFT JOIN "User" ON "User".Id = "GlobalCaseChange".UserId'
        || ' WHERE "GlobalCaseChange".TenantId = ' || p_parentId::TEXT;

    DROP TABLE IF EXISTS GlobalCaseChangeValuePivot;

    EXECUTE v_pivotSql;

    EXECUTE p_sql;

    DROP TABLE IF EXISTS GlobalCaseChangeValuePivot;
EXCEPTION WHEN OTHERS THEN
    DROP TABLE IF EXISTS GlobalCaseChangeValuePivot;
    RAISE;
END;
$$;

-- GetGlobalCaseValues.pg.sql
-- ----------------------------------------------------------------------
-- =============================================================================
-- GetGlobalCaseValues
-- Creates TEMP TABLE pivot + executes caller query against it.
-- =============================================================================

CREATE OR REPLACE PROCEDURE GetGlobalCaseValues(
    IN p_parentId   INTEGER,
    IN p_sql        TEXT,
    IN p_attributes TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_attrSql  TEXT;
    v_pivotSql TEXT;
BEGIN
    v_attrSql  := BuildAttributeQuery('"GlobalCaseValue".Attributes', p_attributes);
    v_pivotSql := 'CREATE TEMP TABLE GlobalCaseValuePivot AS SELECT "GlobalCaseValue".*'
        || v_attrSql
        || ' FROM "GlobalCaseValue" WHERE "GlobalCaseValue".TenantId = '
        || p_parentId::TEXT;

    DROP TABLE IF EXISTS GlobalCaseValuePivot;

    EXECUTE v_pivotSql;

    EXECUTE p_sql;

    DROP TABLE IF EXISTS GlobalCaseValuePivot;
EXCEPTION WHEN OTHERS THEN
    DROP TABLE IF EXISTS GlobalCaseValuePivot;
    RAISE;
END;
$$;

-- GetLookupRangeValue.pg.sql
-- ----------------------------------------------------------------------
-- =============================================================================
-- GetLookupRangeValue
-- =============================================================================

CREATE OR REPLACE PROCEDURE GetLookupRangeValue(
    IN p_lookupId   INTEGER,
    IN p_rangeValue DECIMAL(28,6),
    IN p_keyHash    INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_rangeSize DECIMAL(28,6) DEFAULT 0.0;
    v_minValue  DECIMAL(28,6);
    v_maxValue  DECIMAL(28,6);
BEGIN
    SELECT COALESCE(RangeSize, 0.0) INTO v_rangeSize
    FROM "Lookup" WHERE Id = p_lookupId;

    SELECT MIN(lv.RangeValue), MAX(lv.RangeValue) + v_rangeSize
    INTO v_minValue, v_maxValue
    FROM "LookupValue" lv
    INNER JOIN "Lookup" lk ON lv.LookupId = lk.Id
    WHERE lk.Id = p_lookupId;

    IF v_minValue IS NULL
       OR p_rangeValue < v_minValue
       OR p_rangeValue > v_maxValue THEN
        SELECT * FROM "LookupValue" WHERE 1 = 0;
    ELSE
                SELECT lv.*
        FROM "LookupValue" lv
        INNER JOIN "Lookup" lk ON lv.LookupId = lk.Id
        WHERE lk.Id = p_lookupId
          AND lv.RangeValue <= p_rangeValue
          AND (p_keyHash IS NULL OR lv.KeyHash = p_keyHash)
        ORDER BY lv.RangeValue DESC
        LIMIT 1;
    END IF;
END;
$$;

-- GetNationalCaseChangeValues.pg.sql
-- ----------------------------------------------------------------------
-- =============================================================================
-- GetNationalCaseChangeValues
-- =============================================================================

CREATE OR REPLACE PROCEDURE GetNationalCaseChangeValues(
    IN p_parentId   INTEGER,
    IN p_sql        TEXT,
    IN p_attributes TEXT,
    IN p_culture    TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_attrSql       TEXT;
    v_pivotSql      TEXT;
    v_caseName      TEXT;
    v_caseFieldName TEXT;
    v_caseSlot      TEXT;
BEGIN
    IF p_culture IS NULL THEN
        v_caseName      := '"NationalCaseValue".CaseName';
        v_caseFieldName := '"NationalCaseValue".CaseFieldName';
        v_caseSlot      := '"NationalCaseValue".CaseSlot';
    ELSE
        v_caseName      := 'GetLocalizedValue("NationalCaseValue".CaseNameLocalizations, ''' || p_culture || ''', "NationalCaseValue".CaseName)';
        v_caseFieldName := 'GetLocalizedValue("NationalCaseValue".CaseFieldNameLocalizations, ''' || p_culture || ''', "NationalCaseValue".CaseFieldName)';
        v_caseSlot      := 'GetLocalizedValue("NationalCaseValue".CaseSlotLocalizations, ''' || p_culture || ''', "NationalCaseValue".CaseSlot)';
    END IF;

    v_attrSql  := BuildAttributeQuery('"NationalCaseValue".Attributes', p_attributes);
    v_pivotSql := 'CREATE TEMP TABLE NationalCaseChangeValuePivot AS SELECT'
        || ' "NationalCaseChange".TenantId,'
        || ' "NationalCaseChange".Id AS CaseChangeId,'
        || ' "NationalCaseChange".Created AS CaseChangeCreated,'
        || ' "NationalCaseChange".Reason,'
        || ' "NationalCaseChange".ValidationCaseName,'
        || ' "NationalCaseChange".CancellationType,'
        || ' "NationalCaseChange".CancellationId,'
        || ' "NationalCaseChange".CancellationDate,'
        || ' NULL AS EmployeeId,'
        || ' "NationalCaseChange".UserId,'
        || ' "User".Identifier AS UserIdentifier,'
        || ' "NationalCaseChange".DivisionId,'
        || ' "NationalCaseValue".Id,'
        || ' "NationalCaseValue".Created,'
        || ' "NationalCaseValue".Updated,'
        || ' "NationalCaseValue".Status,'
        || ' ' || v_caseName      || ' AS CaseName,'
        || ' ' || v_caseFieldName || ' AS CaseFieldName,'
        || ' ' || v_caseSlot      || ' AS CaseSlot,'
        || ' "NationalCaseValue"."CaseRelation",'
        || ' "NationalCaseValue".ValueType,'
        || ' "NationalCaseValue".Value,'
        || ' "NationalCaseValue".NumericValue,'
        || ' "NationalCaseValue".Culture,'
        || ' "NationalCaseValue".Start,'
        || ' "NationalCaseValue"."End",'
        || ' "NationalCaseValue".Forecast,'
        || ' "NationalCaseValue".Tags,'
        || ' "NationalCaseValue".Attributes,'
        || ' (SELECT COUNT(*) FROM "NationalCaseDocument" WHERE CaseValueId = "NationalCaseValue".Id) AS Documents'
        || v_attrSql
        || ' FROM "NationalCaseValue"'
        || ' LEFT JOIN "NationalCaseValueChange" ON "NationalCaseValue".Id = "NationalCaseValueChange".CaseValueId'
        || ' LEFT JOIN "NationalCaseChange" ON "NationalCaseValueChange".CaseChangeId = "NationalCaseChange".Id'
        || ' LEFT JOIN "User" ON "User".Id = "NationalCaseChange".UserId'
        || ' WHERE "NationalCaseChange".TenantId = ' || p_parentId::TEXT;

    DROP TABLE IF EXISTS NationalCaseChangeValuePivot;

    EXECUTE v_pivotSql;

    EXECUTE p_sql;

    DROP TABLE IF EXISTS NationalCaseChangeValuePivot;
EXCEPTION WHEN OTHERS THEN
    DROP TABLE IF EXISTS NationalCaseChangeValuePivot;
    RAISE;
END;
$$;

-- GetNationalCaseValues.pg.sql
-- ----------------------------------------------------------------------
-- =============================================================================
-- GetNationalCaseValues
-- =============================================================================

CREATE OR REPLACE PROCEDURE GetNationalCaseValues(
    IN p_parentId   INTEGER,
    IN p_sql        TEXT,
    IN p_attributes TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_attrSql  TEXT;
    v_pivotSql TEXT;
BEGIN
    v_attrSql  := BuildAttributeQuery('"NationalCaseValue".Attributes', p_attributes);
    v_pivotSql := 'CREATE TEMP TABLE NationalCaseValuePivot AS SELECT "NationalCaseValue".*'
        || v_attrSql
        || ' FROM "NationalCaseValue" WHERE "NationalCaseValue".TenantId = '
        || p_parentId::TEXT;

    DROP TABLE IF EXISTS NationalCaseValuePivot;

    EXECUTE v_pivotSql;

    EXECUTE p_sql;

    DROP TABLE IF EXISTS NationalCaseValuePivot;
EXCEPTION WHEN OTHERS THEN
    DROP TABLE IF EXISTS NationalCaseValuePivot;
    RAISE;
END;
$$;

-- GetPayrollResultValues.pg.sql
-- ----------------------------------------------------------------------
-- =============================================================================
-- GetPayrollResultValues
-- 5-way UNION ALL pivot of all result types.
-- FORMAT(value, 2) -> to_char(value, 'FM999999999999999999990.00')
-- =============================================================================

CREATE OR REPLACE PROCEDURE GetPayrollResultValues(
    IN p_parentId   INTEGER,
    IN p_sql        TEXT,
    IN p_employeeId INTEGER,
    IN p_divisionId INTEGER,
    IN p_attributes TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_attrNames TEXT;
    v_pivotSql  TEXT;
    v_where     TEXT;
BEGIN
    v_attrNames := GetAttributeNames(p_attributes);

    -- Build WHERE clause
    v_where := '';
    IF p_employeeId IS NOT NULL OR p_divisionId IS NOT NULL THEN
        v_where := ' WHERE ';
        IF p_employeeId IS NOT NULL THEN
            v_where := v_where || '"Employee".Id = ' || p_employeeId::TEXT;
        END IF;
        IF p_employeeId IS NOT NULL AND p_divisionId IS NOT NULL THEN
            v_where := v_where || ' AND ';
        END IF;
        IF p_divisionId IS NOT NULL THEN
            v_where := v_where || '"Division".Id = ' || p_divisionId::TEXT;
        END IF;
    END IF;

    v_pivotSql := 'CREATE TEMP TABLE PayrollResultPivot AS SELECT'
        || ' "PayrollResult".TenantId,'
        || ' "PayrollResult".Id AS PayrollResultId,'
        || ' "PayrollResult".Created,'
        || ' PayrollValue.ResultKind,'
        || ' PayrollValue.ResultId,'
        || ' PayrollValue.ResultParentId,'
        || ' PayrollValue.ResultNumber,'
        || ' PayrollValue.KindName,'
        || ' PayrollValue.ResultCreated,'
        || ' PayrollValue.ResultStart,'
        || ' PayrollValue.ResultEnd,'
        || ' PayrollValue.ResultType,'
        || ' PayrollValue.ResultValue,'
        || ' PayrollValue.ResultNumericValue,'
        || ' PayrollValue.ResultCulture,'
        || ' PayrollValue.ResultTags,'
        || ' PayrollValue.Attributes,'
        || ' "PayrunJob".Id AS JobId,'
        || ' "PayrunJob".Name AS JobName,'
        || ' "PayrunJob".CreatedReason AS JobReason,'
        || ' "PayrunJob".Forecast,'
        || ' "PayrunJob".JobStatus,'
        || ' "PayrunJob".CycleName,'
        || ' "PayrunJob".PeriodName,'
        || ' "PayrunJob".PeriodStart,'
        || ' "PayrunJob".PeriodEnd,'
        || ' "Payrun".Id AS PayrunId,'
        || ' "Payrun".Name AS PayrunName,'
        || ' "Payroll".Id AS PayrollId,'
        || ' "Payroll".Name AS PayrollName,'
        || ' "Division".Id AS DivisionId,'
        || ' "Division".Name AS DivisionName,'
        || ' "Division".Culture,'
        || ' "User".Id AS UserId,'
        || ' "User".Identifier AS UserIdentifier,'
        || ' "Employee".Id AS EmployeeId,'
        || ' "Employee".Identifier AS EmployeeIdentifier'
        || v_attrNames
        || ' FROM ('
        -- "CollectorResult" (kind=10)
        || ' SELECT 10 AS ResultKind,'
        || ' "CollectorResult".PayrollResultId,'
        || ' "CollectorResult".Id AS ResultId,'
        || ' "CollectorResult".PayrollResultId AS ResultParentId,'
        || ' "CollectorResult".CollectorName AS KindName,'
        || ' 0 AS ResultNumber,'
        || ' "CollectorResult".Created AS ResultCreated,'
        || ' "CollectorResult".Start AS ResultStart,'
        || ' "CollectorResult".End AS ResultEnd,'
        || ' "CollectorResult".Tags AS ResultTags,'
        || ' "CollectorResult".Attributes,'
        || ' "CollectorResult".ValueType AS ResultType,'
        || ' to_char("CollectorResult".Value, ''FM999999999999999999990.00'') AS ResultValue,'
        || ' "CollectorResult".Value AS ResultNumericValue,'
        || ' "CollectorResult".Culture AS ResultCulture'
        || BuildAttributeQuery('"CollectorResult".Attributes', p_attributes)
        || ' FROM "CollectorResult"'
        || ' UNION ALL'
        -- "CollectorCustomResult" (kind=11)
        || ' SELECT 11 AS ResultKind,'
        || ' "CollectorResult".PayrollResultId,'
        || ' "CollectorCustomResult".Id AS ResultId,'
        || ' "CollectorResult".Id AS ResultParentId,'
        || ' "CollectorCustomResult".Source AS KindName,'
        || ' 0 AS ResultNumber,'
        || ' "CollectorCustomResult".Created AS ResultCreated,'
        || ' "CollectorCustomResult".Start AS ResultStart,'
        || ' "CollectorCustomResult".End AS ResultEnd,'
        || ' "CollectorCustomResult".Tags AS ResultTags,'
        || ' "CollectorCustomResult".Attributes,'
        || ' "CollectorCustomResult".ValueType AS ResultType,'
        || ' to_char("CollectorCustomResult".Value, ''FM999999999999999999990.00'') AS ResultValue,'
        || ' "CollectorCustomResult".Value AS ResultNumericValue,'
        || ' "CollectorCustomResult".Culture AS ResultCulture'
        || BuildAttributeQuery('"CollectorCustomResult".Attributes', p_attributes)
        || ' FROM "CollectorResult"'
        || ' INNER JOIN "CollectorCustomResult" ON "CollectorResult".Id = "CollectorCustomResult".CollectorResultId'
        || ' UNION ALL'
        -- "WageTypeResult" (kind=20)
        || ' SELECT 20 AS ResultKind,'
        || ' "WageTypeResult".PayrollResultId,'
        || ' "WageTypeResult".Id AS ResultId,'
        || ' "WageTypeResult".PayrollResultId AS ResultParentId,'
        || ' "WageTypeResult".WageTypeName AS KindName,'
        || ' "WageTypeResult".WageTypeNumber AS ResultNumber,'
        || ' "WageTypeResult".Created AS ResultCreated,'
        || ' "WageTypeResult".Start AS ResultStart,'
        || ' "WageTypeResult".End AS ResultEnd,'
        || ' "WageTypeResult".Tags AS ResultTags,'
        || ' "WageTypeResult".Attributes,'
        || ' "WageTypeResult".ValueType AS ResultType,'
        || ' to_char("WageTypeResult".Value, ''FM999999999999999999990.00'') AS ResultValue,'
        || ' "WageTypeResult".Value AS ResultNumericValue,'
        || ' "WageTypeResult".Culture AS ResultCulture'
        || BuildAttributeQuery('"WageTypeResult".Attributes', p_attributes)
        || ' FROM "WageTypeResult"'
        || ' UNION ALL'
        -- "WageTypeCustomResult" (kind=21)
        || ' SELECT 21 AS ResultKind,'
        || ' "WageTypeResult".PayrollResultId,'
        || ' "WageTypeCustomResult".Id AS ResultId,'
        || ' "WageTypeResult".Id AS ResultParentId,'
        || ' "WageTypeCustomResult".Source AS KindName,'
        || ' 0 AS ResultNumber,'
        || ' "WageTypeCustomResult".Created AS ResultCreated,'
        || ' "WageTypeCustomResult".Start AS ResultStart,'
        || ' "WageTypeCustomResult".End AS ResultEnd,'
        || ' "WageTypeCustomResult".Tags AS ResultTags,'
        || ' "WageTypeCustomResult".Attributes,'
        || ' "WageTypeCustomResult".ValueType AS ResultType,'
        || ' to_char("WageTypeCustomResult".Value, ''FM999999999999999999990.00'') AS ResultValue,'
        || ' "WageTypeCustomResult".Value AS ResultNumericValue,'
        || ' "WageTypeCustomResult".Culture AS ResultCulture'
        || BuildAttributeQuery('"WageTypeCustomResult".Attributes', p_attributes)
        || ' FROM "WageTypeResult"'
        || ' INNER JOIN "WageTypeCustomResult" ON "WageTypeResult".Id = "WageTypeCustomResult".WageTypeResultId'
        || ' UNION ALL'
        -- "PayrunResult" (kind=30)
        || ' SELECT 30 AS ResultKind,'
        || ' "PayrunResult".PayrollResultId,'
        || ' "PayrunResult".Id AS ResultId,'
        || ' "PayrunResult".PayrollResultId AS ResultParentId,'
        || ' "PayrunResult".Name AS KindName,'
        || ' 0 AS ResultNumber,'
        || ' "PayrunResult".Created AS ResultCreated,'
        || ' "PayrunResult".Start AS ResultStart,'
        || ' "PayrunResult".End AS ResultEnd,'
        || ' "PayrunResult".Tags AS ResultTags,'
        || ' "PayrunResult".Attributes,'
        || ' "PayrunResult".ValueType AS ResultType,'
        || ' LTRIM("PayrunResult".Value) AS ResultValue,'
        || ' "PayrunResult".NumericValue AS ResultNumericValue,'
        || ' "PayrunResult".Culture AS ResultCulture'
        || BuildAttributeQuery(NULL, p_attributes)
        || ' FROM "PayrunResult"'
        || ') PayrollValue'
        || ' LEFT JOIN "PayrollResult" ON "PayrollResult".Id = PayrollValue.PayrollResultId'
        || ' LEFT JOIN "PayrunJob" ON "PayrollResult".PayrunJobId = "PayrunJob".Id'
        || ' LEFT JOIN "Payrun" ON "PayrunJob".PayrunId = "Payrun".Id'
        || ' LEFT JOIN "Employee" ON "PayrollResult".EmployeeId = "Employee".Id'
        || ' LEFT JOIN "Payroll" ON "PayrollResult".PayrollId = "Payroll".Id'
        || ' LEFT JOIN "Division" ON "Payroll".DivisionId = "Division".Id'
        || ' LEFT JOIN "User" ON "PayrunJob".CreatedUserId = "User".Id'
        || v_where;

    DROP TABLE IF EXISTS PayrollResultPivot;

    EXECUTE v_pivotSql;

    EXECUTE p_sql;

    DROP TABLE IF EXISTS PayrollResultPivot;
EXCEPTION WHEN OTHERS THEN
    DROP TABLE IF EXISTS PayrollResultPivot;
    RAISE;
END;
$$;

-- GetWageTypeCustomResults.pg.sql
-- ----------------------------------------------------------------------
-- =============================================================================
-- GetWageTypeCustomResults
-- =============================================================================

CREATE OR REPLACE PROCEDURE GetWageTypeCustomResults(
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

        SELECT wtcr.*
    FROM "WageTypeCustomResult" wtcr
    WHERE wtcr.TenantId = p_tenantId
      AND wtcr.EmployeeId = p_employeeId
      AND (p_divisionId IS NULL        OR wtcr.DivisionId = p_divisionId)
      AND (p_payrunJobId IS NULL       OR wtcr.PayrunJobId = p_payrunJobId)
      AND (p_parentPayrunJobId IS NULL OR wtcr.ParentJobId = p_parentPayrunJobId)
      AND (p_wageTypeNumbers IS NULL OR v_wageTypeCount = 0
           OR (v_wageTypeCount = 1 AND wtcr.WageTypeNumber = v_wageTypeNumber)
           OR (v_wageTypeCount > 1 AND wtcr.WageTypeNumber IN (
               SELECT CAST(jt.val AS DECIMAL(28,6))
               FROM jsonb_array_elements_text(p_wageTypeNumbers::jsonb) AS jt(val))))
      AND (p_periodStart IS NULL OR wtcr.Start BETWEEN p_periodStart AND p_periodEnd)
      AND (p_jobStatus IS NULL OR wtcr.PayrunJobId IN (
               SELECT pj.Id FROM "PayrunJob" pj
               WHERE pj.Id = wtcr.PayrunJobId
                 AND (pj.JobStatus & p_jobStatus) = pj.JobStatus))
      AND (wtcr.Forecast IS NULL OR wtcr.Forecast = p_forecast)
      AND (p_evaluationDate IS NULL OR wtcr.Created <= p_evaluationDate)
    ORDER BY wtcr.Created;
END;
$$;

-- GetWageTypeResults.pg.sql
-- ----------------------------------------------------------------------
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

        SELECT wtr.*
    FROM "WageTypeResult" wtr
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
               SELECT pj.Id FROM "PayrunJob" pj
               WHERE pj.Id = wtr.PayrunJobId
                 AND (pj.JobStatus & p_jobStatus) = pj.JobStatus))
      AND (wtr.Forecast IS NULL OR wtr.Forecast = p_forecast)
      AND (p_evaluationDate IS NULL OR wtr.Created <= p_evaluationDate)
    ORDER BY wtr.Created;
END;
$$;

-- UpdateStatistics.pg.sql
-- ----------------------------------------------------------------------
-- =============================================================================
-- UpdateStatistics
-- T-SQL: UPDATE STATISTICS ... WITH FULLSCAN -> MySQL: ANALYZE TABLE -> PG: ANALYZE
-- =============================================================================

CREATE OR REPLACE PROCEDURE UpdateStatistics()
LANGUAGE plpgsql
AS $$
DECLARE
    v_table TEXT;
BEGIN
    FOR v_table IN
        SELECT tablename FROM pg_catalog.pg_tables
        WHERE schemaname = 'public'
    LOOP
        EXECUTE 'ANALYZE ' || v_table;
    END LOOP;
END;
$$;

-- UpdateStatisticsTargeted.pg.sql
-- ----------------------------------------------------------------------
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

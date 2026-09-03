-- =============================================================================
-- GetEmployeeCaseValuesByTenant
-- Direct JOIN query -- no pivot, no temp table needed.
-- Returns active, non-cancelled employee case values for a tenant filtered
-- by optional value date window, evaluation date, field names, and forecast.
-- =============================================================================

DROP PROCEDURE IF EXISTS GetEmployeeCaseValuesByTenant;

CREATE OR REPLACE FUNCTION "GetEmployeeCaseValuesByTenant"(
    IN "tenantId"       INTEGER,
    IN "valueDate"      TIMESTAMP(6),
    IN "evaluationDate" TIMESTAMP(6),
    IN "fieldNames"     TEXT,
    IN "forecast"       TEXT
)
RETURNS TABLE(
    "Id"                         INTEGER,
    "Status"                     INTEGER,
    "Created"                    TIMESTAMP(6),
    "Updated"                    TIMESTAMP(6),
    "EmployeeId"                 INTEGER,
    "DivisionId"                 INTEGER,
    "CaseName"                   VARCHAR(128),
    "CaseNameLocalizations"      TEXT,
    "CaseFieldName"              VARCHAR(128),
    "CaseFieldNameLocalizations" TEXT,
    "CaseSlot"                   VARCHAR(128),
    "CaseSlotLocalizations"      TEXT,
    "ValueType"                  INTEGER,
    "Value"                      TEXT,
    "NumericValue"               DECIMAL(28,6),
    "Culture"                    VARCHAR(128),
    "CaseRelation"               TEXT,
    "CancellationDate"           TIMESTAMP(6),
    "Start"                      TIMESTAMP(6),
    "End"                        TIMESTAMP(6),
    "Forecast"                   VARCHAR(128),
    "Tags"                       TEXT,
    "Attributes"                 TEXT
)
LANGUAGE plpgsql STABLE AS $$
BEGIN
    RETURN QUERY
    SELECT
        ecv."Id", ecv."Status", ecv."Created", ecv."Updated",
        ecv."EmployeeId", ecv."DivisionId",
        ecv."CaseName", ecv."CaseNameLocalizations",
        ecv."CaseFieldName", ecv."CaseFieldNameLocalizations",
        ecv."CaseSlot", ecv."CaseSlotLocalizations",
        ecv."ValueType", ecv."Value", ecv."NumericValue", ecv."Culture",
        ecv."CaseRelation", ecv."CancellationDate", ecv."Start", ecv."End",
        ecv."Forecast", ecv."Tags", ecv."Attributes"
    FROM "EmployeeCaseValue" ecv
    INNER JOIN "Employee" e ON e."Id" = ecv."EmployeeId"
    WHERE e."TenantId" = "tenantId"
      AND e."Status" = 0
      AND ecv."CancellationDate" IS NULL
      AND ("evaluationDate" IS NULL OR ecv."Created" <= "evaluationDate")
      AND ("valueDate" IS NULL OR ecv."Start" IS NULL OR ecv."Start" <= "valueDate")
      AND ("valueDate" IS NULL OR ecv."End"   IS NULL OR ecv."End"   >  "valueDate")
      AND (
          ("forecast" IS NULL     AND ecv."Forecast" IS NULL)
          OR ("forecast" IS NOT NULL AND (ecv."Forecast" IS NULL OR ecv."Forecast" = "forecast"))
      )
      AND (
          "fieldNames" IS NULL
          OR ecv."CaseFieldName" IN (
              SELECT jt.val
              FROM jsonb_array_elements_text("fieldNames"::jsonb) AS jt(val)
          )
      )
    ORDER BY ecv."EmployeeId" ASC, ecv."CaseFieldName" ASC, ecv."Created" DESC;
END;
$$;

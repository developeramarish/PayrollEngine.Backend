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
    DELETE FROM LookupValueAudit lva
    USING LookupValue lv, Lookup lk, Regulation r
    WHERE lva.LookupValueId = lv.Id
      AND lv.LookupId = lk.Id
      AND lk.RegulationId = r.Id
      AND r.TenantId = p_tenantId AND lk.Id = p_lookupId;

    DELETE FROM LookupValue lv
    USING Lookup lk, Regulation r
    WHERE lv.LookupId = lk.Id
      AND lk.RegulationId = r.Id
      AND r.TenantId = p_tenantId AND lk.Id = p_lookupId;

    DELETE FROM LookupAudit la
    USING Lookup lk, Regulation r
    WHERE la.LookupId = lk.Id
      AND lk.RegulationId = r.Id
      AND r.TenantId = p_tenantId AND lk.Id = p_lookupId;

    DELETE FROM Lookup lk
    USING Regulation r
    WHERE lk.RegulationId = r.Id
      AND r.TenantId = p_tenantId AND lk.Id = p_lookupId;
END;
$$;

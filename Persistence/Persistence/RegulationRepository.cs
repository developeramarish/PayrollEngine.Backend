using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using PayrollEngine.Domain.Model;
using PayrollEngine.Domain.Model.Repository;
using PayrollEngine.Persistence.DbSchema;
using PayrollEngine.Serialization;

namespace PayrollEngine.Persistence;

public class RegulationRepository() : ChildDomainRepository<Regulation>(Tables.Regulation,
    RegulationColumn.TenantId), IRegulationRepository
{
    /// <inheritdoc />
    /// Cross-tenant regulation access: also return regulations with SharedRegulation=true
    /// so tenants that consume regulations via RegulationShare can resolve them by name
    /// (e.g. pecmd Report command, regulation-by-name lookup in ReportCommand).
    ///
    /// Correct parenthesization: WHERE [OData filters] AND (TenantId=@parentId OR SharedRegulation=1)
    /// Mirrors the fix applied to CaseRepository and CaseFieldRepository.
    public override async Task<IEnumerable<Regulation>> QueryAsync(IDbContext context, int parentId, Query query = null)
    {
        // Build base query with OData filters but WITHOUT the parent TenantId filter
        var dbQuery = DbQueryFactory.NewQuery<Regulation>(context, TableName, query);

        // Add parenthesized OR so the name filter (when present) applies to both sides:
        // WHERE Name='US.Payroll' AND (TenantId=@parentId OR SharedRegulation=1)
        dbQuery.Where(q => q
            .Where(ParentFieldName, parentId)
            .OrWhere(RegulationColumn.SharedRegulation, true));

        var compileQuery = CompileQuery(dbQuery, context);
        var items = (await QueryAsync<Regulation>(context, compileQuery)).ToList();
        await OnRetrieved(context, parentId, items);
        return items;
    }

    protected override void GetObjectCreateData(Regulation regulation, DbParameterCollection parameters)
    {
        parameters.Add(nameof(regulation.SharedRegulation), regulation.SharedRegulation);
        base.GetObjectCreateData(regulation, parameters);
    }

    protected override void GetObjectData(Regulation regulation, DbParameterCollection parameters)
    {
        parameters.Add(nameof(regulation.Name), regulation.Name);
        parameters.Add(nameof(regulation.NameLocalizations), JsonSerializer.SerializeNamedDictionary(regulation.NameLocalizations));
        parameters.Add(nameof(regulation.Namespace), regulation.Namespace);
        parameters.Add(nameof(regulation.Version), regulation.Version, DbType.Int32);
        parameters.Add(nameof(regulation.ValidFrom), regulation.ValidFrom, DbType.DateTime2);
        parameters.Add(nameof(regulation.Owner), regulation.Owner);
        parameters.Add(nameof(regulation.Description), regulation.Description);
        parameters.Add(nameof(regulation.DescriptionLocalizations), JsonSerializer.SerializeNamedDictionary(regulation.DescriptionLocalizations));
        parameters.Add(nameof(regulation.BaseRegulations), JsonSerializer.SerializeList(regulation.BaseRegulations));
        parameters.Add(nameof(regulation.Attributes), JsonSerializer.SerializeNamedDictionary(regulation.Attributes));
        base.GetObjectData(regulation, parameters);
    }
}
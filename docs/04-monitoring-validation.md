# Monitoring and validation

## Diagnostic path

Key Vault audit events and Blob read/write/delete logs are sent to a dedicated Log Analytics workspace in resource-specific tables:

- `AZKVAuditLogs`
- `StorageBlobLogs`

The repository includes small KQL queries under `queries/`. Entra queries are included but are used only if the tenant can export Entra sign-in and audit logs to the same workspace.

## Validation sequence

1. Build the template with `az bicep build`.
2. preview changes with `az deployment sub what-if`;
3. deploy the resource group and lab resources;
4. allow time for Azure RBAC propagation;
5. run `scripts/validate.sh`;
6. confirm the private-path and OAuth checks pass;
7. wait for diagnostic ingestion;
8. run the Key Vault and Storage KQL queries;
9. inspect relevant Azure Policy or Defender for Cloud findings;
10. export only sanitized evidence; and
11. remove the temporary validation workload.

## What a result proves

| Result | Supports | Does not prove |
|---|---|---|
| Bicep build | Template syntax and type checks | Successful deployment |
| What-if output | Expected management-plane change set | Effective data-plane access |
| VM private DNS check | Service names resolve into the private-endpoint subnet | Every possible network path is private |
| Managed-identity REST test | The assigned identity can perform the tested read | Broader application correctness |
| Log Analytics row | The tested operation was ingested | Complete security monitoring coverage |
| Defender/Policy finding | Azure evaluated a specific configuration | Production risk acceptance or compliance |

## Expected ingestion delay

Azure role assignments and diagnostic logs are not always immediate. A first failed validation is not automatically a configuration defect. The journal records whether a retry was waiting for propagation or followed a real change.

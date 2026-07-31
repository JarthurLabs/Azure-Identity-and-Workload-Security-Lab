# Monitoring validation

## Evidence summary

- **Source:** Azure Log Analytics resource-specific tables.
- **Captured (UTC):** 2026-07-31 08:04.
- **Evidence type:** diagnostic ingestion and authentication result.

The repository queries were run after the managed-identity validation:

```text
Key Vault audit summary
HTTP 200 rows: 14
HTTP 403 rows: 0
Total rows: 14

Storage Blob OAuth summary
OAuth / HTTP 200 rows: 1
OAuth / HTTP 403 rows: 1

monitoring_validation=PASS
```

The Key Vault table contained the successful data-plane activity. The Storage Blob table recorded both the allowed OAuth container listing and the intentional denied OAuth write.

## What this supports

- Key Vault and Storage diagnostic settings delivered records to the dedicated workspace.
- The observed Blob operations used OAuth rather than Shared Key.
- Monitoring recorded both the successful read path and the least-privilege denial.

## Limits and redaction

A row in Log Analytics proves ingestion for the tested operation, not complete security-monitoring coverage. The exported summary omits caller identifiers, resource IDs, IP addresses, globally unique resource suffixes, and unrelated records.

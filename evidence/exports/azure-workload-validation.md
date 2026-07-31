# Azure workload validation

## Evidence summary

- **Source:** Azure CLI, Azure VM Run Command, and the deployed Bicep template.
- **Captured (UTC):** 2026-07-31 07:55.
- **Source commit:** `29279490cc4b`.
- **Environment:** isolated East US training resource group.
- **Evidence type:** deployment, configuration, allowed access, and denied access.

Azure repeated the subscription-scope what-if immediately before deployment. It reported **26 creates**, with no modifications or deletions. The deployment then completed successfully.

![Sanitized live resource metadata and type inventory](../screenshots/E-04-resource-inventory.jpg)

## Sanitized validation output

```text
validation_started_utc=2026-07-31T07:55:54Z
key_vault_private_dns=true
storage_private_dns=true
managed_identity_key_vault_token=true
key_vault_secret_read_status=200
key_vault_expected_secret=true
managed_identity_storage_token=true
storage_private_container_list_status=200
storage_expected_container=true
storage_blob_write_denied_status=403
least_privilege_denied_write=true
validation_result=PASS
```

The test ran from the temporary Azure VM through Azure VM Run Command. Key Vault and Blob service names resolved to the private-endpoint subnet. The VM's user-assigned managed identity obtained service-specific OAuth tokens, read the expected Key Vault secret, and listed the private Blob container. A deliberate Blob write returned HTTP 403 because the identity had a reader role rather than a contributor role.

![Sanitized live validation output](../screenshots/E-07-managed-identity-validation.jpg)

## What this supports

- The tested Key Vault and Blob paths resolved through private DNS.
- The workload used a managed identity instead of a stored application credential.
- The assigned data-plane roles allowed the two intended reads.
- The Storage Blob Data Reader role did not allow the tested write.

## Limits and redaction

This result tests one workload identity and specific operations; it does not prove that every network path or privilege-escalation path is blocked. Tenant, subscription, principal, object, and resource IDs; account names; IP addresses; tokens; secret values; and globally unique resource suffixes were omitted.

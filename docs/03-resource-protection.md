# Resource protection

## Baseline

The Bicep template deploys a deliberately small workload:

- one resource group;
- one virtual network with validation and private-endpoint subnets;
- one network security group;
- one user-assigned managed identity;
- one Key Vault with the Azure RBAC permission model;
- one general-purpose v2 Storage account and a private blob container;
- private endpoints and private DNS for Key Vault and Blob Storage;
- one temporary Ubuntu `Standard_B1s` VM with no public IP;
- one Log Analytics workspace and resource diagnostic settings.

## Security choices

### Identity instead of stored credentials

The VM uses a managed identity. The validation code obtains short-lived tokens through the Azure Instance Metadata Service. No client secret, storage key, connection string, or Key Vault value is committed or printed.

### Separate management and data access

Azure management-plane permissions do not automatically grant Key Vault secret or Blob data access. The template therefore assigns narrow data-plane roles directly on the affected resources.

### Private data path

Key Vault and Storage have public network access disabled. Their public service names resolve to addresses in `10.20.2.0/24` from the validation VM through Azure Private DNS.

### Storage authorization

- Shared Key authorization is disabled.
- The portal defaults to Microsoft Entra authorization.
- Anonymous blob access and cross-tenant object replication are disabled.
- HTTPS and TLS 1.2 or later are required.

### Key Vault recovery

Soft delete and purge protection are enabled with a seven-day retention period. Deleting the resource group removes billable dependent resources, but the vault name remains reserved during the retention window.

### Temporary compute

The validation VM:

- has no public IP;
- allows no password authentication;
- uses a temporary SSH public key;
- uses Trusted Launch with Secure Boot and virtual TPM; and
- deletes its OS disk and network interface when the VM is deleted.

The validation subnet allows outbound TCP 443 to the `AzureCloud` service tag for Azure VM Run Command and denies general Internet egress. That Azure platform dependency is a stated lab limitation rather than hidden as a production-ready network design.

## Validation boundary

The deployment is not considered successful merely because Azure Resource Manager reports success. `validation/validate-from-vm.sh` must confirm:

1. both service names resolve through the private endpoint range;
2. the managed identity obtains separate Key Vault and Storage tokens;
3. the identity can read the marker secret without printing its value; and
4. the identity can list the expected blob container through OAuth; and
5. a blob write fails with HTTP 403 because the identity has only `Storage Blob Data Reader`.

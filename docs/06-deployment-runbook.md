# Deployment runbook

This runbook is intentionally gated. The live environment must have an enabled Azure subscription in an owned training tenant before any deployment command runs.

## Required access

- Azure Cloud Shell Bash, or a local Bash environment with Azure CLI, Bicep, ShellCheck, OpenSSH, and OpenSSL.
- An enabled subscription.
- Permission to create the listed resources and Azure role assignments. `Owner` is the simplest training-lab role; a narrower combination is `Contributor` plus `Role Based Access Control Administrator` or `User Access Administrator`.
- Directory permission to create security groups for the optional Entra portion.
- Microsoft Entra ID P1 only if Conditional Access will be tested.

## Pin the environment

Do not paste real identifiers into repository files or screenshots. Set them only in the current shell:

```bash
export EXPECTED_SUBSCRIPTION_ID='<subscription-guid>'
export EXPECTED_TENANT_ID='<tenant-guid>'
export NAME_PREFIX='carebridge'
export LOCATION='eastus'
export DEPLOYMENT_NAME="${NAME_PREFIX}-security-lab"
```

Every live script verifies the expected subscription, tenant, and enabled state before continuing.

## Preflight

```bash
bash scripts/verify-azure-context.sh
az bicep build --file infra/main.bicep
shellcheck scripts/*.sh validation/*.sh
az group exists --name "rg-${NAME_PREFIX}-security-lab"
```

The final command must return `false`. A pre-existing resource group is treated as a collision, even if its name looks familiar.

Confirm these resource providers are registered before deployment:

- `Microsoft.Authorization`
- `Microsoft.Compute`
- `Microsoft.Insights`
- `Microsoft.KeyVault`
- `Microsoft.ManagedIdentity`
- `Microsoft.Network`
- `Microsoft.OperationalInsights`
- `Microsoft.Storage`

## Preview, then deploy

```bash
bash scripts/deploy.sh
```

Review the complete what-if result. It should create one new resource group and only the documented lab resources. Stop if it changes anything pre-existing.

```bash
APPLY=true bash scripts/deploy.sh
```

A failed deployment can still leave billable resources. Inspect the resource group immediately before troubleshooting or cleanup.

## Validate

Allow time for role assignments, private Domain Name System records, the virtual-machine agent, and diagnostic logs to propagate.

```bash
bash scripts/validate.sh
```

The validation is successful only when it records:

- private address resolution for Key Vault and Storage;
- separate managed-identity tokens;
- an allowed Key Vault secret read;
- an allowed private-container list; and
- a denied blob write with HTTP 403.

Do not treat an initial HTTP 403 on an intended read as proof of a bad design until role-assignment propagation has been considered.

## Cost cleanup

Remove the temporary virtual machine as soon as its evidence is captured:

```bash
CONFIRM_VM_NAME="vm-${NAME_PREFIX}-validation" \
  bash scripts/remove-validation-workload.sh
```

The script verifies deletion of the virtual machine, operating-system disk, and network interface.

Run resource-group cleanup once without confirmation to inspect its inventory:

```bash
bash scripts/cleanup.sh
```

Then supply the exact resource-group name:

```bash
CONFIRM_RESOURCE_GROUP_NAME="rg-${NAME_PREFIX}-security-lab" \
  bash scripts/cleanup.sh
```

Cleanup refuses a resource group whose lab ownership tags do not match. It also verifies that the resource group no longer exists. Entra groups and Conditional Access policies are directory objects and require a separate, deliberate review.

Finally, review Azure Cost Management and record the observed cleanup state. The purge-protected Key Vault name remains reserved for seven days.

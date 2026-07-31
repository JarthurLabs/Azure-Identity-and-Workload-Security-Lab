# Cost controls

This lab is designed to run briefly, not continuously.

## Potential charges

- `Standard_D2ls_v7` virtual machine runtime and its managed OS disk.
- Two private endpoints.
- Two Azure Private DNS zones.
- Log Analytics ingestion and retention.
- Standard Key Vault operations.
- Standard locally redundant Blob Storage.

Prices vary by region and subscription. This repository does not claim that the lab is free.

On 2026-07-31, the Azure Retail Prices API listed the East US Linux
`Standard_D2ls_v7` consumption rate as **$0.117 USD per hour**. The SKU was
selected only after the subscription reported the smaller B-series and
DLSv5 options as capacity-restricted.

Use these conservative planning limits rather than treating them as a bill:

- under **$1** when the complete lab is deleted within four hours;
- about **$4** if it is left for 24 hours; and
- roughly **$110 per month** if every resource is forgotten.

Credits can reduce the amount charged, but the cleanup plan never assumes
that credits are available.

## Guardrails

- Run `az deployment sub what-if` before deployment.
- Use the temporary VM only for private-path validation.
- Target VM deletion within two hours and complete lab deletion the same day.
- Delete the VM immediately after evidence collection with:

  ```bash
  CONFIRM_VM_NAME=vm-carebridge-validation bash scripts/remove-validation-workload.sh
  ```

- Delete the complete lab after the final screenshots and exports with:

  ```bash
  CONFIRM_RESOURCE_GROUP_NAME=rg-carebridge-security-lab bash scripts/cleanup.sh
  ```

- Review Cost Management before and after the lab. A budget sends notifications; it does not automatically stop resources.

## Cleanup evidence

The project is not complete until the evidence register contains:

- a pre-delete resource inventory;
- the resource-group deletion request;
- a post-delete check; and
- a note that the purge-protected Key Vault name remains reserved for seven days.

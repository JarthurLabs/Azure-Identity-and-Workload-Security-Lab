# Cost controls

This lab is designed to run briefly, not continuously.

## Potential charges

- `Standard_B1s` virtual machine runtime and its managed OS disk.
- Two private endpoints.
- Two Azure Private DNS zones.
- Log Analytics ingestion and retention.
- Standard Key Vault operations.
- Standard locally redundant Blob Storage.

Prices vary by region and subscription. This repository does not claim that the lab is free.

## Guardrails

- Run `az deployment sub what-if` before deployment.
- Use the temporary VM only for private-path validation.
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

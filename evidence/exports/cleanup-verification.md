# Cleanup verification

## Evidence summary

- **Source:** guarded Azure CLI cleanup scripts.
- **Date:** 2026-07-31.
- **Evidence type:** cost control, failed safety check, fix, and deletion retest.

The temporary validation VM was removed first. The script verified that the VM, its operating-system disk, and its validation network interface were absent.

The first full-cleanup attempt at 08:07 UTC made no deletion. Its ownership guard stopped because the script read a multiline Azure CLI TSV array as one line:

```text
Resource-group ownership tags do not match this lab. Refusing cleanup.
CLEANUP_EXIT=1
```

The resource-group tags were present and correct. The parser was changed to `mapfile`, required exactly three returned values, and assigned them by index. The fix was published in commit `09b398867793`.

The guarded retest began at 08:09 UTC, accepted the exact resource-group name, listed the remaining lab resources, and completed deletion. A separate verification at 08:14 UTC returned:

```text
RESOURCE_GROUP_EXISTS=false
ACTIVE_RESOURCES_IN_LAB_GROUP=0
cleanup_result=PASS
```

The Key Vault used purge protection, so its name remains reserved during Azure's seven-day soft-delete period. The vault is not an active resource in the deleted group.

## Redaction

Tenant and subscription IDs, account details, globally unique resource suffixes, automatically generated network-interface identifiers, and soft-deleted Key Vault names are omitted.

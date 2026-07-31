# Skills and evidence map

This table is a portfolio index, not a claim of production experience. Status changes to `Implemented` only when the linked evidence exists.

| Skill area | Lab implementation | Status | Evidence |
|---|---|---|---|
| SC-300: identities and groups | Lab security groups and membership review | Blocked | Current directory returned HTTP 401 on group creation; see F-02 |
| SC-300: authentication and access | Conditional Access report-only evaluation with an emergency-access exclusion | License-dependent | Pending tenant capability check |
| SC-300: workload identities | User-assigned managed identity and enterprise application review | Blocked | No Azure subscription; see F-01 |
| SC-300: identity governance | Review of privileged and standing access; PIM or access review only if licensed | License-dependent | Pending tenant capability check |
| SC-500: identity and access governance | Resource-scoped Azure RBAC for administrators and the managed identity | Blocked | No Azure subscription; see F-01 |
| SC-500: storage and networking | Secure Storage baseline, virtual network, private endpoint, and private DNS | Blocked | No Azure subscription; see F-01 |
| SC-500: secrets protection | RBAC-enabled Key Vault reached through a private endpoint | Blocked | No Azure subscription; see F-01 |
| SC-500: compute | Temporary identity-enabled validation workload | Blocked | No Azure subscription; see F-01 |
| SC-500: posture and monitoring | Defender/Policy review, diagnostics, Log Analytics, and KQL validation | Blocked | No Azure subscription; see F-01 |

## Interpretation

- `Implemented` means a real configuration and validation artifact are committed.
- `Partially implemented` means a bounded portion is live and the limitation is stated.
- `License-dependent` means the feature is not claimed unless the tenant exposes it.
- `Blocked` means a real environment prerequisite failed and the linked finding identifies the retest condition.
- `Planned` is not evidence and should not be read as completed work.

# Skills and evidence map

This table is a portfolio index, not a claim of production experience. Status changes to `Implemented` only when the linked evidence exists.

| Skill area | Lab implementation | Status | Evidence |
|---|---|---|---|
| SC-300: identities and groups | Lab security groups and membership review | Blocked | Current directory returned HTTP 401 and the alternate account was not a tenant member; see F-02 and F-03 |
| SC-300: authentication and access | Conditional Access report-only evaluation with an emergency-access exclusion | License-dependent | Pending tenant capability check |
| SC-300: workload identities | User-assigned managed identity and enterprise application review | Previewed | East US what-if includes the identity and resource-scoped role assignments; see F-06 |
| SC-300: identity governance | Review of privileged and standing access; PIM or access review only if licensed | License-dependent | Pending tenant capability check |
| SC-500: identity and access governance | Resource-scoped Azure RBAC for the managed identity | Previewed | What-if includes scoped Key Vault and Blob role assignments; see F-06 |
| SC-500: storage and networking | Secure Storage baseline, virtual network, private endpoint, and private DNS | Previewed | East US what-if passed; live access tests remain pending |
| SC-500: secrets protection | RBAC-enabled Key Vault reached through a private endpoint | Previewed | East US what-if passed; secret-read validation remains pending |
| SC-500: compute | Temporary identity-enabled validation workload | Previewed | `Standard_D2ls_v7` passed subscription capacity validation; see F-06 |
| SC-500: posture and monitoring | Defender/Policy review, diagnostics, Log Analytics, and KQL validation | Previewed | Diagnostic settings passed what-if; live log ingestion remains pending |

## Interpretation

- `Implemented` means a real configuration and validation artifact are committed.
- `Partially implemented` means a bounded portion is live and the limitation is stated.
- `Previewed` means Azure what-if accepted the proposed resources, but nothing is labeled implemented until deployment and validation evidence exist.
- `License-dependent` means the feature is not claimed unless the tenant exposes it.
- `Blocked` means a real environment prerequisite failed and the linked finding identifies the retest condition.
- `Planned` is not evidence and should not be read as completed work.

# Skills and evidence map

This table is a portfolio index, not a claim of production experience. Status changes to `Implemented` only when the linked evidence exists.

| Skill area | Lab implementation | Status | Evidence |
|---|---|---|---|
| SC-300: identities and groups | Lab security groups and membership review | Blocked | Current directory returned HTTP 401 and the alternate account was not a tenant member; see F-02 and F-03 |
| SC-300: authentication and access | Conditional Access report-only evaluation with an emergency-access exclusion | License-dependent | Pending tenant capability check |
| SC-300: workload identities | User-assigned managed identity used by a temporary workload | Implemented | OAuth tokens and intended Key Vault and Blob reads passed; see E-07 |
| SC-300: identity governance | Review of privileged and standing access; PIM or access review only if licensed | License-dependent | Pending tenant capability check |
| SC-500: identity and access governance | Resource-scoped Azure RBAC for the managed identity | Implemented | Intended reads returned HTTP 200 and the out-of-scope write returned HTTP 403; see E-07 |
| SC-500: storage and networking | Secure Storage baseline, virtual network, private endpoint, and private DNS | Implemented | Both service names resolved privately and the Blob data-plane test passed; see E-06 and E-07 |
| SC-500: secrets protection | RBAC-enabled Key Vault reached through a private endpoint | Implemented | Private DNS and the managed-identity secret read passed; see E-06 and E-07 |
| SC-500: compute | Temporary identity-enabled validation workload | Implemented and removed | VM Run Command produced the validation evidence; VM, disk, and interface deletion were verified; see E-07 and E-10 |
| SC-500: posture and monitoring | Diagnostics, Log Analytics, and KQL validation; Defender/Policy review not collected | Partially implemented | Key Vault and Storage OAuth records were ingested; Defender/Policy remains unclaimed; see E-08 and E-09 |

## Interpretation

- `Implemented` means a real configuration and validation artifact are committed.
- `Partially implemented` means a bounded portion is live and the limitation is stated.
- `Previewed` means Azure what-if accepted the proposed resources, but nothing is labeled implemented until deployment and validation evidence exist.
- `License-dependent` means the feature is not claimed unless the tenant exposes it.
- `Blocked` means a real environment prerequisite failed and the linked finding identifies the retest condition.
- `Planned` is not evidence and should not be read as completed work.

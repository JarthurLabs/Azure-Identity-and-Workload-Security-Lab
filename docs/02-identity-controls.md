# Identity controls

## Design

The identity portion stays small and uses group-based assignment:

- `SG-LAB-CA-Pilot` — a limited pilot scope for Conditional Access testing.
- `SG-LAB-Resource-Readers` — the group intended for read-only Azure resource access.
- `SG-LAB-Security-Reviewers` — the group intended for security posture review.
- `id-carebridge-workload` — the managed identity used by the temporary validation VM.

The repository does not create member users or emergency-access accounts automatically. User creation involves temporary credentials and tenant-specific domains, so it is performed manually in the isolated training tenant and documented only after redaction.

## Conditional Access safety sequence

Conditional Access is implemented only if the tenant has Microsoft Entra ID P1 or a suitable trial.

1. Confirm that at least two cloud-only emergency-access accounts exist and are protected according to Microsoft guidance.
2. Add one non-administrator synthetic user to `SG-LAB-CA-Pilot`.
3. Create `CA-001-Require-MFA-Pilot`.
4. Include only `SG-LAB-CA-Pilot`.
5. Exclude the emergency-access accounts.
6. Target the intended cloud apps.
7. Require multifactor authentication.
8. Set the policy to **Report-only**.
9. Run the Conditional Access What If tool for the pilot user and each emergency account.
10. Generate a real pilot sign-in and inspect the report-only result.
11. Record the result without exposing user principal names, tenant IDs, or device/IP details.

The lab does not switch a policy to `On` merely to produce a screenshot. Enforcement occurs only if the safety checks pass and the tenant has a recoverable administrator path.

## Workload identity

The Bicep deployment creates one user-assigned managed identity and attaches it to the validation VM. The identity receives:

- `Key Vault Secrets User` at the Key Vault scope; and
- `Storage Blob Data Reader` at the single `private-data` container scope.

It receives no subscription-wide or resource-group-wide Contributor role. The validation script requests tokens from the Azure Instance Metadata Service and prints only pass/fail state—not tokens, resource IDs, or the secret value.

## Licensing boundaries

| Feature | Minimum practical requirement | Lab rule |
|---|---|---|
| Conditional Access | Entra ID P1 | Implement only after license check |
| Risk-based Conditional Access | Entra ID P2 | Out of scope unless already licensed |
| PIM for Entra roles | Entra ID P2 or ID Governance | Optional, never claimed without evidence |
| Access reviews | Entra ID P2 or ID Governance, depending on scenario | Optional, never claimed without evidence |

If a feature is unavailable, the evidence register records the limitation. A written plan is not labeled as an implemented control.

# Scope and threat model

## Scenario

CareBridge Analytics is a fictional small healthcare SaaS team. It needs a safe place for a limited set of administrators to manage one Azure workload that reads a synthetic secret and inspects a private blob container. The lab focuses on the handoff between identity administration and resource protection:

1. An administrator receives access through an Entra group.
2. An Azure workload authenticates with a managed identity instead of a stored secret.
3. Azure RBAC grants only the data access needed by that identity.
4. Key Vault and Storage reject unintended public data-plane access.
5. Diagnostic records are sent to Log Analytics and queried during validation.

This is not a clinical system and contains no patient, customer, or production data.

## In scope

- A dedicated Azure resource group.
- Three lab-only Entra security groups.
- A user-assigned managed identity and its Entra enterprise application object.
- Resource-scoped Azure RBAC assignments.
- Key Vault and Blob Storage security settings.
- A virtual network, private endpoints, and private DNS.
- A temporary validation workload.
- Diagnostic settings, a Log Analytics workspace, and small KQL checks.
- Conditional Access in report-only mode if the tenant is licensed for it.
- A review of Defender for Cloud or Azure Policy findings that apply to the deployed resources.

## Out of scope

- Production availability, backup, disaster recovery, and formal change management.
- Hybrid identity, Active Directory Domain Services, federation, or identity synchronization.
- Patient data, regulated workloads, or a claim of HIPAA compliance.
- A full SIEM detection engineering program.
- Paid Defender plans enabled only for portfolio appearance.
- PIM, access reviews, or entitlement management if the tenant lacks the required license.

## Assets and trust boundaries

| Asset | Why it matters | Trust boundary |
|---|---|---|
| Administrator role assignment | Can change the lab environment | Entra identity to Azure management plane |
| Managed identity | Authenticates the workload without a stored credential | Azure compute to Entra token service |
| Key Vault secret | Represents a sensitive application value | Workload to Key Vault data plane |
| Storage blob | Represents private application data | Workload to Storage data plane |
| Diagnostic records | Provide evidence for access and configuration review | Azure resources to Log Analytics |

## Main risks and planned controls

| Risk | Planned control | Validation approach |
|---|---|---|
| A broad administrator role grants more access than intended | Group-based, resource-scoped RBAC | Export effective role assignments and inspect scope |
| A sign-in policy locks out all administrators | Report-only deployment and emergency-account exclusion | Inspect policy state and sign-in evaluation before enforcement |
| A workload secret is copied into code or configuration | User-assigned managed identity | Scan repository and test identity-based authentication |
| Secrets or blobs remain reachable over an unintended public path | Public-network restrictions and private endpoints | Inspect resource properties and test name resolution/access from the validation workload |
| A control is configured but never observed | Diagnostic settings and targeted KQL | Query a known validation event |
| A learning-lab feature is mistaken for production experience | Evidence labels and explicit limitations | Review README and skills map before release |

## Success criteria

The lab is complete only when:

- every `Implemented` row in the skills map points to a real artifact;
- the deployment passes a template build and a live Azure validation;
- at least one allowed access test and one denied or constrained path are recorded;
- any real failure is documented with symptom, cause, change, and retest;
- sensitive identifiers are redacted from committed evidence; and
- the temporary validation workload and chargeable resources are cleaned up or their retained cost is stated.

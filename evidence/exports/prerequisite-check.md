# Environment prerequisite check

Captured on 2026-07-31 in the live Microsoft portals.

## P-01 — Azure subscription

- **Source:** Azure portal, Subscriptions.
- **Result:** zero subscriptions were available in the signed-in directory.
- **Security meaning:** no resource group, managed identity, Key Vault, Storage account, virtual network, private endpoint, Log Analytics workspace, or validation VM can be created.
- **Redacted:** account email and directory identifier are outside the cropped screenshot.
- **Next test:** confirm an enabled subscription, then run the Bicep build and subscription-scope what-if.

## P-02 — Entra group administration

- **Source:** Microsoft Entra admin center, Groups, New group.
- **Result:** the current principal received **You don't have access** with HTTP status 401.
- **Security meaning:** the current directory is not a valid administration lab for this account.
- **Redacted:** account email, directory identifier, and session identifier are outside the cropped screenshot.
- **Next test:** switch to an owned training directory with an appropriate administrator role, then create the lab groups.

## Evidence boundary

These are failed prerequisite checks, not implemented security controls. They remain visible because they explain why the project did not claim deployment success.

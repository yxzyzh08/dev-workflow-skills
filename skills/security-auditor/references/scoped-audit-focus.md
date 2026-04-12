# Security Auditor Scoped Audit Focus

Use this file to keep the audit tied to the current change instead of drifting into a full-repo scan.

## Code review focus

Check only the changed or explicitly requested areas for:

- injection or XSS style risks
- authn / authz gaps
- unsafe defaults or debug exposure
- secret leakage in code, config, or logs
- weak transport or storage handling for sensitive data

## Architecture review focus

Check only the affected architecture scope for:

- permission model gaps
- tenant or data-isolation weaknesses
- missing encryption boundaries
- trust-boundary crossings without clear controls

## Dependency review focus

Check only the introduced or changed dependencies for:

- known vulnerability advisories
- incompatible or risky licenses
- temporary acceptance of a risky dependency without a mitigation plan

## Scope discipline

- tie every finding to the reviewed change
- do not block the stage on unrelated historical issues
- expand to a broader scan only when the human explicitly asks

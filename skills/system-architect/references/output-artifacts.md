# System Architect Output Artifacts

Use this file when drafting or reviewing architecture outputs.

## Architecture baseline at `paths.architecture`

Expected coverage:

- purpose / scope and upstream baselines
- a compact navigation layer for downstream stages (for example, a capability registry, exposed-capability section, or equivalent index)
- deferred scope / extension points
- authority model when documents, runtime files, APIs, or storage records are architectural commitments
- business architecture
- product surface or exposed system surfaces
- core object model and key invariants when they are part of the stable baseline
- technical architecture
- explicit tech choices
- component topology, integration / interface contracts, and storage authority when relevant
- horizontal capabilities
- platform foundations
- code organization or build / distribution guidance when they are stable architecture commitments
- evolution space for `later` / `deferred` work and possible third-level expansions
- traceability notes back to requirement / acceptance IDs
- current `change_history`

Equivalent section names are acceptable, but downstream design / development must be able to navigate the baseline without reading it end to end for every capability.

## Architecture review reports under `<from paths.architecture parent>/reviews/arch-review-{nn}.md`

Expected review coverage:

- review scope and referenced baselines
- fit to frozen requirements / acceptance
- capability registry / exposed-capability quality and downstream navigability
- clarity of exposed surfaces and authority boundaries
- future evolution readiness
- findings with severity
- pass / not pass judgment

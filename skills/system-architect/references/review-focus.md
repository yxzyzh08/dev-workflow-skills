# System Architect Review Focus

Use this file before writing `arch-review-{nn}.md`.

## Fit checks

- no frozen second-level boundary is silently expanded
- a capability registry or equivalent exposed-capability section exists near the front and works as a navigation index for downstream stages
- the document gives downstream design / development a primary decomposition or navigation rule, so readers do not need to reread the full baseline for every capability slice
- business and technical architecture both exist
- exposed product or system surfaces are explicit instead of being buried inside lower-level prose
- authority boundaries for documents, files, APIs, records, or projections are explicit when downstream work depends on them
- tech choices are explicit enough for downstream design work
- core object model, key invariants, and integration contracts are explicit enough for downstream implementation planning
- horizontal capabilities are not treated as afterthoughts
- platform foundations cover deployment, scaling, resilience, or equivalent runtime concerns

## Downstream usability checks

- a designer can map one capability area to the right architecture section quickly
- a developer can identify the owning component / layer and the touched interfaces or authority artifacts
- capability index sections stay consistent with the deeper architecture sections they point to

## Evolution checks

- `later` / `deferred` items have a clear landing space
- likely third-level expansions under frozen second-level items can be absorbed without reshaping the baseline
- extension points do not widen the current agreed scope by stealth

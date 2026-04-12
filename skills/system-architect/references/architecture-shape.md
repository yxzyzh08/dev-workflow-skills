# System Architect Architecture Shape

Use this file when drafting or reviewing an architecture baseline and the existing repository does not already impose a stronger architecture template.

Section titles do not need to match this file verbatim, but equivalent coverage should exist in a form that downstream stages can navigate quickly.

## Recommended baseline shape

1. Purpose and scope
   - what the baseline is for
   - what release or capability boundary it serves
   - how downstream design / development should use it
   - primary decomposition or navigation rule when the document is large
2. Capability registry or exposed-capability section
   - list the major capability domains near the front of the document
   - for each capability, capture at least purpose, owning layer / component, and downstream touchpoints or planned owner
   - make it possible for a reader to jump from a requirement slice to the relevant architecture slice without rereading the whole document
3. Deferred scope and extension points
   - record `later` / `deferred` scope explicitly
   - reserve landing space without silently widening current scope
4. Authority model
   - document model and authority rules when architecture is the stable source of truth
   - runtime authority, file authority, API authority, or storage authority when they matter to downstream design
5. Domain / business architecture
   - system overview
   - product surface or exposed system surfaces
   - core object model
   - workflow / governance invariants
   - isolation, observability, or other domain-level invariants when they are architectural commitments
6. Technical architecture
   - technology stack decisions
   - system component topology
   - data or storage architecture
   - integration interface contracts
   - cross-cutting concerns
   - code organization and build / distribution guidance when those are stable architecture commitments
7. Traceability and change log
   - stable links back to requirement / acceptance IDs
   - current `change_history`

## Downstream usability rule

The architecture baseline is not only a correctness artifact. It is also a navigation artifact for later stages.

At minimum, a designer or developer working on one capability should be able to identify:

- which capability bucket they are in
- which section explains the stable architecture for that bucket
- which component, layer, or authority path owns the behavior
- which interfaces, files, or contracts are expected to change

If a reader must scan the full document to answer those questions for one capability, the baseline is missing a usable navigation layer.

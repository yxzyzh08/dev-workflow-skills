# Workflow Router Stage Recommendation Table

Use this file when mapping the current workflow position to the next owning skill.

| Condition | Recommend |
| --- | --- |
| no progress baseline or initialization state | `requirements-analyst` |
| steps 1-3 | `requirements-analyst` |
| steps 4-6 | `acceptance-designer` |
| steps 7-9 | `system-architect` |
| steps 10-12 | `tech-lead` |
| steps 13-15 | `developer` and possibly `parallel-dispatcher` |
| steps 16-18 | `test-engineer` |
| steps 19-26 | `delivery-qa` |
| document-state or freeze hygiene concern | layer in `doc-guardian` |
| skill creation or revision request | layer in `skill-writer` |

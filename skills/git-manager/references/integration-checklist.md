# Git Manager Integration Checklist

Use this file when landing branches back to the protected line.

## Before merge

- merge order is documented
- required verification gate passed for the current branch
- conflict risks are known

## During merge

- resolve conflicts inside the branch worktree
- log the files and decisions involved
- rerun verification if conflict resolution changes files

## After merge

- record why this branch landed in this order
- remove the merged worktree
- clean up or archive the branch reference without rewriting protected history

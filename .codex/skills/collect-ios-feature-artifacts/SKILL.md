---
name: collect-ios-feature-artifacts
description: Use for non-trivial DEVX feature work to create and maintain required AI workflow artifacts under .specs/features/<ticket> before implementation and through delivery.
---

# collect-ios-feature-artifacts

## When to use

- Branch matches `feature/DEVX-<ticket-number>/<short-description>`.
- Any non-trivial feature behavior change, API change, integration-flow change, or release-impacting change.

## Required artifact set

For ticket `DEVX-1234`, maintain:

- `.specs/features/DEVX-1234/intake.md`
- `.specs/features/DEVX-1234/execution.md`

## Artifact intent

- `intake.md`: problem statement, scope, constraints, acceptance criteria, risks.
- `execution.md`: implementation plan, decisions made, tests run, rollout notes, follow-ups.

## Required invariants

- Artifacts are created before significant code edits start.
- Artifacts are updated whenever scope, decisions, tests, or rollout details change.
- Artifact ticket id matches branch ticket id.
- Artifacts contain only non-sensitive content.

## Verification commands

```bash
branch="$(git branch --show-current)"
echo "$branch"
bash scripts/check_feature_artifacts.sh
```

## Done criteria

- Required artifact files exist and are non-empty.
- Artifact content is aligned with the implemented behavior and tests.
- CI artifact check passes for the branch.

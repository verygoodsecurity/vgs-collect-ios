---
description: Create or update required feature artifacts (.specs/features/<ticket>/intake.md and execution.md)
---

You are managing feature artifacts for a DEVX ticket branch.

## When to use

Branch matches `feature/DEVX-<ticket-number>/<short-description>` and involves non-trivial behavior, API, or integration-flow changes.

## Required artifacts

For ticket `DEVX-XXXX` (derive from current branch name):
- `.specs/features/DEVX-XXXX/intake.md` — problem statement, scope, constraints, acceptance criteria, risks
- `.specs/features/DEVX-XXXX/execution.md` — implementation plan, decisions, tests run, rollout notes, follow-ups

## Steps

1. Determine the ticket number from the current branch:
   ```bash
   git branch --show-current
   ```

2. Check if artifacts exist:
   ```bash
   bash scripts/check_feature_artifacts.sh
   ```

3. Create or update artifacts as needed. Ensure:
   - Artifacts created before significant code edits
   - Updated when scope, decisions, tests, or rollout details change
   - Ticket ID matches branch ticket ID
   - Content is non-sensitive

## Done criteria

- Required files exist and are non-empty
- Content aligned with implemented behavior and tests
- `bash scripts/check_feature_artifacts.sh` passes

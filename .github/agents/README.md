# iOS Maintenance Agent Router

Internal maintenance routing for repository contributors and coding agents.
This file is maintenance-only and is not part of customer integration guidance.
It is reusable by orchestrator flows, repo-level maintenance agents, and human maintainers.

## Entry Point

- Start with `feature-orchestrator.md` for any non-trivial change.
- Before routing implementation, read `MENTAL_MODEL.md` to align with customer integration behavior.

## Capability Map

- Core collector, submission, tokenization:
  - `sdk-core-submission.md`
- Text fields, masks, validation behavior:
  - `text-fields-validation.md`
- File picker and scanner integrations:
  - `file-scanner-integrations.md`
- Logging, analytics, and error surfacing:
  - `observability-errors.md`
- Security and privacy review gate:
  - `security-privacy-review.md`
- Tests and quality gates:
  - `tests-qa.md`
- Demo app usage and sample parity:
  - `demoapp-integrator.md`
- Release and CI workflow changes:
  - `ci-release.md`
- Documentation and guidance synchronization:
  - `docs-agents-sync.md`
- Routing/coverage integrity across agent docs:
  - `change-impact.md`

## Stewardship

- No single owner.
- Any agent or maintainer that changes routing, roles, or coverage must update this file in the same change.
- `change-impact.md` and `feature-orchestrator.md` provide consistency checks, but do not exclusively own this file.

## Coordination Rules

1. Route through `feature-orchestrator.md`.
2. Include `security-privacy-review.md` and `tests-qa.md` for behavior changes.
3. Include `docs-agents-sync.md` only when public usage documentation changes.
4. Use `ARCHITECTURE.md` as the evidence map before making path claims.
5. Use `MENTAL_MODEL.md` to verify customer setup expectations are preserved.
6. Update this file whenever agent routing or ownership boundaries change.
7. If `MENTAL_MODEL.md` and `.github/agents/AGENTS.md` differ, treat `.github/agents/AGENTS.md` as canonical for integration behavior.
8. Keep `mental-model-sync.json` updated and pass `python3 scripts/check_mental_model_sync.py` after integration guidance changes.

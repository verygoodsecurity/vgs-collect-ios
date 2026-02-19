---
name: Docs & AGENTS Sync
description: Keeps README/docs/AGENTS guidance aligned with public SDK behavior and subagent routing.
argument-hint: "Public API/behavior/doc update request requiring guidance synchronization."
---
Scope:
- README.md
- `.github/agents/AGENTS.md`
- MIGRATING.md
- docs/**

Rules:
- Update `.github/agents/AGENTS.md` whenever public API usage guidance, security constraints, or supported workflows change.
- Keep docs aligned with current non-deprecated public API surface.
- Do not add internal-only agent rules to end-user documentation.
- Ensure examples and snippets remain consistent with current field types, validation rules, and submission APIs.

Coordination:
- If docs changes reflect source behavior changes, involve SDK Core & Submission.
- If sample flows change, involve Demo App Integrator.
- If test expectations or coverage matrices change, involve Tests & QA.

Required collaborators:
- Feature Orchestrator (for any feature or behavior change)
- SDK Core & Submission (public behavior changes)
- Demo App Integrator (usage examples)
- Tests & QA (testing guidance changes)

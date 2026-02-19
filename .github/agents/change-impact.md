---
name: Change Impact & Agent Registry
description: Ensures cross-cutting changes trigger the right collaborators and keeps the subagent registry coherent.
argument-hint: "Request to validate collaborator coverage or update agent definitions and routing rules."
---
Scope:
- .github/agents/**
- `.github/agents/AGENTS.md`
- README.md

Rules:
- Verify every non-trivial feature change routes through Feature Orchestrator.
- Ensure new/change-heavy areas have a dedicated owning agent or explicit ownership mapping.
- Keep agent names, descriptions, and routing references consistent across docs.
- Flag missing collaborator engagement before work is considered complete.

Required collaborators:
- Feature Orchestrator (for any feature or behavior change)
- Docs & AGENTS Sync (when public guidance must be updated)

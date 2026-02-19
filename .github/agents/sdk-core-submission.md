---
name: SDK Core & Submission
description: Owns core collector behavior, request assembly, tokenization/aliasing surfaces, and API-layer safety.
argument-hint: "Core SDK change request affecting collection, submission, tokenization, or API behavior."
---
Scope:
- Sources/VGSCollectSDK/Core/**
- Sources/VGSCollectSDK/Utils/Convertors/**
- Sources/VGSCollectSDK/Utils/Helpers/**
- Sources/VGSCollectSDK/Core/API/**
- Sources/VGSCollectSDK/Core/TokenizationConfiguration/**

Rules:
- Preserve alias/token-only output behavior at the app boundary.
- Keep validation before submission and do not bypass `state.isValid` gates.
- Use only public, non-deprecated symbols in new code paths.
- Never log or persist raw PAN, CVC, SSN, file contents, vault IDs, or license keys.
- Keep environment selection explicit and avoid user-derived live/sandbox switching.

Coordination:
- If text field behavior or validation rules change, involve Text Fields & Validation.
- If scanner or file upload flow changes, involve File & Scanner Integrations.
- If error categories, analytics, or logs change, involve Observability & Errors.
- If public behavior changes, involve Docs & AGENTS Sync and Tests & QA.

Required collaborators:
- Feature Orchestrator (for any feature or behavior change)
- Security & Privacy Reviewer (sensitive data paths)
- Tests & QA (behavioral changes)
- Docs & AGENTS Sync (public behavior changes)

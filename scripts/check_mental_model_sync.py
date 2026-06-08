#!/usr/bin/env python3
"""Validate retained .codex agent guidance files exist and stay aligned."""

from __future__ import annotations

import pathlib
import sys


def main() -> int:
    repo_root = pathlib.Path(__file__).resolve().parents[1]
    agents_path = repo_root / "AGENTS.md"
    codex_agents_path = repo_root / ".codex" / "agents" / "AGENTS.md"
    mental_model_path = repo_root / ".codex" / "agents" / "MENTAL_MODEL.md"

    if not agents_path.exists():
        print(f"Missing AGENTS.md: {agents_path}", file=sys.stderr)
        return 1
    if not codex_agents_path.exists():
        print(f"Missing .codex agent entrypoint: {codex_agents_path}", file=sys.stderr)
        return 1
    if not mental_model_path.exists():
        print(f"Missing mental model: {mental_model_path}", file=sys.stderr)
        return 1

    agents_text = agents_path.read_text(encoding="utf-8")
    codex_agents_text = codex_agents_path.read_text(encoding="utf-8")
    mental_text = mental_model_path.read_text(encoding="utf-8")

    failures: list[str] = []

    required_agents_text = [
        "All fields validated (`state.isValid`) before submission.",
        "Never log full PAN / CVC / SSN / raw file contents.",
        "APIs used exist in current public surface & are not deprecated.",
    ]
    required_codex_text = [
        ".codex/agents/AGENTS.md",
        ".codex/agents/MENTAL_MODEL.md",
        "~/.codex/skills/collect-ios-",
    ]
    required_mental_text = [
        "No raw PAN/CVC/SSN/file content leaks",
        "Validation gates remain in place before submit/tokenize",
        "Maintenance routing: `.codex/agents/AGENTS.md`",
    ]
    forbidden_text = [
        ".codex/agents/README.md",
        ".github/agents",
        "feature-orchestrator.toml",
        "tests-qa.toml",
        "mental-model-sync.json",
    ]

    for text in required_agents_text:
        if text not in agents_text:
            failures.append(f"AGENTS.md missing required text: {text}")
    for text in required_codex_text:
        if text not in codex_agents_text:
            failures.append(f".codex/agents/AGENTS.md missing required text: {text}")
    for text in required_mental_text:
        if text not in mental_text:
            failures.append(f"MENTAL_MODEL.md missing required text: {text}")
    for text in forbidden_text:
        if text in codex_agents_text or text in mental_text:
            failures.append(f"Retained .codex guidance contains forbidden text: {text}")

    if failures:
        print("Mental model sync check failed:", file=sys.stderr)
        for failure in failures:
            print(f" - {failure}", file=sys.stderr)
        return 1

    print("Mental model sync check passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

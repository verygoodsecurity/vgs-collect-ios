#!/usr/bin/env python3
"""Validate .codex mental-model guidance stays aligned with top-level AGENTS.md."""

from __future__ import annotations

import json
import pathlib
import sys


def main() -> int:
    repo_root = pathlib.Path(__file__).resolve().parents[1]
    config_path = repo_root / ".codex" / "agents" / "mental-model-sync.json"
    agents_path = repo_root / "AGENTS.md"
    mental_model_path = repo_root / ".codex" / "agents" / "MENTAL_MODEL.md"

    if not config_path.exists():
        print(f"Missing config: {config_path}", file=sys.stderr)
        return 1
    if not agents_path.exists():
        print(f"Missing AGENTS.md: {agents_path}", file=sys.stderr)
        return 1
    if not mental_model_path.exists():
        print(f"Missing mental model: {mental_model_path}", file=sys.stderr)
        return 1

    config = json.loads(config_path.read_text(encoding="utf-8"))
    agents_text = agents_path.read_text(encoding="utf-8")
    mental_text = mental_model_path.read_text(encoding="utf-8")

    failures: list[str] = []

    for check in config.get("checks", []):
        check_id = check.get("id", "unknown")
        agents_contains = check.get("agentsContains")
        mental_contains = check.get("mentalModelContains")

        if isinstance(agents_contains, str) and agents_contains not in agents_text:
            failures.append(
                f"[{check_id}] AGENTS.md missing required text: {agents_contains}"
            )
        if isinstance(mental_contains, str) and mental_contains not in mental_text:
            failures.append(
                f"[{check_id}] MENTAL_MODEL.md missing required text: {mental_contains}"
            )

    for forbidden in config.get("forbiddenMentalModelContains", []):
        if isinstance(forbidden, str) and forbidden in mental_text:
            failures.append(f"MENTAL_MODEL.md contains forbidden text: {forbidden}")

    if failures:
        print("Mental model sync check failed:", file=sys.stderr)
        for failure in failures:
            print(f" - {failure}", file=sys.stderr)
        return 1

    print("Mental model sync check passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

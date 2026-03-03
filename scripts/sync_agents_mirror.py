#!/usr/bin/env python3
"""Synchronize .github/agents from .codex/agents source-of-truth."""

from __future__ import annotations

import argparse
import pathlib
import re
import shutil
import sys

SHARED_FILES = [
    "AGENTS.md",
    "README.md",
    "MENTAL_MODEL.md",
    "mental-model-sync.json",
    "template.agent.md",
]


def yaml_quote(value: str) -> str:
    escaped = value.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def parse_instructions(text: str) -> tuple[str, str, str, str]:
    lines = [line.rstrip() for line in text.strip().splitlines()]

    name = ""
    description = ""
    argument_hint = ""

    name_re = re.compile(r"^# Agent:\s*(.+?)\s*$")
    description_re = re.compile(r"^Description:\s*(.+?)\s*$")
    hint_re = re.compile(r'^Argument hint:\s*"(.+?)"\s*$')

    for line in lines:
        if not name:
            m = name_re.match(line)
            if m:
                name = m.group(1)
                continue
        if not description:
            m = description_re.match(line)
            if m:
                description = m.group(1)
                continue
        if not argument_hint:
            m = hint_re.match(line)
            if m:
                argument_hint = m.group(1)
                continue

    if not name or not description or not argument_hint:
        raise ValueError("Failed to parse agent metadata from developer_instructions")

    body_start = None
    for i, line in enumerate(lines):
        if line.startswith("Scope:"):
            body_start = i
            break

    if body_start is None:
        raise ValueError("Failed to parse agent body: missing 'Scope:' section")

    body = "\n".join(lines[body_start:]).strip() + "\n"
    return name, description, argument_hint, body


def extract_developer_instructions(raw_toml: str, toml_path: pathlib.Path) -> str:
    match = re.search(
        r'developer_instructions\s*=\s*"""(.*?)"""',
        raw_toml,
        flags=re.DOTALL,
    )
    if not match:
        raise ValueError(f"{toml_path} missing developer_instructions")
    return match.group(1).strip()


def render_markdown_from_toml(toml_path: pathlib.Path) -> str:
    raw_toml = toml_path.read_text(encoding="utf-8")
    instructions = extract_developer_instructions(raw_toml, toml_path)

    name, description, argument_hint, body = parse_instructions(instructions)

    return (
        "---\n"
        f"name: {name}\n"
        f"description: {description}\n"
        f"argument-hint: {yaml_quote(argument_hint)}\n"
        "---\n"
        f"{body}"
    )


def build_expected_outputs(codex_agents: pathlib.Path) -> dict[str, str]:
    expected: dict[str, str] = {}

    for name in SHARED_FILES:
        src = codex_agents / name
        if not src.exists():
            raise FileNotFoundError(f"Missing shared source file: {src}")
        expected[name] = src.read_text(encoding="utf-8")

    for toml_file in sorted(codex_agents.glob("*.toml")):
        md_name = f"{toml_file.stem}.md"
        expected[md_name] = render_markdown_from_toml(toml_file)

    return expected


def sync(repo_root: pathlib.Path) -> int:
    codex_agents = repo_root / ".codex" / "agents"
    github_agents = repo_root / ".github" / "agents"

    if not codex_agents.exists():
        raise FileNotFoundError(f"Missing source directory: {codex_agents}")

    github_agents.mkdir(parents=True, exist_ok=True)
    expected = build_expected_outputs(codex_agents)

    for name, content in expected.items():
        (github_agents / name).write_text(content, encoding="utf-8")

    for file in sorted(github_agents.iterdir()):
        if not file.is_file():
            continue
        if file.name not in expected:
            file.unlink()

    return 0


def check(repo_root: pathlib.Path) -> int:
    codex_agents = repo_root / ".codex" / "agents"
    github_agents = repo_root / ".github" / "agents"

    if not codex_agents.exists():
        raise FileNotFoundError(f"Missing source directory: {codex_agents}")
    if not github_agents.exists():
        raise FileNotFoundError(f"Missing mirror directory: {github_agents}")

    expected = build_expected_outputs(codex_agents)
    existing = {
        file.name: file.read_text(encoding="utf-8")
        for file in github_agents.iterdir()
        if file.is_file()
    }

    expected_names = set(expected)
    existing_names = set(existing)

    missing = sorted(expected_names - existing_names)
    unexpected = sorted(existing_names - expected_names)
    changed = sorted(
        name
        for name in expected_names & existing_names
        if expected[name] != existing[name]
    )

    if not missing and not unexpected and not changed:
        print("Agent mirror is up to date.")
        return 0

    print("Agent mirror drift detected in .github/agents:", file=sys.stderr)
    for name in missing:
        print(f" - missing: {name}", file=sys.stderr)
    for name in unexpected:
        print(f" - unexpected: {name}", file=sys.stderr)
    for name in changed:
        print(f" - changed: {name}", file=sys.stderr)
    print("Run: python3 scripts/sync_agents_mirror.py", file=sys.stderr)
    return 1


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--check",
        action="store_true",
        help="Validate mirror content without writing files.",
    )
    args = parser.parse_args()

    repo_root = pathlib.Path(__file__).resolve().parents[1]
    try:
        if args.check:
            return check(repo_root)
        return sync(repo_root)
    except Exception as exc:  # pragma: no cover
        print(f"sync_agents_mirror.py failed: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())

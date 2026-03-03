#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

branch="${1:-${GITHUB_HEAD_REF:-${GITHUB_REF_NAME:-$(git branch --show-current)}}}"

# Enforce only DEVX feature branches.
if [[ "$branch" =~ ^feature/DEVX-[0-9]+/ ]]; then
  if [[ ! "$branch" =~ ^feature/(DEVX-[0-9]+)/([a-z0-9][a-z0-9_-]*)$ ]]; then
    echo "Invalid DEVX feature branch naming: '$branch'" >&2
    echo "Expected template: feature/DEVX-<ticket-number>/<short-description>" >&2
    echo "Allowed short-description characters: lowercase letters, digits, '-', '_'." >&2
    exit 1
  fi

  ticket="${BASH_REMATCH[1]}"
  artifacts_dir=".specs/features/${ticket}"
  required_files=(
    "${artifacts_dir}/intake.md"
    "${artifacts_dir}/execution.md"
  )

  missing=()
  for path in "${required_files[@]}"; do
    if [[ ! -s "$path" ]]; then
      missing+=("$path")
    fi
  done

  if [[ ${#missing[@]} -gt 0 ]]; then
    echo "Missing required feature artifacts for branch '$branch':" >&2
    for path in "${missing[@]}"; do
      echo " - $path" >&2
    done
    echo "Create/update artifacts before implementation continues." >&2
    exit 1
  fi

  echo "Feature artifact check passed for $branch."
  exit 0
fi

echo "Feature artifact check skipped for branch '$branch'."

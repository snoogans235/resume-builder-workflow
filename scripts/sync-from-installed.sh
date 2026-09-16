#!/usr/bin/env bash

set -euo pipefail

dry_run=false
commit_changes=false
push_changes=false
commit_message="Sync installed resume workflow evidence"
codex_dir="${CODEX_HOME:-$HOME/.codex}"
agents_source="$codex_dir/agents"
skill_source="$HOME/.agents/skills/job-application"

usage() {
    echo "Usage: ./scripts/sync-from-installed.sh [--dry-run] [--commit] [--push] [--message TEXT] [--agents-source DIRECTORY] [--skill-source DIRECTORY]"
}

while (( $# > 0 )); do
    case "$1" in
        --dry-run)
            dry_run=true
            shift
            ;;
        --commit)
            commit_changes=true
            shift
            ;;
        --push)
            commit_changes=true
            push_changes=true
            shift
            ;;
        --message)
            if (( $# < 2 )); then
                echo "--message requires text" >&2
                exit 1
            fi
            commit_message="$2"
            shift 2
            ;;
        --agents-source)
            if (( $# < 2 )); then
                echo "--agents-source requires a directory" >&2
                exit 1
            fi
            agents_source="$2"
            shift 2
            ;;
        --skill-source)
            if (( $# < 2 )); then
                echo "--skill-source requires a directory" >&2
                exit 1
            fi
            skill_source="$2"
            shift 2
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            echo "Unknown argument: $1" >&2
            usage >&2
            exit 1
            ;;
    esac
done

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repository_dir="$(cd -- "$script_dir/.." && pwd)"
repository_agents="$repository_dir/agents"
repository_skill="$repository_dir/skills/job-application"

if [[ ! -d "$repository_dir/.git" ]]; then
    echo "Not a Git checkout: $repository_dir" >&2
    exit 1
fi
if [[ ! -f "$skill_source/SKILL.md" ]]; then
    echo "Installed job-application skill not found in $skill_source" >&2
    exit 1
fi

shopt -s nullglob
agent_sources=("$agents_source"/job_*.toml)
if (( ${#agent_sources[@]} != 6 )); then
    echo "Expected 6 installed job agent definitions in $agents_source; found ${#agent_sources[@]}" >&2
    exit 1
fi

mapfile_portable() {
    while IFS= read -r line; do
        markdown_sources+=("$line")
    done
}

markdown_sources=()
mapfile_portable < <(find "$skill_source" -type f -name '*.md' ! -path "$skill_source/references/evidence/*" -print | sort)
if (( ${#markdown_sources[@]} == 0 )); then
    echo "No installed workflow Markdown files found in $skill_source" >&2
    exit 1
fi

copy_file() {
    local source="$1"
    local destination="$2"

    if [[ -f "$destination" ]] && cmp -s "$source" "$destination"; then
        echo "unchanged $destination"
    elif [[ "$dry_run" == true ]]; then
        echo "would sync $destination"
    else
        mkdir -p -- "$(dirname -- "$destination")"
        cp -- "$source" "$destination"
        echo "synced $destination"
    fi
}

for source in "${agent_sources[@]}"; do
    copy_file "$source" "$repository_agents/$(basename -- "$source")"
done

for source in "${markdown_sources[@]}"; do
    relative_path="${source#"$skill_source"/}"
    copy_file "$source" "$repository_skill/$relative_path"
done

if [[ "$dry_run" == true ]]; then
    echo "Dry run complete; no files were written, committed, or pushed."
    exit 0
fi

git -C "$repository_dir" status --short -- agents skills/job-application

if [[ "$commit_changes" == true ]]; then
    git -C "$repository_dir" add -- agents skills/job-application
    if git -C "$repository_dir" diff --cached --quiet; then
        echo "No workflow changes to commit."
    else
        git -C "$repository_dir" commit -m "$commit_message"
    fi
fi

if [[ "$push_changes" == true ]]; then
    git -C "$repository_dir" push
fi

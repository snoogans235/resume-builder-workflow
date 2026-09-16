#!/usr/bin/env bash

set -euo pipefail

force=false
dry_run=false
codex_dir="${CODEX_HOME:-$HOME/.codex}"
agents_target="$codex_dir/agents"
skills_target="$HOME/.agents/skills"

usage() {
    echo "Usage: ./installer.sh [--dry-run] [--force] [--agents-target DIRECTORY] [--skills-target DIRECTORY]"
}

while (( $# > 0 )); do
    case "$1" in
        --dry-run)
            dry_run=true
            shift
            ;;
        --force)
            force=true
            shift
            ;;
        --agents-target)
            if (( $# < 2 )); then
                echo "--agents-target requires a directory" >&2
                exit 1
            fi
            agents_target="$2"
            shift 2
            ;;
        --skills-target)
            if (( $# < 2 )); then
                echo "--skills-target requires a directory" >&2
                exit 1
            fi
            skills_target="$2"
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
agent_source_dir="$script_dir/agents"
skill_source="$script_dir/skills/job-application"

for target in "$agents_target" "$skills_target"; do
    if [[ -z "$target" || "$target" == "/" ]]; then
        echo "Refusing unsafe target directory: $target" >&2
        exit 1
    fi
done

if [[ ! -f "$skill_source/SKILL.md" ]]; then
    echo "job-application skill not found in $skill_source" >&2
    exit 1
fi

shopt -s nullglob
agent_sources=("$agent_source_dir"/job_*.toml)
if (( ${#agent_sources[@]} != 6 )); then
    echo "Expected 6 job agent definitions in $agent_source_dir; found ${#agent_sources[@]}" >&2
    exit 1
fi

validate_agent() {
    local source="$1"
    local expected_name
    expected_name="$(basename -- "$source" .toml)"

    if ! grep -Fqx "name = \"$expected_name\"" "$source"; then
        echo "$(basename -- "$source"): missing matching name field" >&2
        return 1
    fi
    if ! grep -Eq '^description = ".+"$' "$source"; then
        echo "$(basename -- "$source"): missing description field" >&2
        return 1
    fi
    if ! grep -Eq '^sandbox_mode = "(read-only|workspace-write)"$' "$source"; then
        echo "$(basename -- "$source"): missing or unsupported sandbox_mode" >&2
        return 1
    fi
    if ! grep -Fqx 'developer_instructions = """' "$source"; then
        echo "$(basename -- "$source"): missing developer instructions" >&2
        return 1
    fi
    if [[ "$(tail -n 1 "$source")" != '"""' ]]; then
        echo "$(basename -- "$source"): developer instructions are not closed" >&2
        return 1
    fi
}

conflicts=()
for source in "${agent_sources[@]}"; do
    validate_agent "$source"
    destination="$agents_target/$(basename -- "$source")"
    if [[ -f "$destination" ]] && ! cmp -s "$source" "$destination" && [[ "$force" != true ]]; then
        conflicts+=("$destination")
    fi
done

skill_destination="$skills_target/job-application"
if [[ -e "$skill_destination" ]] && ! diff -qr -x evidence "$skill_source" "$skill_destination" >/dev/null && [[ "$force" != true ]]; then
    conflicts+=("$skill_destination")
fi

if (( ${#conflicts[@]} > 0 )); then
    for destination in "${conflicts[@]}"; do
        echo "Refusing to overwrite changed installation: $destination" >&2
    done
    echo "Run scripts/sync-from-installed.sh first if those changes should be kept, then rerun with --force." >&2
    exit 2
fi

if [[ "$dry_run" != true ]]; then
    mkdir -p -- "$agents_target" "$skills_target"
fi

for source in "${agent_sources[@]}"; do
    destination="$agents_target/$(basename -- "$source")"
    if [[ -f "$destination" ]] && cmp -s "$source" "$destination"; then
        echo "unchanged $destination"
    elif [[ "$dry_run" == true ]]; then
        if [[ -f "$destination" ]]; then
            echo "would update $destination"
        else
            echo "would install $destination"
        fi
    else
        temporary="$(mktemp "$agents_target/.resume-agent.XXXXXX")"
        cp -- "$source" "$temporary"
        chmod 0644 "$temporary"
        mv -f -- "$temporary" "$destination"
        echo "installed $destination"
    fi
done

if [[ -d "$skill_destination" ]] && diff -qr -x evidence "$skill_source" "$skill_destination" >/dev/null; then
    echo "unchanged $skill_destination"
elif [[ "$dry_run" == true ]]; then
    if [[ -e "$skill_destination" ]]; then
        echo "would update $skill_destination"
    else
        echo "would install $skill_destination"
    fi
else
    temporary_skill="$(mktemp -d "$skills_target/.job-application.XXXXXX")"
    cp -R "$skill_source/." "$temporary_skill/"
    if [[ -e "$skill_destination" ]]; then
        private_evidence="$skill_destination/references/evidence"
        if [[ -d "$private_evidence" ]]; then
            mkdir -p -- "$temporary_skill/references/evidence"
            cp -R "$private_evidence/." "$temporary_skill/references/evidence/"
        fi
        backup_skill="$(mktemp -d "$skills_target/.job-application-backup.XXXXXX")"
        rmdir "$backup_skill"
        mv -- "$skill_destination" "$backup_skill"
        if ! mv -- "$temporary_skill" "$skill_destination"; then
            mv -- "$backup_skill" "$skill_destination"
            exit 1
        fi
        rm -rf -- "$backup_skill"
    else
        mv -- "$temporary_skill" "$skill_destination"
    fi
    echo "installed $skill_destination"
fi

echo "Validated ${#agent_sources[@]} job agent definitions and the job-application skill."
if [[ "$dry_run" == true ]]; then
    echo "Dry run complete; no files were written."
else
    echo "Start a new Codex task if the installed agents or skill are not visible in the current task."
fi

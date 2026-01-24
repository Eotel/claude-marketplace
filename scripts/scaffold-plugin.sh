#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
MARKETPLACE_JSON="$ROOT_DIR/.claude-plugin/marketplace.json"
PLUGINS_DIR="$ROOT_DIR/plugins"

usage() {
  cat <<'USAGE'
Usage: scaffold-plugin.sh <plugin-name> [options]

Options:
  -d, --description <text>  Plugin description
  -v, --version <semver>    Plugin version (default: 0.1.0)
  -a, --author <name>       Author name
      --author-url <url>    Author URL
  -k, --keywords <list>     Comma-separated keywords
  -r, --repository <url>    Repository URL
      --license <text>      License identifier
      --non-interactive     Do not prompt; use defaults where possible
  -h, --help                Show help

Examples:
  ./scripts/scaffold-plugin.sh my-plugin -d "Example" -v 0.1.0
  ./scripts/scaffold-plugin.sh my-plugin --non-interactive
USAGE
}

err() {
  echo "error: $*" >&2
  exit 1
}

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

PLUGIN_NAME="$1"
shift

DESCRIPTION=""
VERSION=""
AUTHOR_NAME=""
AUTHOR_URL=""
KEYWORDS=""
REPOSITORY=""
LICENSE_ID=""
NONINTERACTIVE=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    -d|--description)
      DESCRIPTION="$2"
      shift 2
      ;;
    -v|--version)
      VERSION="$2"
      shift 2
      ;;
    -a|--author)
      AUTHOR_NAME="$2"
      shift 2
      ;;
    --author-url)
      AUTHOR_URL="$2"
      shift 2
      ;;
    -k|--keywords)
      KEYWORDS="$2"
      shift 2
      ;;
    -r|--repository)
      REPOSITORY="$2"
      shift 2
      ;;
    --license)
      LICENSE_ID="$2"
      shift 2
      ;;
    --non-interactive)
      NONINTERACTIVE=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      err "Unknown option: $1"
      ;;
  esac
done

if [[ -z "$PLUGIN_NAME" ]]; then
  err "Plugin name is required"
fi

if [[ ! -f "$MARKETPLACE_JSON" ]]; then
  err "Missing marketplace file: $MARKETPLACE_JSON"
fi

PLUGIN_NAME="$PLUGIN_NAME" \
python3 - "$MARKETPLACE_JSON" <<'PY'
import json
import os
import sys

path = sys.argv[1]
name = os.environ.get("PLUGIN_NAME", "").strip()

with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

if any(p.get("name") == name for p in data.get("plugins", [])):
    print(f"Plugin already exists in marketplace.json: {name}", file=sys.stderr)
    sys.exit(1)
PY

DEFAULT_VERSION="0.1.0"
DEFAULT_DESCRIPTION="TODO: describe ${PLUGIN_NAME}"
DEFAULT_AUTHOR_NAME="$(git -C "$ROOT_DIR" config --get user.name || true)"
DEFAULT_REPOSITORY="$(git -C "$ROOT_DIR" config --get remote.origin.url || true)"

prompt_if_empty() {
  local var_name="$1"
  local label="$2"
  local default_value="$3"
  local current_value
  current_value="${!var_name:-}"

  if [[ -z "$current_value" ]]; then
    if [[ $NONINTERACTIVE -eq 0 && -t 0 ]]; then
      local input
      if [[ -n "$default_value" ]]; then
        read -r -p "$label [$default_value]: " input
        input="${input:-$default_value}"
      else
        read -r -p "$label: " input
      fi
      printf -v "$var_name" '%s' "$input"
    else
      printf -v "$var_name" '%s' "$default_value"
    fi
  fi
}

prompt_if_empty DESCRIPTION "Description" "$DEFAULT_DESCRIPTION"
prompt_if_empty VERSION "Version" "$DEFAULT_VERSION"
prompt_if_empty AUTHOR_NAME "Author name" "$DEFAULT_AUTHOR_NAME"

if [[ $NONINTERACTIVE -eq 0 && -t 0 ]]; then
  if [[ -z "$AUTHOR_URL" ]]; then
    read -r -p "Author URL (optional): " AUTHOR_URL
  fi
  if [[ -z "$KEYWORDS" ]]; then
    read -r -p "Keywords (comma-separated, optional): " KEYWORDS
  fi
  if [[ -z "$REPOSITORY" ]]; then
    read -r -p "Repository URL (optional): " REPOSITORY
  fi
  if [[ -z "$LICENSE_ID" ]]; then
    read -r -p "License (optional): " LICENSE_ID
  fi
fi

if [[ -z "$REPOSITORY" ]]; then
  REPOSITORY="$DEFAULT_REPOSITORY"
fi

PLUGIN_DIR="$PLUGINS_DIR/$PLUGIN_NAME"

if [[ -e "$PLUGIN_DIR" ]]; then
  err "Plugin directory already exists: $PLUGIN_DIR"
fi

mkdir -p "$PLUGIN_DIR/.claude-plugin" "$PLUGIN_DIR/agents" "$PLUGIN_DIR/commands"

cat <<README_EOF > "$PLUGIN_DIR/README.md"
# $PLUGIN_NAME

$DESCRIPTION

## Contents

- commands/: command markdown definitions
- agents/: agent definitions
- .claude-plugin/plugin.json: plugin manifest
README_EOF

: > "$PLUGIN_DIR/agents/.gitkeep"
: > "$PLUGIN_DIR/commands/.gitkeep"

PLUGIN_JSON_PATH="$PLUGIN_DIR/.claude-plugin/plugin.json"

PLUGIN_NAME="$PLUGIN_NAME" \
DESCRIPTION="$DESCRIPTION" \
VERSION="$VERSION" \
AUTHOR_NAME="$AUTHOR_NAME" \
AUTHOR_URL="$AUTHOR_URL" \
KEYWORDS="$KEYWORDS" \
REPOSITORY="$REPOSITORY" \
LICENSE_ID="$LICENSE_ID" \
python3 - "$PLUGIN_JSON_PATH" <<'PY'
import json
import os
import sys

path = sys.argv[1]

data = {
    "name": os.environ.get("PLUGIN_NAME", "").strip(),
    "version": os.environ.get("VERSION", "").strip(),
    "description": os.environ.get("DESCRIPTION", "").strip(),
}

author_name = os.environ.get("AUTHOR_NAME", "").strip()
author_url = os.environ.get("AUTHOR_URL", "").strip()
if author_name or author_url:
    author = {}
    if author_name:
        author["name"] = author_name
    if author_url:
        author["url"] = author_url
    data["author"] = author

repository = os.environ.get("REPOSITORY", "").strip()
if repository:
    data["repository"] = repository

license_id = os.environ.get("LICENSE_ID", "").strip()
if license_id:
    data["license"] = license_id

keywords_raw = os.environ.get("KEYWORDS", "")
keywords = [k.strip() for k in keywords_raw.split(",") if k.strip()]
if keywords:
    data["keywords"] = keywords

with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write("\n")
PY

PLUGIN_NAME="$PLUGIN_NAME" \
DESCRIPTION="$DESCRIPTION" \
VERSION="$VERSION" \
AUTHOR_NAME="$AUTHOR_NAME" \
AUTHOR_URL="$AUTHOR_URL" \
KEYWORDS="$KEYWORDS" \
python3 - "$MARKETPLACE_JSON" <<'PY'
import json
import os
import sys

path = sys.argv[1]
name = os.environ.get("PLUGIN_NAME", "").strip()

with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

plugins = data.get("plugins", [])

description = os.environ.get("DESCRIPTION", "").strip()
version = os.environ.get("VERSION", "").strip()

author_name = os.environ.get("AUTHOR_NAME", "").strip()
author_url = os.environ.get("AUTHOR_URL", "").strip()
keywords_raw = os.environ.get("KEYWORDS", "")
keywords = [k.strip() for k in keywords_raw.split(",") if k.strip()]

entry = {
    "name": name,
    "description": description,
    "source": f"./plugins/{name}",
    "version": version,
}

if author_name or author_url:
    author = {}
    if author_name:
        author["name"] = author_name
    if author_url:
        author["url"] = author_url
    entry["author"] = author

if keywords:
    entry["keywords"] = keywords

plugins.append(entry)

data["plugins"] = plugins

with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write("\n")
PY

echo "Scaffolded plugin at $PLUGIN_DIR"

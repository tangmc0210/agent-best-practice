#!/bin/bash
# Link source (file or directory) into a project's .cursor/rules.
# Prefer symbolic links; fall back to hard links if symlinks are not allowed
# (e.g. Windows without admin/developer mode).
#
# Usage: see usage() below. Target is the project root; links are created
# in target/.cursor/rules.

set -e

SOURCE_DEFAULT="user_rules"
TARGET_DEFAULT="."
POSITIONALS=()

usage() {
    cat <<'EOF'
Usage: init_cursor.sh [OPTIONS] [TARGET] [SOURCE]

  TARGET    Project root directory. Links are created under TARGET/.cursor/rules.
            Default: current directory (.).
  SOURCE   File or directory to link from. If a directory, all files inside
            (one level) are linked. Default: user_rules.

  No args          -> TARGET=., SOURCE=user_rules
  One arg          -> TARGET=<arg>, SOURCE=user_rules
  Two args         -> TARGET=<1st>, SOURCE=<2nd>
  Optional flags   -> --target <path>  --source <path>

  Uses symbolic links when possible; falls back to hard links (e.g. on
  Windows without symlink support).

Options:
  -h, --help   Show this help and exit.

Examples:
  init_cursor.sh
  init_cursor.sh /path/to/project
  init_cursor.sh /path/to/project my_rules
  init_cursor.sh --target . --source user_rules
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)  usage; exit 0 ;;
        --source)   SOURCE="$2"; shift 2 ;;
        --target)   TARGET="$2"; shift 2 ;;
        *)          POSITIONALS+=("$1"); shift ;;
    esac
done

SOURCE="${SOURCE:-$SOURCE_DEFAULT}"
TARGET="${TARGET:-$TARGET_DEFAULT}"

if [[ ${#POSITIONALS[@]} -ge 1 ]]; then
    TARGET="${POSITIONALS[0]}"
fi
if [[ ${#POSITIONALS[@]} -ge 2 ]]; then
    SOURCE="${POSITIONALS[1]}"
fi

# Target is project root; we write into project/.cursor/rules
RULES_DIR="$TARGET/.cursor/rules"

if [[ ! -e "$SOURCE" ]]; then
    echo "Error: source not found: $SOURCE"
    exit 1
fi

mkdir -p "$RULES_DIR"

link_file() {
    local src="$1"
    local dest="$2"
    local abs_src
    abs_src=$(realpath "$src" 2>/dev/null || ( cd "$(dirname "$src")" && pwd )/$(basename "$src"))
    if ln -sf "$abs_src" "$dest" 2>/dev/null; then
        echo "[symlink] $dest -> $src"
        return 0
    fi
    if ln -f "$src" "$dest" 2>/dev/null; then
        echo "[hardlink] $dest -> $src"
        return 0
    fi
    echo "Error: could not create link: $dest"
    return 1
}

if [[ -f "$SOURCE" ]]; then
    TARGET_LINK="$RULES_DIR/$(basename "$SOURCE")"
    link_file "$SOURCE" "$TARGET_LINK" || exit 1
elif [[ -d "$SOURCE" ]]; then
    COUNT=0
    FAIL=0
    for f in "$SOURCE"/*; do
        [[ -e "$f" ]] || continue
        if [[ -f "$f" ]]; then
            name=$(basename "$f")
            link_file "$f" "$RULES_DIR/$name" && ((COUNT++)) || ((FAIL++))
        fi
    done
    if [[ $COUNT -eq 0 && $FAIL -eq 0 ]]; then
        echo "Warning: no files to link in source directory: $SOURCE"
    else
        echo "Linked $COUNT file(s) into $RULES_DIR"
        [[ $FAIL -gt 0 ]] && echo "Failed: $FAIL"
    fi
    [[ $FAIL -gt 0 ]] && exit 1
else
    echo "Error: source is neither a file nor a directory: $SOURCE"
    exit 1
fi

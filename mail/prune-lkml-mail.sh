#!/bin/bash

# Prune old threads from LKML-related maildirs, except those tagged "no-delete".

MAIL_ROOT="$HOME/mail"
WINDOW="${1:-1.week.ago}"
SUBSYSTEM_ARG="$2"

if [ -z "$SUBSYSTEM_ARG" ]; then
    SUBSYSTEM_ARG="all"
fi

declare -A SUBSYSTEMS
SUBSYSTEMS["linux-crypto"]="tc:linux-crypto@vger.kernel.org"
SUBSYSTEMS["u-boot"]="tc:u-boot@lists.denx.de"
SUBSYSTEMS["linux-security-modules"]="tc:linux-security-modules@vger.kernel.org"

REQUESTED_SUBSYSTEMS=()
if [ "$SUBSYSTEM_ARG" = "all" ]; then
    for dir in "${!SUBSYSTEMS[@]}"; do
        REQUESTED_SUBSYSTEMS+=("$dir")
    done
else
    IFS=',' read -r -a REQUESTED_SUBSYSTEMS <<< "$SUBSYSTEM_ARG"
fi

if ! command -v notmuch >/dev/null 2>&1; then
    echo "Error: notmuch is not installed."
    exit 1
fi

NORMALIZED_WINDOW="$WINDOW"
if [[ "$WINDOW" =~ ^([0-9]+)\.([a-zA-Z]+)\.ago$ ]]; then
    COUNT="${BASH_REMATCH[1]}"
    UNIT="${BASH_REMATCH[2]}"
    if [ "$COUNT" = "1" ]; then
        UNIT="${UNIT%s}"
    fi
    NORMALIZED_WINDOW="$COUNT $UNIT ago"
fi

CUTOFF_EPOCH="$(date -d "$NORMALIZED_WINDOW" +%s 2>/dev/null)"
if [ -z "$CUTOFF_EPOCH" ]; then
    echo "Error: Invalid window: $WINDOW"
    exit 1
fi

for dir in "${REQUESTED_SUBSYSTEMS[@]}"; do
    if [ -z "${SUBSYSTEMS[$dir]}" ]; then
        echo "subsystem not supported: $dir"
        continue
    fi

    TARGET="$MAIL_ROOT/$dir"
    if [ ! -d "$TARGET" ]; then
        echo "Skipping $dir (no maildir at $TARGET)"
        continue
    fi

    echo "Pruning $dir (threads older than $WINDOW, excluding tag:no-delete)..."
    ESCAPED_TARGET="${TARGET//\//\\/}"
    PATH_QUERY="path:\"^${ESCAPED_TARGET}/\""

    THREAD_IDS="$(notmuch search --format=json --output=threads \
        "$PATH_QUERY AND not tag:no-delete" | \
        python3 - "$CUTOFF_EPOCH" <<'PY'
import json
import sys

cutoff = int(sys.argv[1])

data = sys.stdin.read().strip()
if not data:
    sys.exit(0)

try:
    threads = json.loads(data)
except json.JSONDecodeError:
    sys.exit(0)

for t in threads:
    ts = t.get("timestamp")
    tid = t.get("thread")
    if ts is None or tid is None:
        continue
    if int(ts) <= cutoff:
        print(tid)
PY
)"

    if [ -z "$THREAD_IDS" ]; then
        echo "No threads eligible for pruning in $dir."
        continue
    fi

    while IFS= read -r tid; do
        [ -z "$tid" ] && continue
        notmuch search --output=files "thread:$tid AND $PATH_QUERY" | \
            while IFS= read -r file; do
                [ -z "$file" ] && continue
                rm -f -- "$file"
            done
    done <<< "$THREAD_IDS"
done

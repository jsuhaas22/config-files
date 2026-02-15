#!/bin/bash

# This script fetches e-mail from subsystems I am interested in. It can be used
# on new machines and old machines. On new machines, it sets up `lei` and the
# saved-search. On old machines, it just invokes `lei up <dir-path>`, since the
# searches are saved to saved-search index.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Configuration
MAIL_ROOT="$HOME/mail"
REMOTE_SOURCE="https://lore.kernel.org/all/"
WINDOW=$1  # Received from Master Script
SUBSYSTEM_ARG=$2

if [ -z "$WINDOW" ]; then
    echo "Error: No time window provided to Fetcher script."
    exit 1
fi

if [ -z "$SUBSYSTEM_ARG" ]; then
    echo "Error: No subsystem list provided. Use \"all\" or a comma-separated list."
    exit 1
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

# 1. Ensure lei is initialized
if [ ! -d "$HOME/.config/lei" ]; then
    echo "Initializing lei..."
    lei init
    lei add-external "$REMOTE_SOURCE"
fi

# 2. Loop through subsystems
for dir in "${REQUESTED_SUBSYSTEMS[@]}"; do
    if [ -z "${SUBSYSTEMS[$dir]}" ]; then
        echo "subsystem not supported: $dir"
        continue
    fi

    TARGET="$MAIL_ROOT/$dir"
    QUERY="${SUBSYSTEMS[$dir]}"

    WINDOW_EFFECTIVE="$WINDOW"
    if [ "$WINDOW" = "auto" ]; then
        WINDOW_EFFECTIVE="$("$SCRIPT_DIR/derive-lkml-window.sh" "$TARGET")"
        echo "Auto window for $dir: $WINDOW_EFFECTIVE"
    fi

    if [ -d "$TARGET/lei/saved-search" ]; then
        echo "Updating $dir (Window: $WINDOW_EFFECTIVE)..."
        if lei q --no-save --augment --threads -o "$TARGET" \
            "$QUERY AND d:$WINDOW_EFFECTIVE.."; then
            date +%s > "$TARGET/.last-fetch"
        else
            echo "Error: fetch failed for $dir"
            continue
        fi
    else
        echo "First-time setup for $dir (Window: $WINDOW_EFFECTIVE)..."
        mkdir -p "$TARGET"
        # We use the window only for the initial query
        if lei q -o "$TARGET" -f maildir --threads \
            "$QUERY AND d:$WINDOW_EFFECTIVE.."; then
            date +%s > "$TARGET/.last-fetch"
        else
            echo "Error: fetch failed for $dir"
            continue
        fi
    fi
done

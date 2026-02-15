#!/bin/bash

TARGET="$1"

if [ -z "$TARGET" ]; then
    echo "Error: No maildir target provided."
    exit 1
fi

LAST_FETCH_FILE="$TARGET/.last-fetch"
if [ -f "$LAST_FETCH_FILE" ]; then
    LAST_FETCH_EPOCH="$(cat "$LAST_FETCH_FILE" 2>/dev/null)"
    if [ -n "$LAST_FETCH_EPOCH" ]; then
        if WINDOW="$(date -d "@$LAST_FETCH_EPOCH" +"%Y-%m-%d" 2>/dev/null)"; then
            echo "$WINDOW"
            exit 0
        fi
    fi
fi

CONFIG="$TARGET/lei/saved-search/config"
if [ -f "$CONFIG" ]; then
    LASTRESULT="$(awk -F'=' '
        /^\s*lastresult\s*=/ {
            gsub(/[ \t]/, "", $2);
            if ($2 ~ /^[0-9]+$/ && $2 > max) max = $2;
        }
        END { if (max > 0) print max }
    ' "$CONFIG")"

    if [ -n "$LASTRESULT" ]; then
        if WINDOW="$(date -d "@$LASTRESULT" +"%Y-%m-%d" 2>/dev/null)"; then
            echo "$WINDOW"
            exit 0
        fi
    fi
fi

echo "1.week.ago"

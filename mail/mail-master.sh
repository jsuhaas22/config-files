#!/bin/bash

# This script is the `master` script for all lore.kernel.org related activities
# in my workflow. This script uses various helper scripts in
# config-files/mail/. The helpers it uses currently are:
# 	`prune-kernel-mail`: to delete old mail
#	`fetch-kernel-mail`: to fetch new mail
# For fetching, it optionally accepts a SYNC_WINDOW ("how many days of mail to
# fetch, from today backwards?"). If not specified, `fetch-kernel-mail` handles
# it by fetching all e-mails between today and the date of the last e-mail
# fetched in the respective mail directory.

# 1. Determine the window.
# If $1 is provided (e.g., ./sync-mail 2.weeks.ago), use it.
# Otherwise, default to "auto" and derive the window per subsystem.
SYNC_WINDOW="${1:-auto}"

# 1b. Determine subsystems. Default to all if not provided.
SUBSYSTEMS="${2:-all}"

echo "Starting kernel mail sync with window: $SYNC_WINDOW (subsystems: $SUBSYSTEMS)"

# 2. Run the Pruner (We will define this in the next step)
# It's good to prune based on the same window to keep things consistent
# If we're auto-deriving for fetch, prune using a safe fixed window.
PRUNE_WINDOW="$SYNC_WINDOW"
if [ "$PRUNE_WINDOW" = "auto" ]; then
    PRUNE_WINDOW="1.week.ago"
fi
~/.local/bin/prune-lkml-mail.sh "$PRUNE_WINDOW" "$SUBSYSTEMS"

# 3. Run the Fetcher with the window
~/.local/bin/fetch-lkml-mail.sh "$SYNC_WINDOW" "$SUBSYSTEMS"

# 4. Index and Tag
notmuch new

echo "Sync complete."

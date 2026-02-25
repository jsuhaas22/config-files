#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/toolchain.sh"

if [ "$#" -lt 3 ]; then
    echo "Usage: $0 <COMPONENT> <TARGET> <DEVICE> [ARGS...]" >&2
    exit 2
fi

COMPONENT="$1"
TARGET="$2"
DEVICE="$3"
shift 3

case "$COMPONENT" in
    tfa|optee|uboot)
        ;;
    *)
        echo "Not supported: COMPONENT '$COMPONENT'" >&2
        exit 1
        ;;
esac

case "$DEVICE" in
    am62x|am64x|am62p|am62l|am62a)
        ;;
    *)
        echo "Not supported: DEVICE '$DEVICE'" >&2
        exit 1
        ;;
esac

"$SCRIPT_DIR/build-$COMPONENT.sh" "$TARGET" "$DEVICE" "$@"

#!/bin/bash
set -euo pipefail

if [ "$#" -lt 3 ]; then
    echo "Usage: $0 <TARGET> <DEVICE> <BUILDCONFIG>" >&2
    exit 2
fi

TARGET_INPUT="$1"
DEVICE="$2"
BUILDCONFIG="$3"

case "$BUILDCONFIG" in
    ti-6.12-config|ti-6.18-config|upstream-6.12-config|upstream-6.18-config)
        ;;
    *)
        echo "Not supported: BUILDCONFIG '$BUILDCONFIG'" >&2
        exit 1
        ;;
 esac

PLAT=""
TARGET_BOARD=""
SPD=""

if [ "$DEVICE" != "am62l" ]; then
    PLAT="k3"
    TARGET_BOARD="lite"
    SPD="opteed"
else
    case "$BUILDCONFIG" in
        ti-6.12-config)
            PLAT="k3"
            TARGET_BOARD="am62l"
            SPD="opteed"
            ;;
        ti-6.18-config)
            PLAT="k3low"
            TARGET_BOARD="am62lx"
            SPD="none"
            ;;
        *)
            echo "Not supported: BUILDCONFIG '$BUILDCONFIG' for DEVICE 'am62l'" >&2
            exit 1
            ;;
    esac
fi

case "$TARGET_INPUT" in
    atf|distclean|cleanbuild)
        ;;
    *)
        echo "Not supported: TARGET '$TARGET_INPUT'" >&2
        exit 1
        ;;
esac

TARGET="$TARGET_INPUT"
if [ "$TARGET_INPUT" = "atf" ]; then
    TARGET=""
fi

if [ "$TARGET_INPUT" = "cleanbuild" ]; then
    make ARCH=aarch64 CROSS_COMPILE="$CROSS_COMPILE_64" PLAT="$PLAT" TARGET_BOARD="$TARGET_BOARD" SPD="$SPD" distclean
    TARGET=""
fi

make ARCH=aarch64 CROSS_COMPILE="$CROSS_COMPILE_64" PLAT="$PLAT" TARGET_BOARD="$TARGET_BOARD" SPD="$SPD" $TARGET

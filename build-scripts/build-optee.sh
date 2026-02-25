#!/bin/bash
set -euo pipefail

if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <TARGET> <DEVICE>" >&2
    exit 2
fi

TARGET_INPUT="$1"
DEVICE="$2"

case "$TARGET_INPUT" in
    optee|distclean|cleanbuild)
        ;;
    *)
        echo "Not supported: TARGET '$TARGET_INPUT'" >&2
        exit 1
        ;;
esac

PLATFORM=""
case "$DEVICE" in
    am62l)
        PLATFORM="k3-am62lx"
        ;;
    am62x|am62p|am62a)
        PLATFORM="k3-am62x"
        ;;
    am64x)
        PLATFORM="k3-am64x"
        ;;
esac

TARGET="$TARGET_INPUT"
if [ "$TARGET_INPUT" = "optee" ]; then
    TARGET=""
fi

if [ "$TARGET_INPUT" = "cleanbuild" ]; then
    if [ "$DEVICE" = "am62l" ]; then
        make CROSS_COMPILE64="$CROSS_COMPILE_64" PLATFORM="$PLATFORM" CFG_ARM64_core=y CFG_USER_TA_TARGETS=ta_arm64 distclean
    else
        make CROSS_COMPILE="$CROSS_COMPILE_32" CROSS_COMPILE64="$CROSS_COMPILE_64" PLATFORM="$PLATFORM" CFG_ARM64_core=y distclean
    fi
    TARGET=""
fi

if [ "$DEVICE" = "am62l" ]; then
    make CROSS_COMPILE64="$CROSS_COMPILE_64" PLATFORM="$PLATFORM" CFG_ARM64_core=y CFG_USER_TA_TARGETS=ta_arm64 $TARGET
else
    make CROSS_COMPILE="$CROSS_COMPILE_32" CROSS_COMPILE64="$CROSS_COMPILE_64" PLATFORM="$PLATFORM" CFG_ARM64_core=y $TARGET
fi

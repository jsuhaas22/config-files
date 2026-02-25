#!/bin/bash
set -euo pipefail

if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <TARGET> <DEVICE> [CORE]" >&2
    exit 2
fi

TARGET_INPUT="$1"
DEVICE="$2"
CORE="${3:-}"

case "$TARGET_INPUT" in
    uboot|distclean|cleanbuild)
        ;;
    *)
        echo "Not supported: TARGET '$TARGET_INPUT'" >&2
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

R5_DEFCONFIG=""
A53_DEFCONFIG=""
PLAT=""
TARGET_BOARD=""

case "$DEVICE" in
    am62x)
        R5_DEFCONFIG="am62x_evm_r5_defconfig"
        A53_DEFCONFIG="am62x_evm_a53_defconfig"
        ;;
    am62p)
        R5_DEFCONFIG="am62px_evm_r5_defconfig"
        A53_DEFCONFIG="am62px_evm_a53_defconfig"
        ;;
    am62a)
        R5_DEFCONFIG="am62ax_evm_r5_defconfig"
        A53_DEFCONFIG="am62ax_evm_a53_defconfig"
        ;;
    am64x)
        R5_DEFCONFIG="am64x_evm_r5_defconfig"
        A53_DEFCONFIG="am64x_evm_a53_defconfig"
        ;;
    am62l)
        A53_DEFCONFIG="am62lx_evm_defconfig"
        ;;
esac

if [ "$DEVICE" != "am62l" ]; then
    case "$CORE" in
        r5|a53)
            ;;
        *)
            echo "Not supported: CORE '$CORE' (use r5 or a53)" >&2
            exit 1
            ;;
    esac
    PLAT="k3"
    TARGET_BOARD="lite"
fi

TARGET="$TARGET_INPUT"
if [ "$TARGET_INPUT" = "uboot" ]; then
    TARGET=""
fi

run_make_r5() {
    make ARCH=arm CROSS_COMPILE="$CROSS_COMPILE_32" "$R5_DEFCONFIG" O="$UBOOT_DIR/out/r5"
    make ARCH=arm CROSS_COMPILE="$CROSS_COMPILE_32" O="$UBOOT_DIR/out/r5" BINMAN_INDIRS="$TI_LINUX_FW_DIR" $TARGET
}

run_make_a53() {
    make ARCH=arm CROSS_COMPILE="$CROSS_COMPILE_64" "$A53_DEFCONFIG" O="$UBOOT_DIR/out/a53"
    make ARCH=arm CROSS_COMPILE="$CROSS_COMPILE_64" CC="$CC_64" BL31="$TFA_DIR/build/$PLAT/$TARGET_BOARD/release/bl31.bin" \
        TEE="$OPTEE_DIR/out/arm-plat-k3/core/tee-pager_v2.bin" O="$UBOOT_DIR/out/a53" BINMAN_INDIRS="$TI_LINUX_FW_DIR" $TARGET
}

run_make_am62l_a53() {
    make ARCH=arm CROSS_COMPILE="$CROSS_COMPILE_64" "$A53_DEFCONFIG"
    make CROSS_COMPILE="$CROSS_COMPILE_64" BL1="$TFA_DIR/build/k3/am62l/release/bl1.bin" \
        BL31="$TFA_DIR/build/k3/am62l/release/bl31.bin" BINMAN_INDIRS="$TI_LINUX_FW_DIR" \
        TEE="$OPTEE_DIR/out/arm-plat-k3/core/tee-pager_v2.bin" $TARGET
}

if [ "$TARGET_INPUT" = "cleanbuild" ]; then
    TARGET=""
    if [ "$DEVICE" = "am62l" ]; then
        make CROSS_COMPILE="$CROSS_COMPILE_64" distclean
    else
        make ARCH=arm CROSS_COMPILE="$CROSS_COMPILE_32" O="$UBOOT_DIR/out/r5" distclean
        make ARCH=arm CROSS_COMPILE="$CROSS_COMPILE_64" O="$UBOOT_DIR/out/a53" distclean
    fi
fi

if [ "$DEVICE" = "am62l" ]; then
    run_make_am62l_a53
else
    if [ "$CORE" = "r5" ]; then
        run_make_r5
    else
        run_make_a53
    fi
fi

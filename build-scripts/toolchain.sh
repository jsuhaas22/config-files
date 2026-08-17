#!/bin/bash

export UBOOT_DIR=$HOME/git/u-boot
export TI_LINUX_FW_DIR=$HOME/git/ti-linux-firmware
export TFA_DIR=$HOME/git/arm-trusted-firmware
export OPTEE_DIR=$HOME/git/optee/optee_os
export TI_DM=${TI_LINUX_FW_DIR}/ti-dm

COMPILER_PATH=$HOME/devel/arm-toolchain
export CROSS_COMPILE_64=$COMPILER_PATH/arm-gnu-toolchain-13.3.rel1-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu-
export CROSS_COMPILE_32=$COMPILER_PATH/arm-gnu-toolchain-13.3.rel1-x86_64-arm-none-linux-gnueabihf/bin/arm-none-linux-gnueabihf-
export CC_64="${CROSS_COMPILE_64}gcc"
export CC_32="${CROSS_COMPILE_32}gcc"

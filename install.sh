#!/bin/bash

set -ue

SCRIPT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TAG="master"

REPODIR="${SCRIPT_ROOT}/PARTS-llvm"
LLVM_INSTALL="${SCRIPT_ROOT}/llvm-install"
BUILD_DIR="${LLVM_INSTALL}/build"
LINARO_RELEASE_URL="https://releases.linaro.org/components/toolchain/binaries/7.3-2018.05/aarch64-linux-gnu/"
LINARO_SYSROOT_FILENAME="sysroot-glibc-linaro-2.25-2018.05-aarch64-linux-gnu.tar.xz"
LINARO_SYSROOT_URL="${LINARO_RELEASE_URL}/${LINARO_SYSROOT_FILENAME}"
LINARO_GCC_FILENAME="gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu.tar.xz"
LINARO_GCC_URL="${LINARO_RELEASE_URL}/${LINARO_GCC_FILENAME}"

EXAMPLE_DIR="${SCRIPT_ROOT}/example"

declare -a pkg_dependencies=(
git cmake ccache python-dev libncurses5-dev swig libedit-dev
libxml2-dev build-essential gcc-7-plugin-dev ninja-build clang-6.0
libclang-6.0-dev lld-6.0
)

is_package_installed() {
    local pkg="$1"

    [[ -n "${pkg}" ]] || (>&2 echo "missing argument" && return 1)

    if command -v dpkg >/dev/null 2>&1; then
        if  dpkg -s "${pkg}" > /dev/null 2>&1; then
            return 0;
        fi
        return 1
    fi

    >&2 echo "checks.sh:${FUNCNAME[0]}: cannot find dpkg"
    return 1
}

check_packages() {
    local missing=""

    for pkg in "${pkg_dependencies[@]}"; do
        if ! is_package_installed "${pkg}"; then
            missing="${missing} ${pkg}"
        fi
    done

    if [[ -n ${missing} ]]; then
        echo "please install ${missing}"
        exit 1
    fi
    return 0
}

dependencies() {
    echo "Checking dependencies..."
    check_packages
}

compiler() {
    echo "Clonging PARTS LLVM..."
    git clone --depth 1 -b "$TAG" https://github.com/pointer-authentication/PARTS-llvm.git "$REPODIR"

    echo "Clonging Clang..."
    cd "$REPODIR"
    git clone --depth 1 -b release_60 https://github.com/llvm-mirror/clang.git "$REPODIR"/tools/clang --depth 1

    echo "Compiling LLVM + PACStack..."
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"
    cmake -G Ninja \
        -DCMAKE_INSTALL_PREFIX="$LLVM_INSTALL"  \
        -DCMAKE_BUILD_TYPE=Release              \
        -DBUILD_SHARED_LIBS=Off                 \
        -DLLVM_TARGETS_TO_BUILD=AArch64         \
        -DLLVM_BUILD_TOOLS=Off                  \
        -DLLVM_BUILD_TESTS=Off                  \
        -DLLVM_BUILD_EXAMPLES=Off               \
        -DLLVM_BUILD_DOCS=Off                   \
        -DLLVM_INCLUDE_EXAMPLES=Off             \
        -DLLVM_ENABLE_LTO=Off                   \
        -DLLVM_ENABLE_DOXYGEN=Off               \
        -DLLVM_ENABLE_RTTI=Off                  \
        "$REPODIR"
    ninja
}

install_sysroot() {
    echo "Setting up Linaro sysroot..."
    cd "${SCRIPT_ROOT}"
    wget "${LINARO_SYSROOT_URL}"
    tar xJf "${LINARO_SYSROOT_FILENAME}"
}

install_gcc() {
    echo "Setting up Linaro sysroot..."
    cd "${SCRIPT_ROOT}"
    wget "${LINARO_GCC_URL}"
    tar xJf "${LINARO_GCC_FILENAME}"
}

compile_example() {
    echo "Compiling example hello_world sample..."
    cd "${EXAMPLE_DIR}"
    make
}

dependencies
compiler
install_sysroot
install_gcc
compile_example


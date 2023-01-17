#!/usr/bin/env bash

# Builds LLVM following the following documentation:
# https://github.com/plaidml/llvm-project#how-to-build-llvm

set -eu

LLVM_REPO=https://github.com/plaidml/llvm.git
LLVM_BRANCH=tpp-mlir

BUILD_TYPE=Release
if [ $# -ge 1 ] && [ "$1" == "-d" ]; then
  echo "Building debug version"
  BUILD_TYPE=Debug
  shift
elif [ $# -ge 1 ] && [ "$1" == "-rd" ]; then
  echo "Building rel+debug version"
  BUILD_TYPE=RelWithDebInfo
  shift
fi
ROOT="$(git rev-parse --show-toplevel)"
if [ ! -d "$ROOT" ]; then
    echo "Cannot find repository root"
    exit 1
fi
pushd "$ROOT"

# Make sure the repo is in a good shape
echo " + Clone/update llvm repo"
mkdir -p repos
pushd repos
if [ -d llvm-project ]; then
  rm -rf llvm-project
fi
git clone --depth 1 -b $LLVM_BRANCH --shallow-submodules $LLVM_REPO
pushd llvm-project

# Create the build structure
LLVM_ROOT=$PWD
BLD_DIR="$LLVM_ROOT/build"
mkdir -p "$BLD_DIR"

# Build llvm-project with LLVM in-tree
echo " + Build llvm-project in-tree"
cmake -GNinja -B $BLD_DIR -S $LLVM_ROOT \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
    -DCMAKE_C_COMPILER_LAUNCHER=ccache \
    -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
    -DCMAKE_C_COMPILER=clang \
    -DCMAKE_CXX_COMPILER=clang++ \
    -DLLVM_ENABLE_PROJECTS=mlir \
    -DLLVM_INSTALL_UTILS=ON \
    -DLLVM_TARGETS_TO_BUILD="X86;NVPTX;AMDGPU" \
    -DLLVM_ENABLE_ASSERTIONS=ON \
    -DLLVM_USE_LINKER=lld
ninja -C "$BLD_DIR" check-mlir

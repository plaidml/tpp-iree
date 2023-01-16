#!/usr/bin/env bash

# Builds TPP-MLIR following the following documentation:
# https://github.com/plaidml/tpp-mlir#how-to-build-tpp-mlir

set -eu

TPPMLIR_REPO=https://github.com/plaidml/tpp-mlir.git
TPPMLIR_BRANCH=iree

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
echo " + Clone/update tpp-mlir repo"
mkdir -p repos
pushd repos
LLVM_ROOT=$PWD/llvm-project/build
if [ -d tpp-mlir ]; then
  rm -rf tpp-mlir
fi
git clone --depth 1 -b $TPPMLIR_BRANCH --shallow-submodules $TPPMLIR_REPO
pushd tpp-mlir

# Create the build structure
TPPMLIR_ROOT=$PWD
BLD_DIR="$TPPMLIR_ROOT/build"
mkdir -p "$BLD_DIR"

# Build tpp-mlir with LLVM in-tree
echo " + Build tpp-mlir in-tree"
cmake -GNinja -B $BLD_DIR -S $TPPMLIR_ROOT \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
    -DCMAKE_C_COMPILER_LAUNCHER=ccache \
    -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
    -DCMAKE_C_COMPILER=clang \
    -DCMAKE_CXX_COMPILER=clang++ \
    -DMLIR_DIR=$LLVM_ROOT/lib/cmake/mlir \
    -DLLVM_EXTERNAL_LIT=$LLVM_ROOT/bin/llvm-lit
ninja -C "$BLD_DIR"

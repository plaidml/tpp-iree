#!/usr/bin/env bash

# Builds IREE following the following documentation:
# https://iree-org.github.io/iree/building-from-source/getting-started/
# https://iree-org.github.io/iree/building-from-source/python-bindings-and-importers/

set -eu

IREE_REPO=https://github.com/plaidml/iree.git
IREE_BRANCH=tpp-mlir

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
# IREE is huge, so we only clone when needed, and update when there already
echo " + Clone/update iree repo"
mkdir -p repos
pushd repos
if [ ! -d iree ]; then
  git clone $IREE_REPO
fi
pushd iree
git checkout $IREE_BRANCH
git pull
git submodule update --init --recursive --depth=1

# Create the build structure
IREE_ROOT=$PWD
BLD_DIR="$IREE_ROOT/build"
mkdir -p "$BLD_DIR"
VENV_DIR="$BLD_DIR/venv"

# Always grab a fresh env environment
echo " + Creating a fresh venv"
rm -rf $VENV_DIR
python -m venv $VENV_DIR
echo "export PATH=\$PATH:$BLD_DIR/tools" >> $VENV_DIR/bin/activate
echo "export PYTHONPATH=$BLD_DIR/compiler/bindings/python:$BLD_DIR/runtime/bindings/python" >> $VENV_DIR/bin/activate
source $VENV_DIR/bin/activate

# Install Python dependencies
echo " + Install Python dependencies"
python -m pip install --upgrade pip
python -m pip install -r $IREE_ROOT/runtime/bindings/python/iree/runtime/build_requirements.txt
python -m pip install tensorflow iree-tools-tf keras transformers torch datasets

# Build iree with LLVM in-tree
echo " + Build iree in-tree"
cmake -GNinja -B $BLD_DIR -S $IREE_ROOT \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
    -DCMAKE_C_COMPILER_LAUNCHER=ccache \
    -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
    -DCMAKE_C_COMPILER=clang \
    -DCMAKE_CXX_COMPILER=clang++ \
    -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
    -DLLVM_ENABLE_ASSERTIONS=ON \
    -DIREE_ENABLE_ASSERTIONS=ON \
    -DIREE_BUILD_PYTHON_BINDINGS=ON \
    -DIREE_ENABLE_LLD=ON \
    -DPython3_EXECUTABLE=$(which python) \
    -DCMAKE_INSTALL_PREFIX=$ROOT/install/iree
ninja -C "$BLD_DIR" install

# Python bindings test
echo " + Checking IREE Python bindings"
python -c "import iree.compiler"
python -c "import iree.runtime"

deactivate

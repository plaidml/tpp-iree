#!/usr/bin/env python3

import git
from datetime import datetime

iree_llvm = git.Repo("./repos/iree/third_party/llvm-project")
iree_commit = iree_llvm.head.commit
iree_date = iree_commit.committed_date
print("IREE's LLVM branch is at " + datetime.fromtimestamp(iree_date).isoformat())

tpp_llvm = git.Repo("./repos/llvm-project")
tpp_commit = tpp_llvm.head.commit
tpp_date = tpp_commit.committed_date
print("TPP-MLIR's LLVM branch is at " + datetime.fromtimestamp(tpp_date).isoformat())

if tpp_date > iree_date:
    print("Can't build this TPP version, LLVM too new for IREE")
elif iree_date > tpp_date:
    print("Need to bring TPP repo to IREE's LLVM")
else:
    print("Versions match, all good")

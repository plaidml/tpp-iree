#!/usr/bin/env python3

import git

iree_llvm = git.Repo("./repos/iree/third_party/llvm-project")
iree_commit = iree_llvm.head.commit
tpp_llvm = git.Repo("./repos/llvm-project")
tpp_commit = tpp_llvm.head.commit
print(iree_commit)
print(tpp_commit)
iree_date = iree_commit.committed_date
tpp_date = tpp_commit.committed_date
print(iree_date)
print(tpp_date)
if tpp_date > iree_date:
    print("Can't build this TPP version, LLVM too new for IREE")
elif iree_date > tpp_date:
    print("Need to bring TPP repo to IREE's LLVM")
else:
    print("Versions match, all good")

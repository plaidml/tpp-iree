# End-to-end integration between tpp-mlir and IREE

This repository serves as the connection between [IREE](https://github.com/iree-org/iree) and [tpp-mlir](https://github.com/plaidml/tpp-mlir/).

It has references to the required repositories (IREE, tpp-mlir, llvm-project) and scripts on how to check them out, patch, build and connect to each other.

We are aiming at three main model features from Python: Resnet's bottleneck layers, DLRM's MLP layers and BERT's MHA layers.

The end goal is to have the minimum amount of patches / glue code between the repositories, leaving the complexity to building and testing.

We also want to expose opportunities to extend upstream MLIR frameworks for controlling dialects and building pipelines.

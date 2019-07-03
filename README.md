# PARTS example

This repository holds a small example setup for testing
[PARTS](https://pointer-authentication.github.io).

You can either just clone this repository and run `./install.sh`, which will
retrieve the PARTS-llvm repository, Linaro sysroot and GCC installations.
Compile PARTS-llvm, and compile the example code in the example directory.
The result is an instrumented binary at `example/example.out`.

Alternatively, you can manually install the Linaro sysroot, GCC, and
PARTS-llvm, and then update then update add a `Makefile.local` to override
paths in `Makefile.common`.

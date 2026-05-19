#!/bin/bash
set -ex

if [ "${gpu_variant}" = "cuda" ]; then
    # The shap setup.py invokes nvcc directly; surface our host C++ compiler so
    # nvcc uses the conda toolchain rather than whatever it finds on PATH.
    export NVCC_PREPEND_FLAGS="-ccbin ${CXX}"
    export CUDA_HOME="${CUDA_HOME:-${BUILD_PREFIX}}"
    export CUDA_PATH="${CUDA_HOME}"
    case "${cuda_compiler_version}" in
        13*)
            # CUDA 13 dropped Maxwell/Pascal/Volta (sm_5x/6x/70/72).
            # Covers Turing, Ampere, Ada, Hopper, Blackwell (B100/B200, RTX 50, DGX Spark).
            export SHAP_CUDA_ARCHITECTURES="75;80;86;89;90;100;103;120;121"
            ;;
        *)
            # Covers Pascal, Volta, Turing, Ampere, Ada, Hopper.
            export SHAP_CUDA_ARCHITECTURES="60;70;75;80;86;89;90"
            ;;
    esac
    # Fail the build if the CUDA extension can't be compiled (no silent CPU fallback).
    export SHAP_REQUIRE_CUDA=1
fi

${PYTHON} -m pip install . -vv --no-deps --no-build-isolation

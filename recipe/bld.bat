@echo on

if "%gpu_variant%"=="cuda" (
    REM shap setup.py invokes nvcc directly; point it at the conda CUDA toolkit.
    set "CUDA_HOME=%BUILD_PREFIX%\Library"
    set "CUDA_PATH=%BUILD_PREFIX%\Library"
    set "CUDAToolkit_ROOT=%BUILD_PREFIX%\Library"
    REM CUDA 13 dropped sm_5x/6x/70/72; older toolkits keep the broader list.
    REM CUDA 13: Turing through Blackwell incl. B100/B200, RTX 50, DGX Spark.
    REM CUDA 12: Pascal through Hopper.
    if "%cuda_compiler_version:~0,2%"=="13" (
        set "SHAP_CUDA_ARCHITECTURES=75;80;86;89;90;100;103;120;121"
    ) else (
        set "SHAP_CUDA_ARCHITECTURES=60;70;75;80;86;89;90"
    )
    REM Fail the build if the CUDA extension can't be compiled (no silent CPU fallback).
    set "SHAP_REQUIRE_CUDA=1"
)

%PYTHON% -m pip install . -vv --no-deps --no-build-isolation
if errorlevel 1 exit /b 1

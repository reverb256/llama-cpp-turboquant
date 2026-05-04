{
  lib,
  autoAddDriverRunpath,
  cmake,
  fetchFromGitHub,
  cudaPackages,
  git,
  ninja,
  ...
}:
let
  effectiveStdenv = cudaPackages.backendStdenv;
  cmakeBool = option: value: "-D${option}=" + (if value then "ON" else "OFF");
  cmakeFeature = feature: value: "-D${feature}=${value}";
in
effectiveStdenv.mkDerivation rec {
  pname = "llama-cpp-turboquant";
  version = "0.0.3-spiritbuun-aecbbd5da";

  src = fetchFromGitHub {
    owner = "spiritbuun";
    repo = "buun-llama-cpp";
    rev = "aecbbd5da";
    hash = "sha256-hXWS2R5GuRPTgmci4OxLkBNbmEHH84TmOhdeVYEnocM=";
  };

  # TriAttention patch temporarily disabled — needs rebase onto 325+ upstream commits.
  # Will re-implement after baseline build is verified.
  # postPatch = ''
  #   patch -p1 < ${./triattention.patch}
  # '';

  nativeBuildInputs = with cudaPackages; [
    cmake
    git
    cuda_nvcc
    ninja
    autoAddDriverRunpath
  ];

  buildInputs = with cudaPackages; [
    cuda_cccl
    cuda_cudart
    libcublas
  ];

  # Target x86-64-v3 (AVX2) — binary runs on Zen 1/2/3 + Coffee Lake
  CFLAGS = "-march=x86-64-v3 -mtune=znver3";

  cmakeFlags = [
    (cmakeBool "GGML_CUDA" true)
    (cmakeBool "GGML_CUDA_F16" true)
    (cmakeBool "GGML_NATIVE" false)
    # CPU: x86-64-v3 covers all cluster nodes
    #   Zephyr: 5950X (Zen 3) | Nexus: 3900X (Zen 2)
    #   Sentry: 1700X (Zen 1) | Forge: i5-9500F (Coffee Lake)
    # All AVX2+FMA+F16C, none AVX512
    (cmakeBool "GGML_AVX2" true)
    (cmakeBool "GGML_FMA" true)
    (cmakeBool "GGML_F16C" true)
    (cmakeBool "GGML_AVX512" false)
    (cmakeBool "GGML_CUDA_FA" true)
    (cmakeBool "GGML_CUDA_FA_ALL_QUANTS" true)
    # Static linking: all ggml/llama code baked into binary, no system libggml.so deps
    # Prevents symbol conflicts with system ggml (missing spiritbuun quant symbols)
    (cmakeBool "BUILD_SHARED_LIBS" false)
    # RTX 3090 = sm_86 (pure Ampere), RTX 4070 Ti = sm_89 (Ada)
    # RTX 3060 Ti = sm_86 (Ampere) — both zephyr GPUs are sm_86
    (cmakeFeature "CMAKE_CUDA_ARCHITECTURES" "86")
    (cmakeFeature "CMAKE_BUILD_TYPE" "Release")
    # Link ggml-cuda statically — avoids runtime symbol lookup from system libggml.so
    (cmakeBool "GGML_CUDA_STATIC" true)
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -Dm755 bin/llama-server $out/bin/llama-server
    install -Dm755 bin/llama-cli $out/bin/llama-cli
    install -Dm755 bin/llama-perplexity $out/bin/llama-perplexity
    ln -sf llama-cli $out/bin/llama
    runHook postInstall
  '';

  meta = {
    description = "llama.cpp with DFlash speculative decoding + TurboQuant TCQ KV cache compression (spiritbuun fork)";
    homepage = "https://github.com/spiritbuun/buun-llama-cpp";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}

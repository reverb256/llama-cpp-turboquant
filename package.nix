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
  version = "0.0.1-spiritbuun-triattention";

  src = fetchFromGitHub {
    owner = "spiritbuun";
    repo = "buun-llama-cpp";
    rev = "9a388b52e";
    hash = "sha256-NJ/mohG3uie4Kw+ciItk/havGjXxNGSljTjq+32FNH4=";
  };

  # TriAttention KV cache pruning (arXiv 2604.04921)
  # Patch from atomicmilkshake/llama-cpp-turboquant — adds GPU-accelerated
  # token eviction on top of spiritbuun's DFlash + TCQ + turbo stack.
  # Applied via postPatch because fetchpatch mangles large patches.
  postPatch = ''
    patch -p1 < ${./triattention.patch}
  '';

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

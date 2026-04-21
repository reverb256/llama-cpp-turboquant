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
  version = "1.7.0";

  src = fetchFromGitHub {
    owner = "AmesianX";
    repo = "TurboQuant";
    rev = "v${version}";
    hash = "sha256-1wdz5b7mpidma7ah52ryw0c07am0r76537hlivg12w847dbis3wq";
  };

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

  cmakeFlags = [
    (cmakeBool "GGML_CUDA" true)
    (cmakeBool "GGML_CUDA_F16" true)
    (cmakeBool "GGML_NATIVE" false)
    # CPU: all cluster nodes are x86-64-v2 (AVX2, no AVX512)
    (cmakeBool "GGML_AVX2" true)
    (cmakeBool "GGML_FMA" true)
    (cmakeBool "GGML_F16C" true)
    (cmakeBool "GGML_AVX512" false)
    (cmakeBool "GGML_CUDA_FA" true)
    (cmakeBool "GGML_CUDA_FA_ALL_QUANTS" true)
    (cmakeBool "BUILD_SHARED_LIBS" true)
    (cmakeFeature "CMAKE_CUDA_ARCHITECTURES" "86;89")
    (cmakeFeature "CMAKE_BUILD_TYPE" "Release")
    (cmakeBool "CMAKE_BUILD_RPATH_USE_ORIGIN" true)
    (cmakeBool "CMAKE_INSTALL_RPATH_USE_LINK_PATH" false)
  ];

  postInstall = ''
    install -Dm755 bin/llama-server $out/bin/llama-server
    install -Dm755 bin/llama-cli $out/bin/llama-cli
    install -Dm755 bin/llama-perplexity $out/bin/llama-perplexity
    find . -name "*.so*" -type f -exec install -Dm644 {} $out/lib/ \; || true
    ln -sf $out/bin/llama-cli $out/bin/llama
  '';

  postFixup = ''
    find $out/bin -type f -exec patchelf --shrink-rpath {} \; || true
    find $out/lib -type f -name "*.so*" -exec patchelf --shrink-rpath {} \; || true
  '';

  meta = {
    description = "llama.cpp with TurboQuant KV cache compression — Polar Derotate + Tangent Residual (v1.6.0)";
    homepage = "https://github.com/AmesianX/TurboQuant";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}

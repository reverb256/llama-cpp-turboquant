{
  description = "llama.cpp with TurboQuant KV cache compression (CUDA, optimized for cluster GPUs)";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        config.cudaSupport = true;
      };
    in
    {
      packages.${system} = {
        llama-cpp-turboquant = pkgs.callPackage ./package.nix { };
      };
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [ cmake ninja gcc cudaPackages.cuda_nvcc ];
      };
    };
}

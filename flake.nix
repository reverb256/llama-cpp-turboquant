{
  description = "llama.cpp with TurboQuant KV cache compression";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    buun-llama-cpp = {
      url = "github:spiritbuun/buun-llama-cpp";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, buun-llama-cpp }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      packages.${system} = {
        llama-cpp-turboquant = pkgs.callPackage ./package.nix { };
      };
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [ cmake ninja gcc ];
      };
    };
}

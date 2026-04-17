# llama-cpp-turboquant

Custom llama.cpp build with TurboQuant TCQ (Trellis-Coded Quantization) for KV cache compression.

## Status
🚧 **Building** — Other agent completing the buun-llama-cpp Nix package.

## What It Does
- Compresses KV cache from ~4-6GB → ~1.2GB at 65K context
- Uses `-ctk turbo4 -ctv t4` flags for zero-loss compression
- Enables dense models (Qwen 3.5 27B, Gemma 4 31B) to run with 130K+ context on 3090

## Deployment
K8s pod on zephyr 3090 via nixos-config cluster.

## Source
- buun-llama-cpp: https://github.com/spiritbuun/buun-llama-cpp
- TurboQuant: ICLR 2026 paper

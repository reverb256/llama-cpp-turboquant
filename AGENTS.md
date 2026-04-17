# llama-cpp-turboquant

## Status
Building — other agent completing Nix package.

## What
Custom llama.cpp with TurboQuant KV cache compression.
Deploys as K8s pod on zephyr 3090.

## Key Files
- `package.nix` — Nix derivation (when ready)
- `k8s/` — Kubernetes deployment manifests

## Related
- `/etc/nixos/packages/llama-cpp-turboquant.nix` — original in nixos-config
- Pipeline design: `/data/projects/docs/PIPELINE-DESIGN.md`

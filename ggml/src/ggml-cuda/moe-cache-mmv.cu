#include "common.cuh"

// MoE cache (fork feature) batched matvec providers.
//
// The fork's original implementation lived in mmvq.cu and used dedicated
// mul_mat_vec_q_moe kernels carrying per-row activation ids, gate ids and clamp
// bounds as explicit operands. Upstream refactored mul_mat_vec_q onto a single
// ggml_cuda_mm_fusion_args_device operand set that no longer exposes those
// fields, so those dedicated kernels could not be carried over in this port.
//
// The MoE-cache provider is therefore not registered (see moe-cache.cu), which
// disables the VRAM MoE-expert cache and makes these entry points unreachable.
// They abort loudly if that ever changes rather than returning wrong results.

void ggml_cuda_moe_cache_mmv(
    const void * pool, ggml_type type0, const char * act_q8,
    const int32_t * ids_dev, const int32_t * act_ids_dev,
    float * dst_dev, int64_t n_in, int64_t n_out, int64_t n_slots,
    int64_t slot_stride_bytes, int64_t n_hits, int64_t act_rows, cudaStream_t stream) {
    GGML_UNUSED(pool); GGML_UNUSED(type0); GGML_UNUSED(act_q8);
    GGML_UNUSED(ids_dev); GGML_UNUSED(act_ids_dev); GGML_UNUSED(dst_dev);
    GGML_UNUSED(n_in); GGML_UNUSED(n_out); GGML_UNUSED(n_slots);
    GGML_UNUSED(slot_stride_bytes); GGML_UNUSED(n_hits); GGML_UNUSED(act_rows);
    GGML_UNUSED(stream);
    GGML_ABORT("ggml_cuda_moe_cache_mmv: not ported to the current mul_mat_vec_q API");
}

void ggml_cuda_moe_cache_mmv_fused(
    const void * up_pool, const void * gate_pool, ggml_type type0,
    const char * act_q8, const int32_t * up_ids_dev,
    const int32_t * gate_ids_dev, const int32_t * act_ids_dev,
    float * dst_dev, int64_t n_in, int64_t n_out,
    int64_t slot_stride_bytes, int64_t n_hits, int64_t act_rows,
    float up_min, float up_max, float gate_min, float gate_max,
    cudaStream_t stream) {
    GGML_UNUSED(up_pool); GGML_UNUSED(gate_pool); GGML_UNUSED(type0);
    GGML_UNUSED(act_q8); GGML_UNUSED(up_ids_dev); GGML_UNUSED(gate_ids_dev);
    GGML_UNUSED(act_ids_dev); GGML_UNUSED(dst_dev); GGML_UNUSED(n_in);
    GGML_UNUSED(n_out); GGML_UNUSED(slot_stride_bytes); GGML_UNUSED(n_hits);
    GGML_UNUSED(act_rows); GGML_UNUSED(up_min); GGML_UNUSED(up_max);
    GGML_UNUSED(gate_min); GGML_UNUSED(gate_max); GGML_UNUSED(stream);
    GGML_ABORT("ggml_cuda_moe_cache_mmv_fused: not ported to the current mul_mat_vec_q API");
}

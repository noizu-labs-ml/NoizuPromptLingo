# Self-Hosting Commercially-Licensed Open-Weight Models on Modal: A 7-Modality Buyer's Guide (Mid-2026)

## TL;DR
- **The single best truly-permissive pick per category (Apache-2.0/MIT, no revenue cap):** TTS → **Kokoro-82M** (Apache 2.0); Image/Image-edit → **Qwen-Image / Qwen-Image-Edit** (Apache 2.0), with **Z-Image-Turbo** as the fast/cheap option; STT → **Whisper large-v3 / large-v3-turbo** (MIT) for breadth, **Parakeet-TDT-0.6b-v3** (CC-BY-4.0) for throughput; 3D → **TRELLIS.2** (MIT); Video → **Wan 2.2** (Apache 2.0); Music → **ACE-Step** (Apache 2.0); Sound-effects → **no Apache/MIT dedicated SFX model exists** — the best commercial-safe option is **Stable Audio Open / Stable Audio 3 Small-SFX**, but both are revenue-capped at $1M under the Stability AI Community License.
- **Watch the license traps:** FLUX.1 [dev]/[Krea]/[Kontext] and FLUX.2 [dev] are **non-commercial** (commercial license required); SD 3.5 and all Stable Audio weights are **revenue-capped at $1M**; MusicGen and AudioGen are **CC-BY-NC** (non-commercial); AudioLDM2 is **CC-BY-NC-SA**; HunyuanVideo and Hunyuan3D use **Tencent Community Licenses** (commercial-OK with restrictions/attribution, not OSI-permissive); XTTS (CPML) and F5-TTS (CC-BY-NC) are non-commercial.
- **Modal fit:** Everything except the largest video/image models fits on a single **L40S (48GB)** or **A100-40/80GB**. vLLM gives you a literal OpenAI-compatible endpoint for free for LLM-architecture models (Whisper, Orpheus, Stable Audio via vLLM-Omni); image/video/3D/music models are wrapped in a small Modal FastAPI/`@modal.web_server` shim. Modal ships official examples for vLLM (OpenAI-compatible), batched Whisper, ACE-Step, Chatterbox, LTX-Video, and Flux.

---

## Key Findings

**1. "Open weights" ≠ "commercially licensed."** The most popular models in several categories (FLUX, MusicGen, HunyuanVideo, XTTS, F5-TTS) are *not* permissively licensed. The genuinely Apache-2.0/MIT options are often slightly less famous but completely commercial-safe.

**2. The Alibaba/Tongyi ecosystem is the biggest winner for permissive licensing.** Qwen-Image, Qwen-Image-Edit, Z-Image-Turbo, and Wan 2.1/2.2 are all Apache 2.0 — covering image gen, image editing, and video with no revenue cap.

**3. OpenAI-compatibility is essentially solved for LLM-architecture audio models and trivial-to-wrap for everything else.** vLLM exposes `/v1/audio/transcriptions` (Whisper), `/v1/audio/speech`-style endpoints, and `/v1/chat/completions`. Diffusion models (image/video/3D/music) don't have a "standard" OpenAI endpoint, so you wrap them in a Modal FastAPI route — but several have community OpenAI-compatible servers already (Kokoro-FastAPI, Chatterbox-TTS-Server, Orpheus-FastAPI).

**4. Revenue-capped licenses (Stability AI Community License, $1M) are a real fork in the road.** They're fine for startups under $1M revenue but become a liability as you scale. For a principal engineer building durable infrastructure, prefer the uncapped Apache/MIT options where quality is competitive.

---

## Details by Category

### 1. Text-to-Speech (TTS)

**Commercial-safe (Apache 2.0 / MIT):**
- **Kokoro-82M (Apache 2.0)** — 82M params, StyleTTS2-based, decoder-only. Weights ~160MB FP16; ~1–3GB total VRAM at inference. Runs on CPU or the smallest Modal GPU (T4/L4). Trained only on permissive/public-domain/synthetic audio. RTF ~0.03 on A100. **Serving:** `kokoro` Python lib; community **Kokoro-FastAPI** (`ghcr.io/remsky/kokoro-fastapi-gpu`) exposes a zero-config **OpenAI-compatible `/v1/audio/speech`** endpoint. English + several languages, 54 voices (v1.0). No voice cloning. **Best default commercial TTS to deploy on Modal.** Modal GPU: T4/L4.
- **Chatterbox / Chatterbox-Turbo (MIT)** — Resemble AI. Turbo is 350M params; Original/Multilingual ~500M. 5–7GB VRAM (fits L4/A10). Zero-shot voice cloning from ~10s reference, emotion exaggeration control, paralinguistic tags, 23-language multilingual variant. Built-in PerTh watermark on all output. **Serving:** `chatterbox-tts` PyPI; community **Chatterbox-TTS-Server** (devnen) provides an **OpenAI-compatible** endpoint + Web UI. Modal example exists ("Generate speech with Chatterbox"). Modal GPU: L4/A10.
- **Orpheus-TTS (Apache 2.0)** — Canopy Labs, Llama-3.2-3B backbone (also 1B/400M/150M planned). 3B variant ~8GB+ VRAM (A10/L40S). Zero-shot cloning, emotion tags, ~200ms streaming latency. **Serving:** `orpheus-speech` uses **vLLM under the hood** — so you get vLLM's OpenAI-compatible API; community Orpheus-FastAPI wrapper also exists. Note the underlying weights are Llama-3.2 fine-tunes; Canopy explicitly clears the -ft models for commercial use under Apache 2.0, but include Llama attribution. Modal GPU: A10/L40S.
- **Higgs Audio V2 (~5.8B)** — frequently cited as Apache 2.0 on GitHub but the HF card shows "other"/Boson license; **verify before production** — at least one curator (TTS.ai) removed it as restrictive. Treat as uncertain.

**Restrictively licensed — flag/exclude:**
- **XTTS-v2** → Coqui CPML (non-commercial without separate agreement).
- **F5-TTS** → CC-BY-NC 4.0 (non-commercial).
- **Fish Speech / OpenAudio S1 / Fish Audio S2** → open weights but **commercial use requires a paid license from Fish Audio**.
- **IndexTTS-2** → non-commercial without contacting authors.
- **Parler-TTS** → Apache 2.0 (fine), but verify dataset terms.
- **Dia / Dia2 (Nari Labs)** → reported Apache 2.0; good for multi-speaker dialogue.

**Recommendation:** **Kokoro-82M** for English narration/agents (smallest footprint, true Apache 2.0, OpenAI-compatible server ready). Add **Chatterbox-Turbo (MIT)** when you need voice cloning or emotion control.

---

### 2. Text-to-Image and Text+Image→Image (editing)

**Commercial-safe (Apache 2.0):**
- **Qwen-Image (Apache 2.0)** — 20B MMDiT (Alibaba). Best-in-class text rendering (esp. Chinese/English). Full precision ~40GB VRAM (A100/H100); **GGUF/FP8/4-bit quantization runs in 8–24GB** (L4/A10/L40S/4090). Newer **Qwen-Image-2.0/2509/2512** consolidates gen+edit and reduces params toward ~7B. **Serving:** HF `diffusers`, ComfyUI (native + GGUF + Nunchaku), DiffSynth, SGLang-Diffusion (day-0). Modal GPU: A100/H100 full; L40S with quant.
- **Qwen-Image-Edit / Qwen-Image-Edit-2511 (Apache 2.0)** — instruction-based + semantic + appearance editing, built on the 20B model. Full model ~58GB VRAM; quantized (nf4) runs ~17GB on a 3090/L4-class. **The best commercial-safe instruction image-editing model.** Modal GPU: A100/H100 full; L40S/A10 with quant.
- **Z-Image-Turbo (Apache 2.0)** — Tongyi-MAI, 6B params, S3-DiT, distilled to 8 steps. **Fits comfortably in 16GB VRAM (L4/A10/L40S)**, sub-second on data-center GPUs. As of Dec 8, 2025 Z-Image-Turbo ranked 8th overall and #1 open-source on the Artificial Analysis Text-to-Image Leaderboard, per Tongyi-MAI's repo: "[2025-12-08] Z-Image-Turbo ranked 8th overall on the Artificial Analysis Text-to-Image Leaderboard, making it the #1 open-source model!" (github.com/Tongyi-MAI/Z-Image). Strong bilingual text. Variants: Turbo (fast), Base (fine-tune), Edit (instruction editing). **Best fast/cheap commercial T2I to deploy on Modal.** Modal GPU: L4/A10.
- **SDXL / SD 1.5 (CreativeML Open RAIL-M)** — no revenue cap, commercial use allowed (use-based restrictions only). SDXL 3.5B UNet, 8–12GB VRAM. Deepest LoRA/fine-tune ecosystem. Not OSI-"open source" but commercially usable without revenue limits. Modal GPU: L4/A10.

**Restrictively licensed — flag/exclude:**
- **FLUX.1 [dev], FLUX.1 Krea [dev], FLUX.1 Kontext [dev], FLUX.1 Fill/Depth/Canny/Redux [dev]** → **FLUX.1 [dev] Non-Commercial License**. Commercial use (incl. any revenue-generating or production use, or end-user-facing output) requires a **paid commercial license from BFL**. *Outputs* may be used commercially, but running the model in production is not permitted under the free license. This is the single most common license mistake.
- **FLUX.2 [dev]** → source-available **non-commercial**; **FLUX.2 [klein]** → **Apache 2.0** (the one FLUX you can use freely); Flex/Pro are proprietary API-only.
- **FLUX.1 [schnell]** → **Apache 2.0** (commercial-OK), but older/lower quality than the dev line.
- **SD 3.5 (Large/Medium/Turbo)** → **Stability AI Community License: free under $1M annual revenue**, Enterprise license required above. Revenue-capped, not unconditionally permissive.

**Recommendation:** **Qwen-Image-Edit** for editing and **Qwen-Image** (or **Z-Image-Turbo** for speed/cost) for generation — all Apache 2.0, no caps. Use **FLUX.2 [klein]** if you specifically want the FLUX aesthetic under Apache 2.0. Modal ships a "Edit images with Flux Kontext" and "Run Flux fast with torch.compile" example, but note Kontext/dev licensing.

---

### 3. Speech-to-Text (STT / ASR)

**Commercial-safe:**
- **Whisper large-v3 (MIT)** — OpenAI, 1.55B params, ~10GB VRAM (A10/L40S). 99 languages. **Serving:** vLLM gives a literal **OpenAI-compatible `/v1/audio/transcriptions`** endpoint — `vllm serve openai/whisper-large-v3 --task transcription`. Modal has an **official batched-Whisper example** (2.8x throughput on A10G via dynamic batching). The default, most-compatible choice. Modal GPU: A10/L4.
- **Whisper large-v3-turbo (MIT)** — OpenAI pruned the decoder from 32→4 layers (1.55B→809M params), yielding ~6x faster inference at 216x real-time (60 min audio in ~17s) "while keeping accuracy within 1–2% WER of the full model" (per a production analysis at arunbaby.com and the openai/whisper-large-v3-turbo HF card). ~6GB VRAM. **Best speed/quality/compat balance.** Modal GPU: L4/T4.
- **Distil-Whisper (MIT)** — 756M params, 6x faster, within ~1% WER on long-form English.
- **Parakeet-TDT-0.6b-v3 (CC-BY-4.0)** — NVIDIA NeMo, 600M params, ~5GB weights. **Tops the HF Open ASR leaderboard for throughput** (RTFx >2000 on the 1.1B variant; v3 = 600M, 25 European languages, supports up to 24-min audio with full attention on A100). CC-BY-4.0 **permits commercial use** (attribution required). NVIDIA-GPU dependent (NeMo). Not natively an OpenAI endpoint — wrap in Modal FastAPI, or use `parakeet.cpp`. Modal GPU: L4/A10.
- **Canary-Qwen-2.5B (CC-BY-4.0)** — NVIDIA, tops the Hugging Face Open ASR Leaderboard for accuracy at 5.63% average WER while running at RTFx 418, per NVIDIA's model card and Slator (Jul 2025): "NVIDIA's NeMo Canary Qwen 2.5b tops the English leaderboard with a 5.63% word error rate (WER)." ~8GB VRAM. Accuracy-focused, English. Commercial-OK.

**Recommendation:** **Whisper large-v3-turbo (MIT)** as the default — MIT, multilingual, and vLLM gives you a drop-in OpenAI `/v1/audio/transcriptions` endpoint with in-production parity. Switch to **Parakeet-TDT-0.6b-v3** when you need maximum English/European throughput on an NVIDIA fleet (it's CC-BY-4.0, so keep the attribution notice).

---

### 4. Text/Image-to-3D

**Commercial-safe (MIT):**
- **TRELLIS.2-4B (MIT)** — Microsoft, 4B flow-matching transformer with O-Voxel sparse representation; outputs Gaussians/radiance-fields/meshes with PBR. **Requires ≥24GB VRAM** (tested A100/H100), Linux only, CUDA 12.4. **MIT — fully commercial, no restrictions.** The best commercial-safe high-fidelity image-to-3D. Modal GPU: A100/L40S.
- **Original TRELLIS (MIT)** — up to 2B params, the widely-deployed predecessor.
- **TripoSR (MIT)** — fastest (<1s), 6–8GB VRAM, lower fidelity, huge community. Good for quick previews. Modal GPU: T4/L4.
- **Hi3DGen (MIT)** — strong geometry, MIT.
- **Stable Fast 3D / SF3D** — free for businesses **under $1M revenue** (Stability Community License), so revenue-capped.

**Restrictively licensed — flag:**
- **Hunyuan3D 2.0 / 2.1 (Tencent Community License)** — production-grade PBR, but Tencent license: commercial use allowed **with conditions/attribution** ("Created with Hunyuan 3D-2.1"), territorial restrictions (>100M MAU needs separate license). 2.1: 10GB VRAM shape, 21GB texture, 29GB both. Not OSI-permissive — usable but read the terms. Modal GPU: A10/L40S.

**Recommendation:** **TRELLIS.2-4B (MIT)** for quality, **TripoSR (MIT)** for speed/cost. Both fully commercial. Wrap in a Modal FastAPI route (no standard OpenAI 3D endpoint exists). Modal has Images/Video/3D examples but no official 3D model example as of writing — build a custom `@modal.cls` with a `/generate` route.

---

### 5. Text/Image-to-Video

**Commercial-safe (Apache 2.0):**
- **Wan 2.2 (Apache 2.0)** — Alibaba, MoE design (high-noise + low-noise experts). Variants from 1.3B (8GB VRAM) to 14B/A14B (24GB+ with FP8/INT8 quant; 40GB+ full). Apache 2.0 = **unrestricted commercial use, no revenue cap**, outputs fully yours. **The best truly-permissive video model.** Wan 2.1 also Apache 2.0. (Note: Wan 2.5-Preview/2.6 are API/commercial-only — no open weights; Wan 2.7 weights are again Apache 2.0 per Tongyi.) Modal GPU: L40S (1.3B/quant) up to H100/H200 (14B). Modal has a "Fine-tune Wan2.1 video models" example.
- **Mochi 1 (Apache 2.0)** — Genmo, 10B AsymmDiT, 480p, ~24GB VRAM. Apache 2.0. Surpassed on quality by Wan 2.2 but licensing is clean.
- **LTX-Video / LTX-2.x** — **older LTX-Video (2B/13B) is Apache 2.0**; the newer **LTX-2 / LTX-2.3 uses the LTX Model License: free commercially only under $10M annual revenue** (more generous cap than Stability's $1M, but still a cap). Speed leader (~5s clip in ~4s on a 4090). 12–32GB VRAM depending on version. Modal has "Animate images with LTX-Video" and "Generate video clips with LTX-Video" examples. Modal GPU: L40S/A100.
- **CogVideoX-2B (Apache 2.0)**; CogVideoX-5B uses Tsinghua license (commercial-OK with restrictions). 16–24GB VRAM.

**Restrictively licensed — flag:**
- **HunyuanVideo / HunyuanVideo 1.5 (Tencent Community License)** — best faces/motion, but Tencent license has **territorial restrictions** (not OSI-permissive). 14GB (1.5 w/ offload) to 60–80GB (original). Usable commercially with conditions; read terms.

**Recommendation:** **Wan 2.2 (Apache 2.0)** is the clear commercial-safe pick — scales from 1.3B (L40S) to 14B (H100/H200), unrestricted. Use LTX-2.3 only if under $10M revenue and you need its speed/audio. Wrap in Modal FastAPI; no OpenAI video standard exists.

---

### 6. Text-to-Music

**Commercial-safe (Apache 2.0):**
- **ACE-Step / ACE-Step-v1-3.5B (Apache 2.0)** — ACE Studio + StepFun, 3.5B diffusion + DCAE + linear transformer. ~8GB weights, **<4GB–8GB VRAM** (fits 12GB consumer / L4). Full song in <20s on A100. **ACE-Step 1.5 (Jan 2026)** adds an LM planner (0.6B–4B); 1.5 XL (4B DiT, Apr 2026) needs ≥12–20GB. Apache 2.0 = **fully commercial, no cap.** **Best commercial-safe music model.** **Serving:** own repo + **Modal has an official "Make music with ACE-Step" example**; ComfyUI node. Modal GPU: L4/A10/L40S.
- **YuE 7B (Apache 2.0)** — m-a-p/MAP, autoregressive, full songs with vocals from lyrics, 44.1kHz stereo, 16GB VRAM (A10/L40S), 3–4 min tracks. Apache 2.0. Best for lyric-driven full songs. Modal GPU: L40S/A100.
- **DiffRhythm 2 (Apache 2.0)** — Xiaomi/ASLP, Block Flow Matching, recent and architecturally novel.

**Restrictively licensed — flag/exclude:**
- **MusicGen (CC-BY-NC 4.0)** — Meta. **Weights are non-commercial.** Using MusicGen output commercially violates the license regardless of self-hosting. Code is MIT but weights are NC. Exclude for commercial use.
- **Stable Audio Open** → Stability Community License, **$1M revenue cap** (see §7).

**Recommendation:** **ACE-Step (Apache 2.0)** — fully commercial, fast, fits small GPUs, and has an official Modal example. Use **YuE (Apache 2.0)** when you need lyric-aligned vocal songs.

---

### 7. Text-to-Sound-Effect / General Audio

**This is the hardest category for permissive licensing — there is NO Apache/MIT dedicated text-to-SFX model as of mid-2026.** Every dedicated SFX/general-audio model is either revenue-capped or non-commercial.

**Best commercial-safe option (revenue-capped):**
- **Stable Audio Open 1.0 (Stability AI Community License)** — ~1.1–1.21B params (DiT ~1.06B + T5-base + autoencoder), up to **47s** stereo @ 44.1kHz. DiT uses ~5.9GB VRAM during diffusion; decode peaks higher — comfortable on 12–24GB (L4/A10/L40S). Trained only on CC0/CC-BY/CC-Sampling+ data (Freesound + FMA). **Commercial use IS permitted under $1M annual revenue.** Per the model's LICENSE.md: "this Agreement preserves free access to the Models for people or organizations generating annual revenue of less than US $1,000,000... If at any time You or Your Affiliate(s)... generate more than USD $1,000,000 in annual revenue... any licenses granted to You under this Agreement shall terminate" (huggingface.co/stabilityai/stable-audio-open-1.0/blob/main/LICENSE.md). Above $1M requires an Enterprise license. Best for SFX/field recordings, not vocals/music. **Serving:** `stable-audio-tools`, HF `diffusers` (`StableAudioPipeline`), and **vLLM-Omni** (which can expose it via an OpenAI-style audio endpoint). Modal GPU: L4/A10.
- **Stable Audio 3 Small-SFX (Stability AI Community License, released May 21, 2026)** — a dedicated sound-effects model. Per Stability AI's announcement the Small SFX model is **459M params** (not the ~433M some aggregators report): "a small SFX model and a small model, both running 459 million parameters" (technology.org, May 21 2026; stability.ai/news-updates). Up to **120s**, **CPU-capable** (~1.7–3GB if on GPU). Reference code repo is MIT (code only; weights are Community License). Stability AI states all three open-weight 3.0 models (Small SFX, Small, Medium) are free under the Community License up to $1M revenue: "For organizations with more than $1M in annual revenue, you can get commercial coverage with our Enterprise license. We also offer legal indemnification" (stability.ai/news-updates/meet-stable-audio-3). The newest purpose-built SFX option. Modal GPU: T4/L4 or CPU.
- **Stable Audio Open Small (Stability AI Community License)** — 341M params, generating 11s of 44.1kHz stereo in under 8s on Arm CPUs via Arm's KleidiAI library; free for "companies with annual revenue below $1 million," per Stability AI's release coverage (aibase.com/news/19431; medium.com/@CherryZhouTech). Arm-optimized (runs on a phone). Stability's blog calls it "permissive" but it carries the **same $1M cap** — not Apache/MIT.

**Restrictively licensed — exclude:**
- **AudioGen (facebook/audiogen-medium)** → **CC-BY-NC 4.0** (weights non-commercial; code MIT). 1.5B. Exclude.
- **AudioLDM2 (cvssp/audioldm2)** → **CC-BY-NC-SA 4.0** (non-commercial + share-alike). HF `diffusers` `AudioLDM2Pipeline`. 16kHz. Exclude.

**Permissive workaround:** If you must stay strictly Apache/MIT and need SFX, **ACE-Step (Apache 2.0)** offers a "text-to-samples" LoRA feature that can produce one-shots/loops/SFX, though SFX is secondary to its music focus. There is no purpose-built permissive SFX model.

**Recommendation:** If your revenue is under $1M, **Stable Audio 3 Small-SFX** (or Stable Audio Open 1.0) is the best dedicated SFX model and is commercial-safe — but **plan a migration or Enterprise license before you cross $1M revenue.** If you require unconditional permissive licensing today, there is no dedicated SFX model; repurpose **ACE-Step (Apache 2.0)** for sample/SFX generation or generate SFX assets and verify rights.

---

## Modal Deployment Notes & GPU-Fit Cheat Sheet

**OpenAI-compatible wrapping:**
- **LLM-architecture models (Whisper STT, Orpheus TTS, Stable Audio via vLLM-Omni):** use **vLLM on Modal** → you get `/v1/...` endpoints natively. Modal's official "Deploy an OpenAI-compatible LLM service with vLLM" example is the template (`@modal.web_server`, HF cache on a Modal Volume, `vllm serve`).
- **TTS with existing OpenAI servers:** Kokoro-FastAPI (`/v1/audio/speech`), Chatterbox-TTS-Server, Orpheus-FastAPI — drop these into a Modal image and expose via `@modal.web_server`.
- **Diffusion models (image/video/3D/music/SFX):** no OpenAI standard; build a small `@modal.cls` + FastAPI `/generate` route returning the asset. LiteLLM can route to these as custom endpoints.

**GPU tiers (Modal) — rule of thumb:**
- **T4 (16GB):** Kokoro, Whisper-turbo, TripoSR, Stable Audio 3 Small-SFX.
- **L4 (24GB):** Kokoro, Chatterbox, Whisper large-v3, Z-Image-Turbo, ACE-Step, Parakeet, Stable Audio Open.
- **A10 (24GB):** Orpheus 3B, Wan 2.2 1.3B, quantized Qwen-Image, Canary-Qwen.
- **L40S (48GB):** Qwen-Image (quant), YuE, LTX-Video, TRELLIS.2, Wan 2.2 14B (FP8).
- **A100 (40/80GB):** Qwen-Image/Qwen-Image-Edit full, TRELLIS.2-4B, Wan 2.2 14B, HunyuanVideo.
- **H100/H200 (80/141GB):** Qwen-Image-Edit full (58GB), HunyuanVideo 1080p, Wan 2.2 14B full precision, longer video clips.

**Official Modal examples that map to these categories:** vLLM OpenAI-compatible service; batched Whisper transcription; Fine-tune Whisper; Make music with ACE-Step; Generate speech with Chatterbox; Edit images with Flux Kontext; Run Flux fast with torch.compile; Animate/Generate video with LTX-Video; Run Stable Diffusion with CLI/API/web UI; Deploy a Moshi voice chatbot; Stream transcripts with Kyutai STT.

---

## Recommendations (staged)

**Stage 1 — Stand up the permissive core (do this first):**
1. **STT:** Whisper large-v3-turbo on vLLM (MIT) → instant `/v1/audio/transcriptions`. Modal L4.
2. **TTS:** Kokoro-82M via Kokoro-FastAPI (Apache 2.0) → `/v1/audio/speech`. Modal T4/L4. Add Chatterbox-Turbo (MIT) for cloning.
3. **Image:** Z-Image-Turbo (Apache 2.0) for speed on L4/A10; Qwen-Image (Apache 2.0) on A100 for max quality/text.
4. **Image editing:** Qwen-Image-Edit (Apache 2.0), quantized on L40S or full on A100/H100.

**Stage 2 — Add generative media:**
5. **Video:** Wan 2.2 (Apache 2.0) — 1.3B on L40S, 14B on H100.
6. **Music:** ACE-Step (Apache 2.0) via the Modal example. L4/A10.
7. **3D:** TRELLIS.2-4B (MIT) on A100; TripoSR (MIT) on L4 for previews.

**Stage 3 — Handle the constrained categories deliberately:**
8. **SFX:** If under $1M revenue, deploy Stable Audio 3 Small-SFX (Stability Community License) and track the revenue threshold. Otherwise use ACE-Step for samples. Set an explicit alert/benchmark: **when annual revenue approaches $1M, either buy the Stability Enterprise license or migrate.**

**Thresholds that change these recommendations:**
- **Cross $1M revenue** → drop all Stability Community License models (SD 3.5, Stable Audio family, SF3D) or buy Enterprise licenses.
- **Cross $10M revenue** → LTX-2.3 needs a commercial license; stay on Wan 2.2 (Apache) to avoid this.
- **Need the FLUX aesthetic** → only FLUX.1 [schnell] and FLUX.2 [klein] are Apache 2.0; everything else FLUX requires a BFL commercial license.
- **Need best video faces/motion** → HunyuanVideo (Tencent license, commercial-OK with restrictions) — acceptable only if you've read and can comply with the territorial terms.

## Caveats
- **Licenses change between versions and over time.** Always re-verify the exact LICENSE file on the specific model revision before shipping (e.g., Higgs Audio V2 shows conflicting Apache-vs-"other" across GitHub/HF; Wan open-weight status varies by version).
- **CC-BY-4.0 (Parakeet, Canary) requires attribution** — keep the notice in your distribution. It permits commercial use but is not "no-strings."
- **Model output rights vs. model-use rights are distinct.** FLUX [dev] lets you use *outputs* commercially but prohibits *running the model* in production without a license — a subtle but critical distinction.
- **Tencent Community Licenses (Hunyuan3D, HunyuanVideo) are commercial-capable but not OSI-permissive** — they carry attribution and territorial/MAU conditions. Read them; don't assume "open weights" = Apache.
- **VRAM figures are approximate** and depend heavily on quantization (FP8/GGUF/nf4), resolution, sequence length, and batch size. Benchmark on your target Modal GPU before capacity planning.
- **"Stable Audio Open 1.5" appears to be a mislabel** propagated by some third-party blogs; the real lineage is Stable Audio Open 1.0, Stable Audio Open Small, and the Stable Audio 3.0 family (May 2026).
- Some cited blog/vendor pages contain marketing language and vendor-run benchmarks (e.g., Resemble's Chatterbox blind tests, ElevenLabs comparisons) — treat comparative quality claims as directional, not definitive.

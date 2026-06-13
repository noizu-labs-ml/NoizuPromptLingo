
# GPU/Graphics & LLM Inference from a JS Website — April 2026

## Overview

As of April 2026, browser-based GPU compute and LLM inference have crossed decisively from experimental to production-ready. The catalyst is universal WebGPU support: Chrome, Firefox, Edge, and Safari all now ship WebGPU enabled by default, closing the last major deployment gap. On the inference side, frameworks like WebLLM and Transformers.js v4 can retain up to 80% of native device performance while running entirely in-browser. Developers today have a rich, tiered ecosystem covering everything from raw GPU compute to drop-in OpenAI-compatible LLM APIs.[1][2][3][4]

***

## The WebGPU Foundation

All modern browser inference and GPU compute frameworks build on the **WebGPU API**, the W3C successor to WebGL. Unlike WebGL's state-machine model built on OpenGL compatibility, WebGPU provides low-level GPU control with first-class compute shader support, explicit resource management, and a modern architecture matching how GPUs actually work.[5][6]

Key milestones:
- **Chrome 113** (May 2023): First browser to ship WebGPU by default
- **Firefox 141** (July 2025): Stable Windows support[1]
- **Safari 26** (September 2025): Full support on macOS, iOS, iPadOS, and visionOS[7]
- **January 2026**: All four major browsers ship WebGPU by default[3][1]

Performance benchmarks show **15–30x improvements** for GPU compute workloads over WebGL, and the 2025 Web Almanac reports 65% of new web applications already leveraging WebGPU. WGSL (the shader language) is text-based, safe, and verifiable — no more SPIR-V cross-compilation gymnastics.[3][1]

The key hardware access APIs in 2026:

| API | Target Hardware | Browser Support | Best For |
|-----|----------------|-----------------|---------|
| WebGPU | GPU (discrete + integrated) | All major browsers | LLM inference, rendering, heavy compute[4] |
| WebNN | NPU / dedicated AI accelerators | Chrome, Edge (flags in some configs) | Power-efficient background inference[4][8] |
| WASM + SIMD | CPU | Universal | Fallback, llama.cpp ports, maximum compatibility[4] |

***

## LLM Inference Frameworks

### WebLLM (MLC AI) — Best Overall for LLM Inference

WebLLM is the most mature and polished browser-native LLM inference engine, with 17,000+ GitHub stars. It leverages WebGPU for GPU acceleration with WebAssembly as a CPU fallback, and critically provides a **fully OpenAI-compatible API** — including streaming, JSON mode, function calling, and logit-level control.[9][4][10]

Key characteristics:
- **OpenAI API drop-in**: Same `chat.completions.create()` interface developers use with cloud APIs[10]
- **Performance**: Retains up to 80% of native inference performance on the same device[2][4]
- **Compiler-backed kernels**: Uses MLC-LLM and Apache TVM to generate optimized WebGPU WGSL kernels, compensating for the lack of mature WebGPU kernel libraries[11][2]
- **Worker support**: Offloads inference to Web Workers or Service Workers to keep UI responsive[9]
- **Model coverage**: Llama 3.x, DeepSeek, Phi, SmolLM2, Hermes 3, Qwen, and more[12]
- **Chrome Extension support**: First-class support with examples provided[9]

```js
import { CreateMLCEngine } from "@mlc-ai/web-llm";

const engine = await CreateMLCEngine("Llama-3.2-3B-Instruct-q4f16_1-MLC");
const reply = await engine.chat.completions.create({
  messages: [{ role: "user", content: "Hello!" }],
  stream: true,
});
```

WebLLM is the right choice when you need LLM chat/completion capabilities with the least friction and the highest raw throughput.

***

### Transformers.js v4 (Hugging Face) — Best for Model Diversity

Transformers.js v4 was released in February/March 2026 and represents a major generational leap. The biggest change is a **completely rewritten C++ WebGPU runtime**, built in close collaboration with the ONNX Runtime team and tested across ~200 supported model architectures.[13][14][15]

Key v4 improvements over v3:
- **New WebGPU runtime (C++)**: Better operator coverage, improved performance, and accuracy[13]
- **Cross-runtime**: Same code runs in browsers, Node.js, Bun, and Deno with WebGPU acceleration[15][13]
- **Architecture breadth**: GPT-OSS, Qwen, DeepSeek-v3, Llama 3, Phi-3, Whisper Large-v3, MoE models, Florence-2, and more[16][13]
- **8B+ parameter support**: Tested at ~60 tokens/second for GPT-OSS 20B (q4f16) on M4 Pro Max[13]
- **Modular codebase**: The monolithic `models.js` (~8,000 lines) was split into focused modules for maintainability[13]
- **Dynamic pipeline types**: Enhanced TypeScript typings that adapt based on pipeline inputs[13]

```js
import { pipeline } from "@huggingface/transformers";

const generator = await pipeline("text-generation", "Qwen/Qwen2.5-1.5B-Instruct", {
  device: "webgpu",
  dtype: "q4f16",
});
const output = await generator("Explain WebGPU in one paragraph.");
```

Transformers.js excels at **multimodal and specialized tasks** — NLP, vision, audio transcription, embeddings — where you need more than just text generation. Its Hugging Face Hub integration means access to thousands of pre-converted ONNX models.[17]

***

### wllama — Best for GGUF/llama.cpp Compatibility

`wllama` (by ngxson, a core llama.cpp contributor) is a TypeScript/JavaScript WebAssembly binding for llama.cpp, presented at FOSDEM 2025. It runs any GGUF model in-browser using WASM SIMD with automatic single/multi-thread switching — **no GPU required**.[18][19]

Key characteristics:
- **Full GGUF support**: Load any quantized model directly from Hugging Face Hub[18]
- **High-level + low-level APIs**: Completions, embeddings, (de)tokenization, KV cache control, and sampling control[18]
- **Worker-isolated**: Inference runs in a Web Worker, never blocking the main thread[18]
- **Chunked model loading**: Can split large models into smaller files and load in parallel[18]
- **NPM package**: `@wllama/wllama` with full TypeScript support[18]

wllama is ideal when you need broad GGUF model compatibility, CPU-only fallback support, or when users may not have WebGPU available.

***

### llama.cpp WASM / WebGPU Ports

Beyond wllama, there are direct llama.cpp-to-browser compilations worth knowing:

- **tangledgroup/llama-cpp-wasm**: Emscripten-compiled llama.cpp for browsers with single-thread and multi-thread builds, supporting TinyLlama, Phi-2, and other small GGUF models[20]
- **WebGPU-patched llama.cpp**: Community patches enable WebGPU WGSL kernel use; one notable demo wired it into a Unity WebGL NPC system with a modified Emscripten toolchain[21]

These are less polished than WebLLM but useful when you need direct access to llama.cpp internals.

***

### MediaPipe LLM Task API (Google AI Edge)

Google's **MediaPipe Tasks GenAI** (`@mediapipe/tasks-genai`) provides a WASM-based inference engine specifically for Gemma models (Gemma 3, Gemma 3n) running in the browser. It uses a `.litertlm` model format (LiteRT, Google's TFLite successor) and is designed for privacy-first, serverless AI apps.[22][23]

```js
import { LlmInference, FilesetResolver } from "@mediapipe/tasks-genai";

const genai = await FilesetResolver.forGenAiTasks(
  "https://cdn.jsdelivr.net/npm/@mediapipe/tasks-genai@latest/wasm"
);
const llm = await LlmInference.createFromOptions(genai, {
  baseOptions: { modelAssetPath: '/assets/gemma-3n-E4B-it-int4-Web.litertlm' },
  maxTokens: 1000, temperature: 0.8, topK: 40,
});
```

MediaPipe is a strong choice if you're building specifically around Gemma models or need Google's production-hardened WASM runtime.[23][22]

***

### Chrome Built-in AI (Prompt API)

Chrome's **Built-in AI Prompt API** provides access to Gemini Nano embedded in the browser itself — no model download required. As of April 2026, it is gated behind origin trials (Chrome 139–144) and is actively evolving (Chrome 147 removed two session context methods).[24][25][26]

Key caveats:
- Requires a compatible device (not all hardware qualifies)
- Origin trial gating means it's not suitable for general-audience production use yet
- Supports text, image, and audio input modalities[24]
- Complementary APIs: Summarization, Translation, Language Detection[25]

Best used for Chrome-extension-based projects or exploratory prototypes rather than broad web deployment.

***

## Comparative Summary

| Framework | Primary Use | GPU Acceleration | Model Format | API Style | Maturity |
|-----------|-------------|-----------------|--------------|-----------|----------|
| **WebLLM** | LLM inference | WebGPU (primary) + WASM | MLC-compiled | OpenAI-compatible | ★★★★★ Production |
| **Transformers.js v4** | LLM + multimodal | WebGPU + WebNN + WASM | ONNX (HF Hub) | Pipeline API | ★★★★★ Production |
| **wllama** | LLM inference | WASM SIMD (CPU only) | GGUF | Custom JS/TS | ★★★★☆ Stable |
| **ONNX Runtime Web** | General ML | WebGPU + WebGL + WASM | ONNX | Session API | ★★★★★ Production[27] |
| **MediaPipe Tasks GenAI** | Gemma models | WASM | LiteRT (.litertlm) | Task API | ★★★★☆ Stable[23] |
| **Chrome Built-in AI** | On-device Gemini Nano | Native (bundled) | N/A | Prompt API | ★★☆☆☆ Origin Trial[25] |

***

## GPU/Graphics Rendering Frameworks

### Three.js — Dominant 3D/WebGPU Rendering

Three.js (2.7M+ weekly npm downloads) became **production-ready for WebGPU with r171** (September 2025) via zero-config imports. The key features:[28][3]

- **`WebGPURenderer`**: Drop-in replacement for `WebGLRenderer` with automatic WebGL 2 fallback[28][7]
- **TSL (Three Shader Language)**: Write shaders in JavaScript that compile to both WGSL (WebGPU) and GLSL (WebGL) — single codebase, dual targets[5][7]
- **Performance**: 2–10x improvements for draw-call-heavy scenes vs WebGL[7]
- **React Three Fiber**: Full integration landed with r171[28]

```js
import { WebGPURenderer } from 'three/webgpu';  // zero-config since r171
const renderer = new WebGPURenderer({ antialias: true });
await renderer.init();
```

For existing projects, no immediate migration is needed — when you do migrate, expect performance gains for complex scenes.[28]

### Babylon.js — Advanced Compute Shaders

Babylon.js has supported WebGPU since version 5.0 and rewrote all core engine shaders in native WGSL in 2024. Its standout feature is first-class **compute shader** support via the `ComputeShader` class:[29][3]

- Compute shaders are WebGPU-only (no WebGL fallback for this feature)[29]
- Supports storage textures, storage buffers, and atomic operations[30]
- Enables hybrid rendering + simulation pipelines (particles, fluid, physics)[31]
- Ray tracing support is in-progress[32]

Babylon.js is the right choice when you need raw GPGPU compute power alongside 3D rendering — physics simulations, particle systems, or GPU-accelerated data pipelines running alongside a scene.

### ONNX Runtime Web — The General ML Engine

ONNX Runtime Web is the backbone powering Transformers.js and many custom pipelines. It supports WebGPU, WebGL, and WASM execution providers:[33][27]

```js
import * as ort from 'onnxruntime-web';
const session = await ort.InferenceSession.create('/models/model.onnx', {
  executionProviders: ['webgpu', 'wasm'] // automatic fallback
});
```

The WebGPU backend supports FP16, IOBinding (avoiding GPU-CPU data copies), and has broad operator coverage. It's the right base layer when building custom inference pipelines with non-LLM models (Stable Diffusion Turbo runs at ~1 second on an RTX 4090 via this path).[34]

### TensorFlow.js with WebGPU Backend

TensorFlow.js (`@tensorflow/tfjs-backend-webgpu`) provides a production WebGPU backend for standard TF model architectures. While the last major npm publish was ~7 months ago, the package is actively maintained. It's primarily suited for:[35][36]

- Computer vision models (MobileNet, BlazeFace, HandPose, PoseDetection)
- Lightweight audio models (speech commands)
- Sentence embeddings (Universal Sentence Encoder)
- Rapid prototyping via `tf.setBackend('webgpu')`[37][35]

TensorFlow.js delivers **3x faster** inference than the WebGL backend for these workloads, though for LLMs specifically, WebLLM and Transformers.js are better optimized.[37]

***

## WebNN: The Emerging NPU API

The **Web Neural Network (WebNN) API** is the W3C standard for accessing NPUs and dedicated AI accelerators from JavaScript. It was published as an updated Candidate Recommendation Snapshot in January 2026. Microsoft uses it with DirectML on Windows; Apple Silicon's Neural Engine is a target.[8][38][39]

Current status:
- Chrome and Edge: Progressive rollout with GPU/NPU support in preview state[8]
- Firefox, Safari: No stable support yet[40]
- **Not production-ready** for broad deployment, but the API to watch for power-efficient always-on inference tasks on modern hardware[4][8]

Frameworks like Transformers.js v4 already include WebNN as a backend option alongside WebGPU and WASM.[41]

***

## Recommended Stack by Use Case

| Use Case | Recommended Framework | Notes |
|----------|-----------------------|-------|
| LLM chatbot / assistant | **WebLLM** | OpenAI-compatible API, highest throughput[9][4] |
| Multimodal / NLP / vision pipeline | **Transformers.js v4** | 200+ architectures, HF Hub models[13] |
| GGUF model compatibility / CPU fallback | **wllama** | Best llama.cpp WASM binding[18][19] |
| 3D scenes with WebGPU rendering | **Three.js r171+** | Zero-config, TSL shaders, R3F support[28] |
| GPGPU compute + 3D hybrid | **Babylon.js** | Compute shaders, storage buffers[29][32] |
| Custom ONNX model inference | **ONNX Runtime Web** | Widest model format coverage[34][27] |
| Gemma-specific apps | **MediaPipe Tasks GenAI** | Google's production Gemma runtime[23] |
| CV/pose/detection models | **TensorFlow.js** | Mature ecosystem for standard CV tasks[35] |
| Chrome extensions (zero-download AI) | **Chrome Built-in AI** | Gemini Nano, no model download needed[24][26] |

***

## Practical Considerations

**Model size and download**: Most useful LLMs are 1–4GB quantized. Cache aggressively with Service Workers and stream model bytes on first load. WebLLM and Transformers.js both handle this automatically.[42]

**Memory pressure**: Browser-based inference can consume RAM quickly. Implement a memory monitor (alert at ~80% usage) and support clearing unused model weights between sessions.[12]

**Fallback strategy**: Always implement progressive enhancement — detect `navigator.gpu`, fall back to WASM if unavailable. wllama's CPU-only path is a reliable last resort for broad audience apps.[42][18]

**The "3W Stack"**: For browser-native AI agents, the community-established pattern is WebLLM (inference) + WebAssembly (agent logic via Rust/Go/Pyodide) + Web Workers (off-main-thread orchestration).[4]

**Worker isolation is non-negotiable**: All inference should run in a Web Worker or Service Worker. Blocking the main thread with model loading or token generation will make your UI unresponsive.[9][18]



------

Here's the full landscape as of April 2026 — the ecosystem has genuinely matured this cycle. The report covers everything in depth, but here's the lay of the land:

## LLM Inference

**[WebLLM](https://webllm.mlc.ai)** (MLC AI) is the most polished option for pure LLM inference. It exposes a fully OpenAI-compatible API (`chat.completions.create` with streaming, JSON mode, function calling) running 100% in-browser via WebGPU, retaining up to ~80% of native inference speed. 17k+ GitHub stars, actively maintained, supports Llama 3, DeepSeek, Phi, Qwen, etc. [webgpu](https://www.webgpu.com/news/webgpu-hits-critical-mass-all-major-browsers/)

**[Transformers.js v4](https://huggingface.co/docs/transformers.js)** (Hugging Face, released Feb/Mar 2026) is the better pick when you need more than just text generation — multimodal pipelines, embeddings, ASR, vision. v4 rewrote the WebGPU runtime in C++, now supports 200+ architectures including 8B+ models (~60 tok/s for GPT-OSS 20B on M4 Pro Max), and works across browser, Node, Bun, and Deno. [blog.openreplay](https://blog.openreplay.com/webgpu-vs-webgl-industry-moving/)

**[wllama](https://github.com/ngxson/wllama)** is the cleanest llama.cpp WASM binding — runs any GGUF model CPU-only with SIMD, auto single/multi-thread switching, off-main-thread via Web Workers. Best for maximum model compatibility and CPU fallback paths. [utsubo](https://www.utsubo.com/blog/webgpu-threejs-migration-guide)

**MediaPipe Tasks GenAI** (`@mediapipe/tasks-genai`) is Google's option if you're targeting Gemma 3/3n models specifically. [webllm.mlc](https://webllm.mlc.ai)

## GPU/Graphics Rendering

**Three.js r171+** (Sept 2025) is production-ready WebGPU via zero-config `WebGPURenderer`, with automatic WebGL 2 fallback and TSL — a JS-based shader language that compiles to both WGSL and GLSL so you maintain one codebase. [github](https://github.com/mlc-ai/web-llm)

**Babylon.js** is the power move if you need GPGPU compute shaders *alongside* rendering — storage buffers, atomic ops, and hybrid simulation pipelines are first-class. [reddit](https://www.reddit.com/r/LocalLLaMA/comments/1qyemhf/running_llms_inbrowser_via_webgpu_transformersjs/)

**ONNX Runtime Web** is the underlying engine behind Transformers.js, and worth using directly if you have custom ONNX models or need Stable Diffusion-class image pipelines (1s/image on RTX 4090). [reddit](https://www.reddit.com/r/javascript/comments/1s7r9qh/huggingface_has_just_released_transformerjs_v4/)

## Key Context

WebGPU now ships by default in Chrome, Firefox, Edge, and Safari (since Nov 2025) — you can realistically target it for all users. WebNN (NPU access) is still origin-trial/preview in Chrome/Edge and not yet production-deployable. Always run inference in a Web Worker to avoid blocking the UI. [explore.n1n](https://explore.n1n.ai/blog/transformers-js-v4-preview-npm-release-2026-02-10)

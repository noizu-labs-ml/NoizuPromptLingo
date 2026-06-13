# How Modal (modal.com) Works as a Cloud GPU Service

## TL;DR
- **Modal is a Python-native serverless platform where you define your container image, hardware (including GPUs), and scaling entirely in code via decorators — no Dockerfiles, YAML, or Kubernetes required — and Modal builds the image, provisions a GPU from one of 13 cloud providers, runs your function, and bills you per second.** You get a GPU by adding one argument: `@app.function(gpu="H100")`.
- **There is no "image upload" in the Docker sense.** You describe an image in Python (`modal.Image.debian_slim().pip_install("torch")`), Modal builds it in the cloud on a custom Rust-based runtime, and serves it lazily through a content-addressed distributed filesystem so containers boot in roughly one second instead of pulling multi-GB images.
- **The core concepts are App (the deployable unit/namespace), Function (a decorated autoscaling unit of compute), Cls (a class with lifecycle hooks like `@modal.enter` for loading model weights once), Image (the container environment as code), Volume (persistent distributed storage for weights/data), and Secret (env-var credentials).** Pricing is pure pay-per-second with scale-to-zero; H100 GPU time is $0.001097/sec (~$3.95/hr) and every account gets $30/month free.

## Key Findings

**Modal inverts the normal cloud workflow.** Instead of writing a Dockerfile, building an image, pushing it to a registry, provisioning a VM/cluster, and deploying, you write plain Python, decorate functions with `@app.function()`, and run `modal run` or `modal deploy`. Modal's founding internal benchmark for failure is telling: "if a developer ever needs to edit YAML or write a Dockerfile, something has gone wrong." Founder Erik Bernhardsson has stated there is "no configuration in Modal — everything is in code."

**You get GPU access by passing a single `gpu=` argument.** `@app.function(gpu="H100")` attaches an H100; the NVIDIA kernel driver (580.95.05) and CUDA Driver API (13.0) plus `nvidia-smi` are preinstalled on every GPU machine, so `pip_install("torch")` is enough to get a working CUDA stack. You can request multiples (`gpu="H100:8"`), pick from T4/L4/A10/L40S/A100/H100/H200/B200 (plus RTX PRO 6000), and Modal abstracts away which underlying cloud (AWS, GCP, OCI, etc.) the GPU comes from.

**Images are built in the cloud and served lazily, not "uploaded."** Modal built its own container runtime in Rust, its own image builder, and two custom filesystems. Images are stored content-addressed; only the bytes a container actually reads are fetched, and files shared between images (sometimes >50% overlap) are cached across a memory/SSD/object-storage tier. This is why containers boot in ~1 second.

**Pricing is per-second with scale-to-zero and no idle charges.** When a Function has no inputs, no containers run and you are not billed, even if the App is deployed.

## Details

### The local-to-GPU workflow

1. **Install and authenticate.** `pip install modal`, then `modal setup` (writes an API token to `~/.modal.toml`, or set `MODAL_TOKEN_ID`/`MODAL_TOKEN_SECRET`). You never set up any infrastructure, AWS account, or cluster.

2. **Write a Python file** defining an `App`, an `Image`, and one or more decorated Functions:
```python
import modal
app = modal.App("example")
image = modal.Image.debian_slim().pip_install("torch")

@app.function(gpu="H100", image=image)
def run():
    import torch
    assert torch.cuda.is_available()
```

3. **Iterate with `modal run`.** This creates an *ephemeral App* that exists only for the duration of the script and is torn down on exit (unless you pass `--detach`). It runs your `@app.local_entrypoint()` locally, which calls `.remote()` to execute functions in the cloud. `modal serve` gives you a hot-reloading temporary web endpoint for development.

4. **Ship with `modal deploy`.** This creates a *deployed App* that persists indefinitely (until you `modal app stop` it). Deployed functions are persistent and reused (faster calls), keep running when you close your laptop, can be scheduled with cron, and get stable web URLs. Re-deploying with the same name updates in place using a rolling strategy by default (old containers keep serving until new ones are warm).

5. **Invoke.** `.remote()` runs remotely; `.local()` runs in the caller's context; `.map()` fans out across many parallel containers; `.spawn()` fires off without waiting and returns a `FunctionCall` handle. Deployed functions can be called from other Python code via `modal.Function.from_name("app", "fn")`, or over HTTP/from other languages.

### Key concepts

- **App** — the top-level object that groups Functions and Classes for atomic deployment and acts as a shared namespace. Apps are ephemeral (`modal run`) or deployed (`modal deploy`). *Historical note:* the `App` class was previously called `Stub`; `modal.Stub` was kept as an alias but, from Modal 1.0.0 (May 2025) onward, referencing `modal.Stub` raises an error. Much older tutorials still use `stub = modal.Stub(...)`.

- **Function** — a Python function decorated with `@app.function()`, the basic unit of serverless compute. Each Function maps to its own autoscaling pool of containers and scales independently. Decorator arguments configure everything: `image`, `gpu`, `cpu`, `memory`, `volumes`, `secrets`, `timeout`, `schedule`, `min_containers`, `max_containers`, `region`, `cloud`, and retries.

- **Cls (class)** — a class decorated with `@app.cls()` for stateful workloads with lifecycle hooks. `@modal.enter()` runs once on container startup — the canonical place to load model weights into GPU memory so you don't reload on every request. `@modal.method()` marks callable methods; `@modal.exit()` runs on shutdown. (The older `@modal.build()` hook for baking downloads into the image has been superseded by `Image.run_function`.)

- **Image** — the container filesystem defined as code. Start from `debian_slim()` (matches your local Python minor version), `from_registry()` (any public registry: Docker Hub, nvcr.io, ECR, ghcr.io), or `from_dockerfile()` (Modal reimplements the Dockerfile spec; a few directives like `VOLUME`, `ONBUILD`, `STOPSIGNAL` aren't supported). Chain builder methods: `.pip_install()`, `.uv_pip_install()`, `.apt_install()`, `.run_commands()`, `.run_function()`, `.env()`. Each step is a cached layer; changing a step invalidates downstream layers (like Docker). `MODAL_FORCE_BUILD=1` rebuilds everything; `MODAL_IGNORE_CACHE=1` rebuilds without poisoning the cache. A workspace-level "Image Builder Version" controls base-image updates so they don't trigger surprise rebuilds.

- **Local code and files.** `add_local_dir`/`add_local_file` and `add_local_python_source` bring local files/modules into the container. By default (`copy=False`) these are mounted at container *startup* (fast iteration, but no further build steps can run after); `copy=True` bakes them into an image layer at build time. **Footgun:** since Modal 1.0, you must explicitly include local Python modules via `add_local_python_source` — `modal run` may work without it while `modal deploy` fails at runtime with a missing-module error.

- **Volume** — `modal.Volume`, a distributed filesystem ("VolumeFS," built on a content-addressed store) that appears as a local directory and persists across runs and across regions. Optimized for write-once/read-many (model weights, datasets, checkpoints). Mount with `@app.function(volumes={"/models": vol})`. Writes require `vol.commit()` to persist; Volumes are eventually consistent. Recommended over baking weights into the image or using cloud bucket mounts. Storage is billed at $0.09/GiB/month with 1 TiB/month free.

- **Secret** — `modal.Secret`, encrypted credentials injected as environment variables. Create on the dashboard (templates for Postgres, HuggingFace, AWS, W&B, etc.), via CLI (`modal secret create`), or programmatically (`Secret.from_dict`, `Secret.from_dotenv`). Attach with `@app.function(secrets=[modal.Secret.from_name("my-secret")])` and read via `os.environ`.

- **Sandbox** — `modal.Sandbox`, a lower-level primitive for spinning up secure, isolated containers (their own filesystem, resources, lifecycle) programmatically — built for running untrusted/AI-generated code. Per Modal's Series C announcement (May 21, 2026), "Over 1 billion sandboxes have been launched on Modal" and "Sandboxes already drive more than a third of our revenue." Mistral's Le Chat code interpreter runs on them.

- **Other storage/coordination primitives:** `modal.Dict` (distributed key-value store), `modal.Queue` (distributed queue), and `CloudBucketMount` (mount S3/GCS/R2 buckets directly).

### GPUs, CUDA, and the container runtime

Modal runs containers on the sandboxed gVisor runtime, pointing it at a root filesystem served over the network via a FUSE content-addressed filesystem, so it never has to "pull" an image. The kernel-mode NVIDIA driver and the user-mode CUDA Driver API (`libcuda.so`, `nvidia-smi`) are preinstalled (driver 580.95.05, CUDA 13.0). The CUDA *Toolkit* (compiler `nvcc`, runtime `libcudart.so`) is *not* installed by default, but libraries like `torch` bundle their own CUDA deps, so a plain `pip_install("torch")` works. For bleeding-edge libraries (e.g. `flash-attn`, TensorRT-LLM) you start from an `nvidia/cuda:*-devel-*` image.

GPU options and notes (per Modal docs): T4, L4, A10, L40S, A100 (40/80GB), H100 (all SXM), H200, B200, plus RTX PRO 6000. Use `gpu="H100:8"` for up to 8 GPUs on one machine (B200/H200/H100/A100/L4/T4/L40S support up to 8, A10 up to 4). L40S is Modal's recommended default for inference (good cost/performance, 48GB). H100 may be auto-upgraded to H200; `gpu="B200+"` lets Modal pick B200 or B300 (billed as B200).

### Scaling, cold starts, and performance

Every Function is an autoscaling container pool. By default each container handles one input at a time and the pool scales to zero when idle. Key knobs on the decorator: `max_containers` (cap), `min_containers` (keep N warm to avoid cold starts), `buffer_containers` (idle headroom while active), and `scaledown_window` (how long idle containers linger, default 60s, max 20 min). `@modal.concurrent(max_inputs=...)` lets one container process many inputs at once (ideal for I/O-bound work or vLLM continuous batching). `.map()` fans a function out over many inputs across containers in parallel (inputs are chunked ~49 per request). New accounts have a rate limit of 200 function calls/HTTP requests per second.

Containers boot in ~1 second, but a container isn't "warm" until global-scope code and `@modal.enter` methods finish (e.g. importing torch's 20,000+ files, loading weights, JIT compilation). To cut this, Modal offers **Memory Snapshots** (introduced January 2025): it snapshots CPU memory after warm-up and restores it on future boots, typically 3–10x faster startup. **GPU Memory Snapshots** (alpha) also capture GPU/CUDA state via the driver's checkpoint/restore API; Modal reports cold-start improvements such as vLLM Qwen2.5-0.5B from 45s to 5s and NeMo Parakeet from 20s to 2s, and frames its headline "improve cold starts by 100x with GPU snapshotting... scaling from 0 to 1,000 GPUs in minutes (or even seconds)." Caveat: snapshots help with init/compilation work, not weight-loading bottlenecked by storage bandwidth, and multi-GPU snapshotting has known issues.

### Web endpoints

Any function becomes an HTTPS API by adding `@modal.fastapi_endpoint()` (single function, wraps it in FastAPI with CORS), `@modal.asgi_app()` (full FastAPI/ASGI app), `@modal.wsgi_app()` (Flask/WSGI), or `@modal.web_server()` (anything listening on a port). Deployed endpoints get URLs like `https://<workspace>--<label>.modal.run`; ephemeral (`modal serve`) endpoints get a `-dev` suffix. Custom domains and auto-renewed TLS are supported. Protect endpoints with proxy auth tokens (`Modal-Key`/`Modal-Secret` headers) or standard bearer-token validation.

### Pricing (verified against modal.com/pricing, June 2026)

Pure pay-per-second, billed per CPU cycle with no idle charges, no egress fees, no API-call charges. Per-second GPU list rates:

| GPU | $/sec | ≈ $/hr |
|---|---|---|
| B200 | $0.001736 | ~$6.25 |
| H200 | $0.001261 | ~$4.54 |
| H100 (SXM) | $0.001097 | ~$3.95 |
| RTX PRO 6000 | $0.000842 | ~$3.03 |
| A100 80GB | $0.000694 | ~$2.50 |
| A100 40GB | $0.000583 | ~$2.10 |
| L40S | $0.000542 | ~$1.95 |
| A10 | $0.000306 | ~$1.10 |
| L4 | $0.000222 | ~$0.80 |
| T4 | $0.000164 | ~$0.59 |

Plus CPU at $0.0000131/core/sec (min 0.125 cores) and memory at $0.00000222/GiB/sec for standard Functions. **Sandboxes/Notebooks compute is priced higher**: CPU $0.00003942/core/sec and memory $0.00000672/GiB/sec. Disk requests bill by raising the memory request at a 20:1 ratio.

**Multipliers (verify before budgeting):** Modal's pricing page lists **region selection at 1.5–1.75x** base prices and **non-preemptible execution at 3x** base prices. Per the preemption docs, the **3x non-preemptible multiplier applies to CPU and Memory only, and the `nonpreemptible` parameter is *not* supported for GPU Functions** — so the often-cited "3x production multiplier on GPUs" is not applicable via that parameter. GPU Sandboxes are subject to preemption while CPU Sandboxes are not. Note that some third-party sites cite an H100 at ~$0.002778/sec (~$4.50–4.76/hr); this does **not** match Modal's current official list price of $0.001097/sec and appears outdated or conflated with multiplied/sandbox rates.

**Plans:** Starter ($0/mo, $30/mo free credits, 3 seats, 100 containers, 10 concurrent GPUs); Team ($250/mo, $100/mo credits, unlimited seats, 1,000 containers, 50 concurrent GPUs); Enterprise (custom, SSO/HIPAA/audit logs). Startup and academic (up to $10k) credits available; can transact via AWS/GCP marketplace.

### Company context

Modal Labs was founded in 2021 by Erik Bernhardsson (ex-Spotify; creator of the Luigi workflow tool and the Annoy nearest-neighbor library) and Akshat Bubna — both International Olympiad in Informatics gold medalists (Bernhardsson, Sweden 2003; Bubna, India 2014). It is headquartered in New York with offices in San Francisco and Stockholm and a 120+ person team. Per Modal's own announcement (May 21, 2026): "We've raised $355 million... Our valuation is $4.65B post-money in a round led by General Catalyst and Redpoint, with Menlo, Bain Capital Ventures, and Accel joining as new investors." Reuters/Dealroom reporting notes the round closed in two tranches — an earlier tranche priced at a $2.5B valuation before the larger $4.65B tranche — up from the ~$1.1B Series B (led by Lux Capital) in September 2025. The company describes "growing fivefold since September, surpassing $300 million in annualized revenue" (up from ~$60M in September 2025); CEO Erik Bernhardsson told Reuters, "Coding for the last six months has been driving everything." It now routes workloads across 13 cloud providers (up from 5 a year earlier) and serves 10,000+ teams. The asset-light model (brokering third-party GPU capacity rather than owning it) means Modal's own supply is exposed to the same GPU scarcity its customers face.

## Recommendations

1. **Start here (first hour):** `pip install modal`, `modal setup`, then copy the hello-world or LLM-inference example and run `modal run file.py`. Use the $30/month free credits to validate your workload on a cheap GPU (T4 or L4) before scaling up.
2. **For model serving:** Use a `@app.cls()` with `@modal.enter()` to load weights once, store weights in a `modal.Volume` (not baked into the image, not re-downloaded per request), pick **L40S** as a cost-effective default, and only move to H100/H200/B200 once you've confirmed the GPU is your bottleneck. Expose it via `@modal.fastapi_endpoint()` or `@modal.asgi_app()`.
3. **To control cost:** Rely on scale-to-zero for bursty/spiky traffic (where Modal beats always-on instances). Set `scaledown_window` and `min_containers` deliberately — `min_containers>0` eliminates cold starts but you pay for idle GPU reservation. For sustained 24/7 high-utilization inference, model the per-second cost against a reserved instance elsewhere; Modal's premium per-second rates favor variable demand, not constant load.
4. **To cut cold starts:** Move init work into `@modal.enter`/global scope, load large files concurrently, download weights at build time (`Image.run_function`) or to a Volume, and evaluate Memory Snapshots for import/JIT-heavy startups.
5. **For production hygiene:** Pin dependency versions in your Image (especially with `uv_pip_install`) to avoid surprise rebuilds, explicitly `add_local_python_source` your modules so `modal deploy` matches `modal run`, store all credentials as `modal.Secret`, and wire `modal deploy` into CI/CD via GitHub Actions using `MODAL_TOKEN_ID`/`MODAL_TOKEN_SECRET`.

**Thresholds that change the recommendation:** If your workload is steady-state 24/7 at high GPU utilization, a reserved/owned GPU or a cheaper DIY provider (e.g. RunPod community/spot) likely wins on raw cost. If you primarily need a turnkey generation API rather than custom infrastructure, a per-generation API (Replicate, fal, WaveSpeed) avoids the engineering you must do yourself on Modal. If you require strictly non-preemptible GPUs with guaranteed execution, confirm current availability with Modal directly, since `nonpreemptible` does not apply to GPU Functions.

## Caveats

- **Pricing changes and multipliers:** Always re-check modal.com/pricing before budgeting. The region (1.5–1.75x) and non-preemptible (3x, CPU/memory only) multipliers materially change costs, and third-party pricing pages are frequently stale or conflate sandbox/multiplied rates with base GPU rates.
- **You build the serving stack yourself.** Modal provides compute and primitives, not pre-built model endpoints; you write the vLLM/serving code, handle model loading, and manage the pipeline. Reviewers note Modal is "cheap-but-DIY" relative to managed inference APIs.
- **Cold starts remain a real constraint** for latency-sensitive interactive workloads despite ~1s container boots; the mitigations (warm pools, snapshots) trade cost for latency.
- **GPU Memory Snapshots are alpha**, with documented limitations (multi-GPU issues, weight-loading not accelerated, some torch.compile failures) and require code adjustments.
- **Feature maturity varies:** several capabilities (multi-node clusters, VM/Docker-in-Sandbox, proxies, dynamic batching, GPU memory snapshots) are explicitly Beta/Alpha.
- **Source quality:** Architecture, workflow, concepts, and pricing here are drawn from Modal's official docs and pricing page; financials from Reuters/company announcements. Some performance numbers (e.g. snapshot speedups, "100x" cold-start claims) come from Modal's own blog/marketing and should be read as vendor-reported.

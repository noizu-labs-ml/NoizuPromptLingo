# RobotAudio — virtual microphone devices

queue-populator can route your live microphone into four **virtual microphone
devices**: `Recording`, `Claude`, `Codex`, and `Llama`. `Recording` is always fed
while queue-populator is listening. Other apps (a browser, an LLM voice client,
Zoom, OBS, ...) can then select e.g. "Claude" as their input and receive your
voice, but only while that assistant device is *open*.

## Why a driver is required

On macOS a normal app cannot create a device that appears as a microphone to
other apps. That capability only exists for a **CoreAudio AudioServerPlugIn** (a
"HAL driver") installed in `/Library/Audio/Plug-Ins/HAL/` and loaded by
`coreaudiod`. This is the same mechanism BlackHole, Loopback, and VB-Cable use.

So the feature has two halves:

1. **The driver** (this folder) — vends the four loopback devices.
2. **The app** — captures your real mic, always renders it into `Recording`,
   and renders it into whichever assistant device is open; writes nothing to the
   closed assistant devices, so they stay silent (muted).

## How the four devices are built

`build-virtual-mics.sh` builds the drivers by **customizing
[BlackHole](https://github.com/ExistentialAudio/BlackHole) (MIT)** — four times,
once per device, each with a unique name, bundle id, and UID.

### Why BlackHole rather than a hand-written driver

The brief left the driver choice to me. The realistic options were:

| Option | Pros | Cons |
| --- | --- | --- |
| **Rebrand BlackHole** (chosen) | Proven, zero-latency loopback that is *exactly* a minimal HAL driver; battle-tested across thousands of installs; supports per-instance customization | Pulls an external MIT repo at build time; needs Xcode |
| Hand-rolled minimal HAL driver | Fully self-contained, exact names/UIDs | ~1k lines of unforgiving CoreAudio plug-in C that **could not be tested in the environment it was written in**; a faulty HAL driver can wedge `coreaudiod` system-wide |

BlackHole *is* the minimal HAL loopback driver this feature needs, so rebranding
it satisfies the "minimal HAL" intent while being the responsible, low-risk
choice. If you'd rather ship a bespoke driver later, the app side doesn't care:
it matches devices by name (`Recording`/`Claude`/`Codex`/`Llama`), so any driver
that vends those names works.

## Build & install

```bash
cd Driver
./build-virtual-mics.sh          # builds all four and installs them
./build-virtual-mics.sh --no-install   # build only, bundles land in ./build
```

Requirements: the full **Xcode** app (not just Command Line Tools) and your admin
password for the install step. The script:

1. clones BlackHole (pinned to `BLACKHOLE_REF`, default `v0.6.1`),
2. builds `Recording` / `Claude` / `Codex` / `Llama` with unique bundle ids + UIDs,
3. ad-hoc code-signs each `.driver`,
4. copies them to `/Library/Audio/Plug-Ins/HAL/`,
5. restarts CoreAudio (`sudo killall -9 coreaudiod`).

Override defaults with env vars, e.g. `CHANNELS=1 BLACKHOLE_REF=v0.6.0 ./build-virtual-mics.sh`.

### Verify

After install, open **Audio MIDI Setup** (or run `system_profiler SPAudioDataType`)
and confirm `Recording`, `Claude`, `Codex`, and `Llama` appear. `Recording`
receives audio while queue-populator is listening; the assistant devices are
silent until queue-populator routes audio into one.

## Uninstall

```bash
./uninstall-virtual-mics.sh
```

## Notes & caveats

- **Signing/Gatekeeper:** the drivers are ad-hoc signed (`-`), which is fine for
  local use. For distribution to other machines you'd sign with a Developer ID
  and notarize.
- **Shared mic:** while a virtual mic is open, queue-populator is still listening
  on the same physical mic, so it can still hear its own wake phrase. Say
  `robot close <name>` to stop routing.
- **Assistant routing:** opening one assistant device automatically mutes the
  other assistant devices. `Recording` remains active while the app is listening.

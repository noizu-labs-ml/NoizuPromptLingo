# Echo of Manifestation — Tech Stack

Platform specifications and technical requirements.

## Engine

Unreal Engine 5.4 (Nanite + Lumen for twilight volumetrics and shadow rendering)

## Platform Specifications

| Spec | PC Minimum | PC Recommended | PlayStation 5 | Xbox Series X | Nintendo Switch |
|------|-----------|---------------|--------------|--------------|-----------------|
| **OS** | Windows 10 64-bit / macOS 12+ / Linux (Proton) | Windows 11 64-bit | PS5 system software | Xbox OS | Switch OS |
| **CPU** | Intel i5-8400 / AMD Ryzen 5 2600 | Intel i7-10700 / AMD Ryzen 7 3700X | Custom AMD Zen 2 | Custom AMD Zen 2 | Custom NVIDIA Tegra |
| **RAM** | 16 GB | 32 GB | 16 GB GDDR6 | 16 GB GDDR6 | 4 GB |
| **GPU** | GTX 1660 / RX 570 | RTX 3060 / RX 6700 XT | Custom RDNA 2 | Custom RDNA 2 | Integrated |
| **Storage** | 25 GB SSD | 25 GB NVMe SSD | 25 GB SSD | 25 GB SSD | 20 GB |
| **Target Resolution** | 1080p / 30 FPS | 1440p / 60 FPS | 4K/30 or 1440p/60 | 4K/30 or 1440p/60 | 720p handheld / 1080p docked / 30 FPS |

## Audio Middleware

Wwise — all sounds triggered via Wwise events, adaptive music state machine (Explore -> Alert -> Combat -> Boss -> Death), RTPC controllers for Resonance/HP/Zone Depth/Combat Proximity.

## Key Technical Decisions

- **Procedural generation**: Template-based with validated connection graphs. Each room template has entry/exit sockets that only connect to compatible sockets.
- **Chimera AI**: Modular behavior trees. Base behavior (patrol, aggro, combat) + echo-specific module plug-in architecture.
- **Scalability**: Low uses baked lighting + traditional LOD. Lumen/Nanite only on Medium+. Switch uses custom lightweight shadow shader pipeline.
- **Cloud saves**: Steam Cloud, PlayStation Plus, Xbox Live. Local backup on PC. Corruption recovery from last 3 saves.

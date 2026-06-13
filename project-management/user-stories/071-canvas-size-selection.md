# US-071: Canvas Size Selection at Project Creation

**As a** plein air sketcher,
**I want to** choose a canvas size (in pixels or physical dimensions) when creating a new project,
**So that** my output matches my intended medium — sketchbook proportion, print size, or screen format.

## Personas
- **Primary:** P7 Priya Sharma — works to specific sketchbook proportions; wrong canvas size wastes session time
- **Also relevant:** P4 James Whitfield, P5 Suki Tanaka

## Acceptance Criteria
- [ ] New project dialog provides size presets: common pixel sizes (1024×768, 2048×1536, 4096×3072) and physical sizes (A5, A4, Letter) at selectable DPI
- [ ] User can enter arbitrary width and height in pixels
- [ ] Canvas size determines the GPU buffer allocation: layer-major buffer = width × height × 8 layers × 32 B
- [ ] A memory estimate (MB/GB) is shown before creation so the user understands the resource cost
- [ ] Canvas size cannot be changed after project creation in v1; the dialog makes this limitation explicit

## Notes
Buffer allocation size scales linearly with pixel count and quadratically with dimension. At 4096×3072 × 8 layers × 32 B the buffer is ~3.2 GB; the dialog should warn if this approaches or exceeds available GPU memory reported by MTLDevice.

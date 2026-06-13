# US-020: GPU Memory Usage Indicator

**As a** technical artist developing shaders on a machine with limited GPU memory,
**I want to** see a live GPU memory usage indicator in the application,
**So that** I can monitor memory pressure as I work with large canvases and multiple textures and avoid out-of-memory crashes.

## Personas
- **Primary:** Alex Kirchner — shader development and large texture experimentation can push GPU memory hard; a live indicator lets him make informed decisions about canvas size and layer count
- **Also relevant:** Lena Vasquez, David Okafor

## Acceptance Criteria
- [ ] A GPU memory badge showing current usage / total available (e.g., "1.4 GB / 8 GB") is displayed in the status bar or debug HUD
- [ ] Memory usage is polled from `MTLDevice.currentAllocatedSize` and `MTLDevice.recommendedMaxWorkingSetSize` at a maximum of 4 Hz to avoid polling overhead
- [ ] The badge color changes at thresholds: green (< 60%), amber (60–85%), red (> 85%)
- [ ] A warning dialog is shown when allocated memory crosses 90% of `recommendedMaxWorkingSetSize`, advising the user to reduce canvas size or close other GPU-intensive apps
- [ ] The indicator is only visible when Debug HUD is enabled (View > Debug HUD) in production builds; it is always visible in debug builds
- [ ] Memory usage is broken down in a tooltip: VolumeLayer textures, compositor textures, other

## Notes
`MTLDevice.currentAllocatedSize` reflects all Metal allocations for the process. The tooltip breakdown requires tracking allocation sizes manually via a central Metal resource allocator class rather than querying them from the device. The 4 Hz poll rate is a deliberate cap to ensure the polling itself does not appear in profiling as a performance hotspot.

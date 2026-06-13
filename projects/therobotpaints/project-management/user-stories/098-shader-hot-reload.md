# US-098: Shader Hot-Reload for Development Iteration

**As a** technical artist iterating on custom Metal shaders,
**I want to** reload shader source files without restarting the application,
**So that** I can see the effect of shader changes on the live simulation in seconds rather than minutes.

## Personas
- **Primary:** P6 Alex Kirchner — shader iteration is the core development loop; compile-restart cycles destroy momentum and make parameter tuning impractical
- **Also relevant:** P4 James Whitfield

## Acceptance Criteria
- [ ] A designated shader source directory (configurable in Preferences > Developer) is watched for file changes using `DispatchSource.makeFileSystemObjectSource`
- [ ] On detecting a `.metal` file change, the app recompiles the affected pipeline via `MTLDevice.makeLibrary(source:options:)` asynchronously
- [ ] Successful recompile hot-swaps the pipeline; the canvas updates on the next render tick with no visible interruption beyond a brief frame stutter
- [ ] Compilation errors are displayed in a floating "Shader Log" panel with file, line, and error message; the previous pipeline remains active
- [ ] A "Force Reload Shaders" menu item and keyboard shortcut (Ctrl+Shift+R) triggers manual reload without a file change
- [ ] Hot-reload is disabled in release builds; it only activates when a developer shader directory is configured

## Notes
Shaders currently live as Swift string literals in the codebase — this story implies migrating them to `.metal` source files under `Resources/Shaders/`. The `MetalEngine` singleton must be refactored to support pipeline replacement without tearing down GPU state. This is a significant architectural prerequisite.

# Export Controls

| Field | Value |
|-------|-------|
| **ID** | `export-controls` |
| **Category** | Input & Forms |
| **Used In** | 01-Fighter Studio, 02-Battle Replay Viewer, 04-Training Gym, 07-Laboratory, 03-Post-Battle Screen |

## Description

Unified export interface for various data types (graph JSON, SVG, PNG, MP4, CSV, Parquet). Supports format selection, resolution options, background selection, and export queue status.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Single export button with format pre-selected by context |
| **Expanded** | Full panel with format selector, resolution options, background picker, and queue status |

## Props / Configuration

- `formats` — List of available export formats for the current context
- `resolution` — Resolution multiplier for image exports (1x, 2x, 4x)
- `background` — Background option: `transparent`, `solid`, or `themed`
- `includeOverlay` — Whether to composite active overlays into video exports
- `estimatedSize` — Projected file size shown before initiating export

## Interactions

- Select target export format from available options
- Configure resolution multiplier and background style
- Toggle overlay inclusion for video exports
- Initiate export and monitor queue progress
- Download completed export file

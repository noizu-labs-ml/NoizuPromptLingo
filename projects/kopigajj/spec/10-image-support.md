# 10. Image Support

## Image Processing Pipeline

```mermaid
graph TB
    subgraph "Image Ingest"
        COPY[Image Copied<br/>PNG/JPEG/TIFF/GIF/SVG] --> STORE[Store to<br/>File System]
        COPY --> THUMB[Generate<br/>Thumbnail]
        COPY --> OCR[OCR Engine<br/>Extract Text]
        COPY --> CLIP_EMB[CLIP Embedding<br/>Visual Vector]
        COPY --> META_EX[Extract Metadata<br/>dimensions, size]
    end

    OCR --> FTS[FTS5 Index<br/>searchable text]
    CLIP_EMB --> VEC[Vector Index<br/>visual similarity]

    subgraph "Image + LLM Generation"
        T2I[Text-to-Image<br/>Macro vars → prompt → generate]
        I2I[Image-to-Image<br/>Wrapper captures image →<br/>diffusion transform → paste]
        TI2I[Text+Image-to-Image<br/>Selected text + reference image →<br/>generate combined]
    end

    subgraph "Output"
        PREVIEW[Full-size Preview<br/>on hover / Space key]
        PASTE_IMG[Paste Image<br/>to target app]
        PASTE_GEN[Paste Generated<br/>Image]
    end

    T2I --> PASTE_GEN
    I2I --> PASTE_GEN
    TI2I --> PASTE_GEN
```

## Capabilities

- Copy/paste images (PNG, JPEG, TIFF, GIF, SVG) — full first-class support.
- Thumbnail previews in the history panel.
- Full-size preview on hover or `Space` key.
- Image metadata stored: dimensions, file size, source app.
- OCR on image content for searchability (text extracted and indexed).
- Semantic embedding of images for visual similarity search.

## Image Generation Macro Example

```plantuml
@startsalt
{
  {+ 
    **MACRO: banner — Blog Header Image**
    --
    "Model:" | ^DALL-E 3^
    --
    "title:" | "Building with Weaviate" | "Blog post title"
    "style:" | ^watercolor^ | "Visual style"
    --
    ── Preview (generating...) ──
    { SI
      [Generating image...]
      Prompt: "Create a minimal blog header image
      for a post titled 'Building with Weaviate'
      in the style of watercolor"
    }
    --
    [Cancel] | | [⌘⇧T+Space: Paste Image]
  }
}
@endsalt
```

#### Asset: Image Generation Macro

![Create Macro Form](style-guide/create-macro-form.png)

---

[← Smart Formatting & Paste Modes](09-smart-formatting-paste-modes.md) | [Table of Contents](../product-spec.md#table-of-contents) | [Menu Bar Interface →](11-menu-bar-interface.md)

**Solution Analysis:** [Clipboard Types](solution-analysis/05-clipboard-types.md)
**User Stories:** [US-014](user-stories/US-014.md) · [US-015](user-stories/US-015.md) · [US-016](user-stories/US-016.md)

<!-- nav -->

---

[< Previous: 7. LLM Snippet Library (`⌘⇧T L`)](07-llm-snippet-library.md) | [Table of Contents](../product-spec.md) | [Next: 14. Technical Architecture Notes >](14-technical-architecture.md)

<!-- nav -->

# 9. Smart Formatting & Paste Modes

When pasting, hold modifier keys or use a submenu to control formatting:

| Action | Result |
|---|---|
| `⌘⇧T Space` | Paste as-is (default) |
| `⌘⇧T Space` + `⌥` | Paste as plain text (strip formatting) |
| Hold `⌘⇧T Space` (long press) | Open paste format picker |

## Paste Format Transformation Pipeline

```mermaid
graph LR
    RAW[Raw Entry<br/>Content] --> DETECT{Content Type<br/>Detection}

    DETECT -->|text/plain| PT[Plain Text]
    DETECT -->|text/html| HTML[HTML]
    DETECT -->|text/rtf| RTF[Rich Text]
    DETECT -->|image/*| IMG[Image Data]
    DETECT -->|color value| CLR[Color Value]

    PT --> FMT{Paste Format<br/>Selection}
    HTML --> FMT
    RTF --> FMT
    IMG --> FMT
    CLR --> FMT

    FMT -->|as Plain Text| STRIP[Strip Formatting]
    FMT -->|as Markdown| MD[HTML→MD / RTF→MD]
    FMT -->|as HTML| H[Wrap/Convert to HTML]
    FMT -->|as Code Block| CB[Wrap in ``` block]
    FMT -->|as JSON| JSON[Escape & Format]
    FMT -->|as URL-encoded| URL[encodeURIComponent]
    FMT -->|as Base64| B64[Base64 Encode]
    FMT -->|as Image| RENDER[Render HTML→Image]
    FMT -->|Color Convert| CC[hex↔rgb↔hsl↔UIColor]
    FMT -->|Custom Transform| CUST[Regex / LLM / Script]

    STRIP --> PASTE[Paste to<br/>Target App]
    MD --> PASTE
    H --> PASTE
    CB --> PASTE
    JSON --> PASTE
    URL --> PASTE
    B64 --> PASTE
    RENDER --> PASTE
    CC --> PASTE
    CUST --> PASTE
```

## Paste Format Picker

```plantuml
@startsalt
{
  {+ 
    **Paste as...**
    --
    {
      ( ) Plain Text
      ( ) Markdown
      ( ) HTML
      ( ) Rich Text (RTF)
      ( ) Image (render HTML)
      ( ) Code Block
      ( ) JSON (escape)
      ( ) URL-encoded
      ( ) Base64
      ( ) Custom transform...
    }
  }
}
@endsalt
```

#### Asset: Paste Format Picker

![Paste Format Picker](style-guide/paste-format-picker.png)

## Color Support

- Color values detected in clipboard content (hex, RGB, HSL) show a color swatch preview.
- Paste-as options for colors: convert between hex, RGB, HSL, Swift UIColor, CSS variable.
- Color palette entries can be favorited and tagged for design system use.

---

[← Editing](08-editing.md) | [Table of Contents](../product-spec.md#table-of-contents) | [Image Support →](10-image-support.md)

**Mockups:** [Design Elements](style-guide/style-guide-elements.md)
**Solution Analysis:** [Clipboard Types](solution-analysis/05-clipboard-types.md)
**User Stories:** [US-014](user-stories/US-014.md) · [US-015](user-stories/US-015.md) · [US-016](user-stories/US-016.md) · [US-017](user-stories/US-017.md)

<!-- nav -->

---

[< Previous: 8. Editing](08-editing.md) | [Table of Contents](../product-spec.md) | [Next: 3. Favorites & Tagging >](03-favorites-tagging.md)

<!-- nav -->

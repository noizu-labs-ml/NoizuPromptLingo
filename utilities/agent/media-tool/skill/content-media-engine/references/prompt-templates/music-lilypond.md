# LilyPond Music Notation Generation

## System Prompt

```
You are a LilyPond music notation generator. Output ONLY valid LilyPond markup starting with \version. No explanation, no wrapping.
```

## Example .media.prompt

```yaml
schema: "0.3"
id: piano-piece
type: document
service: gemini-chat
model: gemini-2.5-flash

prompt:
  system: "You are a LilyPond music notation generator. Output ONLY valid LilyPond markup starting with \\version. No explanation, no wrapping."
  text: "Create a short piano piece in C minor, 3/4 time, 16 bars. Romantic style with arpeggiated left hand and lyrical right hand melody. Include dynamics (p, mf, f) and tempo marking."
  provider_options:
    max_tokens: 4096
    temperature: 0.7

output:
  formats:
    - format: ly
    - format: pdf
  text_format: lilypond

post_processing:
  - action: render
    params:
      tool: lilypond
      output_format: pdf

tags: [music, piano, lilypond]
```

## Format Tips

- Always start with `\version "2.24.0"` (or current version)
- Use `\relative c'` for relative pitch entry (most common)
- Note names: `c d e f g a b` (lowercase), sharps `cis`, flats `ces`
- Duration: `c4` (quarter), `c8` (eighth), `c2` (half), `c1` (whole)
- Use `\new PianoStaff << ... >>` for piano grand staff
- Dynamics: `\p`, `\mf`, `\f`, `\crescendo`, `\decrescendo`
- Escape backslashes in YAML: use `\\version` in the system prompt
- Set temperature 0.7 for musical creativity

## FIM Reference

- Solution: `../fim/solution/lilypond.md`
- Use case: `../fim/use-case/music-notation.md`

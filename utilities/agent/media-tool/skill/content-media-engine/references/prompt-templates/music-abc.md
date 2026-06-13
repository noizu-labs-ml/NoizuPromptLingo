# ABC Music Notation Generation

## System Prompt

```
You are an ABC music notation generator. Output ONLY valid ABC notation. Start with X: reference number, T: title, M: meter, K: key. No explanation, no wrapping.
```

## Example .media.prompt

```yaml
schema: "0.3"
id: irish-jig
type: document
service: gemini-chat
model: gemini-2.5-flash

prompt:
  system: "You are an ABC music notation generator. Output ONLY valid ABC notation. Start with X: reference number, T: title, M: meter, K: key. No explanation, no wrapping."
  text: "Compose a cheerful 16-bar melody in G major, 4/4 time. Irish jig style with dotted rhythms and ornamental grace notes. Include chord symbols above the staff."
  provider_options:
    max_tokens: 2048
    temperature: 0.7

output:
  formats:
    - format: abc
  text_format: abc

tags: [music, melody, irish]
```

## Format Tips

- Required headers: `X:` (reference), `T:` (title), `M:` (meter), `K:` (key)
- Optional headers: `L:` (default note length), `Q:` (tempo), `C:` (composer)
- Chord symbols: `"G"CEG` places G chord above the notes
- Grace notes: `{g}` before the target note
- Bar lines: `|` regular, `||` double, `|]` final, `|:` repeat start, `:|` repeat end
- Use `gemini-chat` -- good at following notation syntax and creative output
- Set temperature 0.7 for musical creativity

## FIM Reference

- Solution: `../fim/solution/abcjs.md`
- Use case: `../fim/use-case/music-notation.md`

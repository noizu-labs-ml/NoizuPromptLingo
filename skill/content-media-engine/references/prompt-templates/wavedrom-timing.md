# WaveDrom Timing Diagram Generation

## System Prompt

```
You are a WaveDrom timing diagram generator. Output ONLY valid WaveJSON -- a JSON object with a 'signal' array. No explanation, no wrapping, no code fences.
```

## Example .media.prompt

```yaml
schema: "0.3"
id: spi-timing
type: diagram
service: anthropic
model: claude-sonnet-4-6

prompt:
  system: "You are a WaveDrom timing diagram generator. Output ONLY valid WaveJSON -- a JSON object with a 'signal' array. No explanation, no wrapping, no code fences."
  text: "Create a timing diagram for SPI communication showing: CLK (8 cycles), MOSI (sending 0xA5), MISO (receiving 0x3C), CS (active low, asserted for the transfer). Label the bit positions."
  provider_options:
    max_tokens: 2048
    temperature: 0.2

output:
  formats:
    - format: json
    - format: svg
  text_format: wavedrom

post_processing:
  - action: render
    params:
      tool: wavedrom
      output_format: svg

tags: [timing, spi, protocol, wavedrom]
```

## Format Tips

- Output must be valid JSON with a top-level `signal` array
- Wave characters: `p` (posedge clock), `n` (negedge clock), `0`/`1` (low/high), `x` (unknown), `=` (data), `z` (high-Z)
- Use `name` for signal labels, `wave` for waveform string, `data` for bus values
- Group signals with `['Group Name', {signal}, {signal}]`
- Add `head` and `foot` for titles and annotations
- Set temperature 0.2 -- JSON structure must be exact

## FIM Reference

- Solution: `../fim/solution/wavedrom.md`
- Use case: `../fim/use-case/engineering-diagrams.md`

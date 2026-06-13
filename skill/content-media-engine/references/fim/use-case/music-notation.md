# Music Notation
Generate sheet music, tablature, chord charts, and musical scores using NPL-FIM.
[Documentation](https://lilypond.org/doc/v2.24/Documentation/notation/index.html)

## WWHW
**What:** Create musical notation in various formats (sheet music, tabs, chord charts)
**Why:** Convert musical ideas to readable notation for musicians and composers
**How:** Use LilyPond, ABC notation, or ASCII tab formats through NPL-FIM
**When:** Composing, transcribing, educational materials, or musical analysis

## When to Use
- Transcribing audio recordings to sheet music
- Creating educational musical exercises
- Generating chord progressions and lead sheets
- Converting between notation formats (standard to tablature)
- Creating custom musical examples for documentation

## Key Outputs
`lilypond`, `abc`, `musicxml`, `ascii-tab`, `chord-charts`

## Quick Example
```lilypond
\version "2.24.0"
{
  \clef treble
  \time 4/4
  c'4 d' e' f' |
  g'2 a' |
  b'4 c''2. |
}
```

## Extended Reference
- [LilyPond Learning Manual](https://lilypond.org/doc/v2.24/Documentation/learning/index.html)
- [ABC Notation Standard](https://abcnotation.com/wiki/abc:standard:v2.1)
- [MuseScore Documentation](https://musescore.org/en/handbook)
- [Guitar Tab ASCII Guide](https://www.guitarnoise.com/lessons/reading-guitar-tablature/)
- [MusicXML Format Specification](https://www.musicxml.com/)
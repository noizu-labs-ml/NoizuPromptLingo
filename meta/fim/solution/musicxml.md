# MusicXML

## Description
MusicXML is the industry-standard open format for exchanging digital sheet music.
- Official site: https://www.musicxml.com
- W3C standard for music notation interchange
- Supported by 250+ applications including Finale, Sibelius, MuseScore
- XML-based format with comprehensive notation coverage

## Structure Overview
```xml
<score-partwise>
  <part id="P1">
    <measure number="1">
      <note>
        <pitch>
          <step>C</step>
          <octave>4</octave>
        </pitch>
        <duration>4</duration>
        <type>quarter</type>
      </note>
    </measure>
  </part>
</score-partwise>
```

Key elements:
- `score-partwise`: Root container for score organized by parts
- `part`: Individual instrument or voice
- `measure`: Bar of music containing notes and rests
- `note`: Musical note with pitch, duration, articulations

## Example: Simple Melody
```xml
<measure number="1">
  <attributes>
    <divisions>4</divisions>
    <key><fifths>0</fifths></key>
    <time>
      <beats>4</beats>
      <beat-type>4</beat-type>
    </time>
  </attributes>
  <note>
    <pitch><step>C</step><octave>4</octave></pitch>
    <duration>4</duration>
    <type>quarter</type>
  </note>
</measure>
```

## Libraries
- **OSMD** (OpenSheetMusicDisplay): JavaScript renderer for MusicXML
- **music21**: Python toolkit for computer-aided musicology
- **xml2abc**: Conversion to ABC notation
- **musicxml-parser**: Various language implementations

## Strengths
- Universal support across notation software
- Complete notation representation
- Preserves layout and formatting
- Handles complex scores and parts
- W3C standardized format

## Limitations
- Verbose XML syntax
- Large file sizes for complex scores
- Complexity for simple use cases
- Requires parsing for manipulation

## Best For
- Music notation software interchange
- Digital sheet music distribution
- Music analysis and education
- Archival and preservation
- Cross-platform music sharing

## NPL-FIM Integration
```
npl-fim:music/notation format:musicxml {
  score: score-partwise
  parts: [instrument definitions]
  measures: [time-ordered bars]
  render: osmd | music21 | native
}
```
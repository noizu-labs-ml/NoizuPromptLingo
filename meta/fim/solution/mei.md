# MEI (Music Encoding Initiative)

## Overview
MEI is an XML-based format for encoding music notation with rich scholarly metadata. Designed for academic music research, digital critical editions, and musicological analysis.

**Official Site**: https://music-encoding.org
**Documentation**: https://music-encoding.org/guidelines/
**Schema**: https://github.com/music-encoding/music-encoding

## Basic Structure
```xml
<?xml version="1.0" encoding="UTF-8"?>
<mei xmlns="http://www.music-encoding.org/ns/mei">
  <meiHead>
    <fileDesc>
      <titleStmt><title>Work Title</title></titleStmt>
    </fileDesc>
  </meiHead>
  <music>
    <body>
      <mdiv>
        <score>
          <scoreDef>
            <staffGrp>
              <staffDef n="1" lines="5" clef.shape="G" clef.line="2"/>
            </staffGrp>
          </scoreDef>
          <section>
            <measure n="1">
              <staff n="1">
                <layer n="1">
                  <note pname="c" oct="4" dur="4"/>
                </layer>
              </staff>
            </measure>
          </section>
        </score>
      </mdiv>
    </body>
  </music>
</mei>
```

## Key Tools
- **Verovio**: Primary rendering engine (https://www.verovio.org)
- **mei-friend**: Web-based MEI editor
- **LibMEI**: C++ library for MEI manipulation
- **MEI Viewer**: Online visualization tool

## Strengths
- Comprehensive scholarly encoding (variants, editorial marks, annotations)
- Support for critical editions and apparatus
- Rich metadata capabilities (performers, sources, historical context)
- Semantic music encoding beyond visual notation
- Integration with TEI for text encoding

## Limitations
- Steep learning curve for complex features
- Limited mainstream software support
- Primarily academic focus limits commercial adoption
- Verbose XML syntax for simple scores

## Best For
- Digital humanities projects
- Critical music editions
- Musicological research databases
- Historical music archives
- Academic publishing platforms

## NPL-FIM Integration
```yaml
fim_type: music_notation
fim_format: mei_xml
capabilities: [notation, metadata, variants, analysis]
render_with: verovio
complexity: high
use_cases: [scholarly, archival, research]
```
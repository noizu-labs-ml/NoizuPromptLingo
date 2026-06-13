# FIM Library Cross-Reference Index

Maps each `text_format` supported by the media asset generation system to its corresponding FIM solution and use-case files in the bundled FIM library.

All paths are relative to this file's location (`skill/content-media-engine/references/`).

## Format-to-FIM Mapping

| text_format | Category | FIM Solution | FIM Use-Case | Default Extension |
|-------------|----------|-------------|--------------|-------------------|
| mermaid | diagram | `fim/solution/mermaid.md` | `fim/use-case/diagram-generation.md` | .mmd |
| plantuml | diagram | `fim/solution/plantuml.md` | `fim/use-case/diagram-generation.md` | .puml |
| graphviz | diagram | `fim/solution/graphviz.md` | `fim/use-case/diagram-generation.md` | .dot |
| drawio | diagram | `fim/solution/drawio-xml.md` | `fim/use-case/diagram-generation.md` | .drawio |
| svg | image | (multiple -- see design-systems use-case) | `fim/use-case/design-systems.md` | .svg |
| html | page | (inline CSS/JS -- see prototyping use-case) | `fim/use-case/prototyping.md` | .html |
| tsx | component | (React patterns -- see prototyping use-case) | `fim/use-case/prototyping.md` | .tsx |
| latex | document | `fim/solution/latex.md` | `fim/use-case/document-processing.md` | .tex |
| typst | document | `fim/solution/typst.md` | `fim/use-case/document-processing.md` | .typ |
| abc | music | `fim/solution/abcjs.md` | `fim/use-case/music-notation.md` | .abc |
| lilypond | music | `fim/solution/lilypond.md` | `fim/use-case/music-notation.md` | .ly |
| wavedrom | engineering | `fim/solution/wavedrom.md` | `fim/use-case/engineering-diagrams.md` | .json |
| katex | math | `fim/solution/katex.md` | `fim/use-case/mathematical-scientific.md` | .tex |

## Usage

When authoring a `.media.prompt` file for a given format, consult:

1. **FIM Solution** -- syntax reference, capabilities, and limitations of the format
2. **FIM Use-Case** -- patterns, best practices, and common configurations for the category
3. **Prompt Template** -- pre-built system prompt and example (see `prompt-templates/`)

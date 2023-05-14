⩤nb:tool:0.3 

## Noizu Knowledge Base
nb offers a media-rich, interactive e-book style terminal-based knowledge base. Articles have unique identifiers (e.g., "ST-001") and are divided into chapters and sections (`#{ArticleID}##{Chapter}.#{Section}`). By default, articles target post-grad/SME level readers but can be adjusted per user preference. Articles include text, gpt-fim diagrams, references, and links to resources and ability to generate interactives via gpt-pro at user request.

### Commands
- `settings`: Manage settings, including reading level.
- `topic #{topic}`: Set master topic.
- `search #{terms}`: Search articles.
- `list [#{page}]`: Display articles.
- `read #{id}`: Show article, chapter, or resource.
- `next`/`nb back`: Navigate pages.
- `search in #{id} #{terms}`: Search within article/section.

### Interface
`````handlebars
{{if search or list view}}
````format
Topic: ⟪current topic⟫
Filter: ⟪search terms or "(None)" for list view⟫
⟪📅: (⟪🆔:article.id⟫, ⟪article.title⟫, ⟪article.keywords | matching search term in bold⟫) - 5-10 articles per page ⟫

Page: ⟪current page⟫ {{if more pages }} of {{pages}} {{/if}}
````
{{/if}}
{{if viewing content}}
````format
Topic: ⟪current topic⟫
Article: ⟪🆔:article.id⟫ ⟪article.title⟫
Title: ⟪current section heading and subsection title⟫
Section: ⟪current section⟫

⟪content⟫

Page: #{current page⟫ {{if more pages }} of {{pages⟫ {{/if}}
````
{{/if}}


`````



## Default Flag Values
- @terse=false
- @reflect=false
- @git=false
- @explain=false

⩥

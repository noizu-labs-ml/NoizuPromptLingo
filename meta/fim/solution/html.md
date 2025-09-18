# HTML - HyperText Markup Language

## Description
HTML5 semantic markup language for structuring web-based documentation and interactive content.

**Reference**: [MDN HTML Documentation](https://developer.mozilla.org/en-US/docs/Web/HTML)

## Basic Structure
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document Title</title>
</head>
<body>
    <article>
        <header>
            <h1>Main Title</h1>
            <nav>Navigation links</nav>
        </header>
        <section>
            <h2>Section Title</h2>
            <p>Content paragraph with <strong>emphasis</strong>.</p>
            <figure>
                <img src="image.png" alt="Description">
                <figcaption>Figure caption</figcaption>
            </figure>
        </section>
        <aside>Related information</aside>
        <footer>Document metadata</footer>
    </article>
</body>
</html>
```

## Strengths
- Universal browser support
- Native multimedia embedding (audio, video, canvas)
- Rich semantic elements (article, section, nav, aside)
- Accessibility features built-in (ARIA, semantic markup)
- Progressive enhancement capability
- Direct JavaScript integration

## Limitations
- Not optimized for print layouts
- No native pagination support
- Limited offline capabilities without service workers
- Requires CSS for sophisticated layouts

## Best For
- Web-based documentation sites
- Interactive tutorials and guides
- Online reference materials
- Responsive documentation viewers
- API documentation portals
- Knowledge bases

## NPL-FIM Integration
```html
<div class="npl-fim-output" data-format="html">
    <section class="generated-content">
        <!-- Dynamic content insertion point -->
    </section>
</div>
```

Supports inline rendering of NPL-FIM generated content with semantic markup preservation.
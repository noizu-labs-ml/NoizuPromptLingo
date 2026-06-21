# Jekyll - FIM Solution Documentation

## Description
[Jekyll](https://jekyllrb.com) is a Ruby-based static site generator with built-in support for GitHub Pages. Created by GitHub co-founder Tom Preston-Werner, Jekyll transforms plain text into static websites and blogs using Markdown, Liquid templates, and YAML front matter.

## Installation
```bash
# Install Ruby and Bundler
gem install bundler jekyll

# Create new site
jekyll new my-site
cd my-site

# Serve locally
bundle exec jekyll serve
```

## Basic Site Structure
```
├── _config.yml      # Site configuration
├── _posts/          # Blog posts (YYYY-MM-DD-title.md)
├── _layouts/        # Page templates
├── _includes/       # Reusable components
├── _sass/           # Sass partials
├── assets/          # CSS, JS, images
└── index.html       # Homepage

# Front matter example
---
layout: post
title: "Welcome"
date: 2024-01-15
categories: jekyll update
---
```

## Strengths
- Native GitHub Pages integration (no CI/CD required)
- Rich plugin ecosystem (jekyll-seo-tag, jekyll-feed)
- Built-in blog awareness (posts, categories, tags)
- Liquid templating for dynamic content
- Sass/SCSS preprocessing out of the box

## Limitations
- Ruby dependency can complicate deployment
- Build times slow for large sites (1000+ pages)
- Limited to GitHub Pages safe plugins when hosted there
- Learning curve for Liquid templating language

## Best Use Cases
- Documentation sites and technical blogs
- GitHub project pages
- Personal portfolios and resumes
- Small to medium marketing sites
- Academic and research websites

## NPL-FIM Integration
```npl
⌜jekyll-builder|jekyll|FIM@1.0⌝
format: jekyll
engine: ruby
templates: liquid
frontmatter: yaml
plugins: [seo, feed, sitemap]
output: static-html
⌞jekyll-builder⌟
```

NPL agents can generate Jekyll-compatible content with proper front matter, leverage Liquid templates for dynamic scaffolding, and automate GitHub Pages deployment workflows through FIM's unified interface.
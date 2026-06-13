---
id: US-033
title: "Document Repository"
slug: "document-repository"
personas: [P-007, P-002, P-001]
epic: "Customer Dashboard"
priority: "should-have"
complexity: "L"
tags: [dashboard, documents, repository, files]
---

# US-033: Document Repository

## User Story

**As an** active client collaborating on a complex engagement (P-007),
**I want to** access a shared document repository for the project — including specs, architecture diagrams, meeting notes, and reference materials,
**So that** both I and Keith have a shared, versioned record of all project artifacts beyond just final deliverables.

## Acceptance Criteria

- [ ] Given I navigate to the Documents tab of a project, when the page loads, then I see a folder-organized list of documents with name, type, upload date, and uploader
- [ ] Given I click on a document, when it opens, then I can either preview it in-browser (for PDF/image) or download it
- [ ] Given Keith uploads a new document, when I next view the repository, then the new document appears with a "new" badge until I view it
- [ ] Given I want to find a specific document, when I type in the search field, then results filter by document name in real time
- [ ] Given a document has been superseded, when Keith marks it archived, then it moves to an "Archive" section I can still access but is visually de-emphasized

## Notes

Distinct from US-028 (Deliverables) — this is for working documents, not final deliverables. Upload is Keith-only initially; consider client upload in a future story. Folder structure per project, organized by Keith. File types: PDF, DOCX, PPTX, PNG/JPG, MD. Storage via S3-compatible object store. Versioning deferred to a future iteration.

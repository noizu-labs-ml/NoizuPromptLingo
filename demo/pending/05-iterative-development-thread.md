# Iterative Development Thread Demo

## Prompt

Create a demonstration of Iterative Development for the NPL project. Generate the following in demo/threads/iterative-development.md:

Create a complete conversation thread for building a REST API for user management:

1. User requests: "Build a REST API for user management with CRUD operations"
2. @npl-thinker designs the endpoint structure and data models
3. @npl-templater creates the FastAPI implementation template
4. @npl-grader reviews the implementation finding issues
5. Iterate: Fix issues based on grader feedback
6. @npl-technical-writer generates comprehensive API documentation
7. @npl-persona (as DevOps engineer) suggests deployment improvements
8. Final iteration with all improvements integrated

Show realistic back-and-forth with clear progression from concept to production-ready API.

## Expected Output Structure

```markdown
# Iterative Development Thread

## Session: REST API Development
**Date:** 2024-01-15
**User:** Full-stack developer
**Goal:** Build production-ready user management API

### Initial Request
**[10:00:00] User:**
Build a REST API for user management with CRUD operations

### Iteration 1: Design Phase
**[10:00:15] @npl-thinker:**
[Endpoint structure and data model design]
- GET /users - List all users
- GET /users/{id} - Get specific user
- POST /users - Create user
- PUT /users/{id} - Update user
- DELETE /users/{id} - Delete user
[Data models, authentication strategy]

### Iteration 2: Implementation
**[10:01:00] @npl-templater:**
[FastAPI implementation with models, routes, database]

### Iteration 3: Code Review
**[10:01:45] @npl-grader:**
[Review finding issues: missing validation, no pagination, weak error handling]
Score: 72/100

### Iteration 4: Improvements
**[10:02:30] User + Assistant:**
[Fixing identified issues]

### Iteration 5: Documentation
**[10:03:15] @npl-technical-writer:**
[Comprehensive API documentation with examples]

### Iteration 6: DevOps Review
**[10:04:00] @npl-persona (DevOps Engineer):**
[Suggestions for containerization, CI/CD, monitoring]

### Iteration 7: Final Implementation
**[10:04:45] Final code with all improvements:**
[Production-ready API with all enhancements]

### Summary
[Evolution from basic CRUD to production-ready API]
```

## Agent Sequence

1. @npl-thinker (design)
2. @npl-templater (implement)
3. @npl-grader (review)
4. Fix issues
5. @npl-technical-writer (document)
6. @npl-persona (DevOps review)
7. Final implementation
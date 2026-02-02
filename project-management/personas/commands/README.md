# Commands

CLI utilities for project initialization, architecture documentation, and layout management.

## Commands

### init-project-fast
Rapid project initialization with sensible defaults. Accelerates project setup vs. full init-project.

### update-arch
Updates architecture documentation (PROJECT-ARCH/) based on current codebase state. Keeps architectural docs in sync with reality.

### update-layout
Updates project layout documentation (PROJECT-LAYOUT/) to reflect current directory structure and file organization.

## Quick Reference

| Command | Purpose | Typical Frequency |
|---------|---------|-------------------|
| **init-project-fast** | Bootstrap new project | One-time |
| **update-arch** | Sync arch docs | Per release |
| **update-layout** | Sync layout docs | As needed |

## Workflows

**New Project Setup**
```bash
init-project-fast  # Rapid initialization
```

**Post-Refactor Documentation**
```bash
update-arch        # Update architecture docs
update-layout      # Update layout docs
```

**Release Preparation**
```bash
update-arch        # Ensure arch docs current
update-layout      # Ensure layout docs current
```

## Integration

These commands maintain documentation consistency and should be run:
- After significant architectural changes (run `update-arch`)
- After directory structure refactoring (run `update-layout`)
- As part of release checklist

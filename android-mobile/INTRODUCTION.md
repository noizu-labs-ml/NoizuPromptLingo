---
skill: android-mobile
version: "1.0"
compatible_with:
  - claude-code
last_updated: 2026-05-28
---

# Android Mobile — Introduction

This skill designs and implements production-ready Android applications from project setup through Play Store publication. It targets engineers building Kotlin/Compose apps using modern Android architecture (MVVM/MVI, Hilt, Room, Retrofit) with Material Design 3. Primary value is a complete, opinionated methodology that produces compilable, shippable code — not scaffolding stubs or pseudocode. It also covers CI/CD configuration, Play Store listing optimization (ASO), and offline-first architecture.

## Input Contract

```yaml
inputs:
  arguments:
    - name: task
      type: freeform
      required: true
      description: "What to build or accomplish (screen, feature, project setup, release, etc.)"
      example: "create a new Android app for tracking daily habits with offline support"

    - name: workflow
      type: choice
      required: false
      description: "Explicit workflow to run: new-project | implement-screen | play-store-release | ci-setup | aso"
      example: "play-store-release"

  file_conventions:
    - pattern: "app/build.gradle.kts"
      format: custom
      description: "App-level Gradle build file; read to detect existing dependencies and min SDK"
      schema: "Standard Android Gradle Kotlin DSL"
      example: |
        android {
            compileSdk = 35
            defaultConfig { minSdk = 26 }
        }

    - pattern: "gradle/libs.versions.toml"
      format: toml
      description: "Version catalog; read to find current library versions before adding dependencies"
      schema: "[versions], [libraries], [plugins] TOML sections"
      example: |
        [versions]
        kotlin = "2.0.0"
        compose-bom = "2024.09.00"

    - pattern: "specs/app-spec.md"
      format: markdown
      description: "Optional feature brief or screen spec provided by the user"
      schema: "Free-form markdown describing screens, flows, and data requirements"
      example: |
        ## Habit Tracker
        - Screen: Home — list of today's habits
        - Screen: Add Habit — form with name, frequency, color

  context_expectations:
    - "Android project directory (contains settings.gradle.kts and app/)"
    - "Kotlin 2.x and Jetpack Compose BOM already in version catalog (for screen/feature work)"
    - "Play Console access and signing keystore (for release workflows)"
```

## Output Contract

```yaml
outputs:
  artifacts:
    - name: "Kotlin source files"
      path: "app/src/main/java/com/example/app/**/*.kt"
      format: custom
      description: "Compilable Kotlin: screen composables, ViewModels, repositories, Room entities, Hilt modules"
      example: |
        @HiltViewModel
        class HomeViewModel @Inject constructor(
            private val habitRepo: HabitRepository
        ) : ViewModel() {
            val uiState: StateFlow<HomeUiState> = ...
        }

    - name: "Gradle configuration"
      path: "app/build.gradle.kts, gradle/libs.versions.toml"
      format: custom
      description: "Updated build files and version catalog entries for added dependencies"

    - name: "CI/CD workflow"
      path: ".github/workflows/android-ci.yml"
      format: yaml
      description: "GitHub Actions pipeline: build, test, optional Play Store deploy"
      example: |
        jobs:
          build:
            runs-on: ubuntu-latest
            steps:
              - uses: actions/checkout@v4
              - run: ./gradlew assembleDebug testDebugUnitTest

    - name: "Play Store listing copy"
      path: "play-store/listing.md"
      format: markdown
      description: "ASO-optimized title, short description, full description, and release notes"

  side_effects:
    - "None — no git commits, no external API calls, no Play Console mutations"

  handoff:
    - skill: user-experience-engineer
      artifact: "Screen composable outputs"
      description: "Hand off screen specs or Figma requirements; UX skill can generate the visual design"
    - skill: seo-guru
      artifact: "Play Store listing copy"
      description: "ASO copy can be further refined for keyword density and conversion"
```

## Conventions

```yaml
conventions:
  naming:
    - "Package structure: ui/screens/{feature}/ contains {Feature}Screen.kt + {Feature}ViewModel.kt"
    - "Composables use PascalCase; preview functions suffixed with Preview"
    - "UI state sealed classes named {Feature}UiState"
  structure:
    - "All UI in Jetpack Compose — no XML layouts generated for new projects"
    - "Every screen composable includes @Preview with light and dark theme variants"
    - "Room + WorkManager for offline-first; network is never the source of truth"
    - "Hilt for DI on all projects; no manual service locators"
  anti_patterns:
    - "Do not generate Java — Kotlin only, even for trivial utility classes"
    - "Do not use SharedPreferences — use DataStore for all key-value storage"
    - "Do not hardcode signing credentials in build files — reference CI environment variables"
    - "Do not default to MVI — use MVVM unless state complexity explicitly warrants MVI"
    - "Do not skip @Preview composables — they are required for every screen"
  prerequisites:
    - "For screen/feature workflows: existing project with Compose BOM and Hilt configured"
    - "For release workflow: signed keystore present and version code incremented"
    - "For CI setup: GitHub repository with Actions enabled"
```

## Reading Order

| Priority | File | When to Read |
|----------|------|--------------|
| 1 (always) | `INTRODUCTION.md` | Before any interaction (you are reading it now) |
| 2 (before executing) | `SKILL.md` | For full workflow details, tech stack tables, and architecture patterns |
| 3 (during execution) | `references/agent-playbook.claude-code.md` | Step-by-step workflow for the specific task (new project, screen, release) |
| 4 (architecture) | `references/android-architecture-guide.md` | When designing data layer or choosing MVVM vs MVI |
| 5 (release) | `references/play-store-publishing.md` | When preparing Play Console listing or staged rollout |
| 6 (testing) | `references/testing-strategy.md` | When writing unit, UI, or screenshot tests |
| 7 (CI/CD) | `references/android-ci-cd-guide.md` | When configuring GitHub Actions or signing |

## Quick Examples

### New app from scratch
`/android-mobile create a habit tracking app with offline support, Room DB, and a home screen showing today's habits`

### Add a feature screen
`/android-mobile implement a Settings screen with dark mode toggle and notification preferences using DataStore`

### Prepare for Play Store release
`/android-mobile play-store-release` — with `app/build.gradle.kts` present; skill audits version code, builds AAB guidance, and produces ASO listing copy

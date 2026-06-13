# Material Design 3 Patterns for Android

Practical guide to implementing Material Design 3 in Jetpack Compose with brand customization.

## Theme Setup

### Color System

Generate colors using the [Material Theme Builder](https://m3.material.io/theme-builder) tool. Export as Kotlin (Compose), which gives you `Color.kt` with all 29 color roles.

**Color roles to understand:**

| Role | Usage | Example |
|------|-------|---------|
| `primary` | Key interactive elements | FABs, prominent buttons, active states |
| `onPrimary` | Text/icons on primary color | Button label text |
| `primaryContainer` | Less prominent primary elements | Card backgrounds, chip fills |
| `secondary` | Supporting elements | Filter chips, toggles |
| `tertiary` | Accent and contrast | Badges, special highlights |
| `surface` | Main background | Scaffold background, cards |
| `surfaceVariant` | Differentiated surface | Dividers, decorative elements |
| `error` | Error states | Validation messages, destructive actions |

### Dynamic Color

```kotlin
@Composable
fun AppTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    dynamicColor: Boolean = true,
    content: @Composable () -> Unit
) {
    val colorScheme = when {
        dynamicColor && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S -> {
            val context = LocalContext.current
            if (darkTheme) dynamicDarkColorScheme(context)
            else dynamicLightColorScheme(context)
        }
        darkTheme -> darkColorScheme(/* brand colors */)
        else -> lightColorScheme(/* brand colors */)
    }

    MaterialTheme(
        colorScheme = colorScheme,
        typography = AppTypography,
        content = content
    )
}
```

### Typography Scale

Map your brand fonts to the MD3 type scale:

| Scale | Default Size | Usage |
|-------|-------------|-------|
| `displayLarge` | 57sp | Hero numbers, marketing callouts |
| `displayMedium` | 45sp | Large display text |
| `displaySmall` | 36sp | Medium display text |
| `headlineLarge` | 32sp | Page titles |
| `headlineMedium` | 28sp | Section headers |
| `headlineSmall` | 24sp | Sub-section headers |
| `titleLarge` | 22sp | Card titles, dialog titles |
| `titleMedium` | 16sp | List item primary text |
| `titleSmall` | 14sp | Tab labels, list item secondary |
| `bodyLarge` | 16sp | Primary body text |
| `bodyMedium` | 14sp | Secondary body text |
| `bodySmall` | 12sp | Captions, timestamps |
| `labelLarge` | 14sp | Button text |
| `labelMedium` | 12sp | Navigation labels |
| `labelSmall` | 11sp | Badge text, overlines |

## Component Selection Guide

### Navigation

| Users Need To... | Use | Compose Component |
|------------------|-----|-------------------|
| Switch between 3-5 top-level sections | Bottom Navigation | `NavigationBar` + `NavigationBarItem` |
| Navigate frequently on tablet/desktop | Navigation Rail | `NavigationRail` + `NavigationRailItem` |
| Access many sections (6+) | Navigation Drawer | `ModalNavigationDrawer` |
| Go back or perform contextual actions | Top App Bar | `TopAppBar`, `MediumTopAppBar`, `LargeTopAppBar` |

### Actions

| Users Need To... | Use | Compose Component |
|------------------|-----|-------------------|
| Perform the primary action on screen | FAB | `FloatingActionButton` |
| Confirm or submit | Filled Button | `Button` |
| Take a secondary action | Outlined Button | `OutlinedButton` |
| Take a low-emphasis action | Text Button | `TextButton` |
| Toggle a binary state | Switch | `Switch` |
| Select from a few options | Segmented Button | `SingleChoiceSegmentedButtonRow` |
| Select multiple from a few options | Filter Chips | `FilterChip` |

### Content

| Content Type | Use | Compose Component |
|-------------|-----|-------------------|
| Grouped content with actions | Card | `Card`, `ElevatedCard`, `OutlinedCard` |
| Scrollable vertical list | LazyColumn | `LazyColumn` with `items()` |
| Scrollable grid | LazyGrid | `LazyVerticalGrid` |
| Short informational text | Snackbar | `Snackbar` via `SnackbarHost` |
| Critical decision | Dialog | `AlertDialog` |
| Detailed input form | Bottom Sheet | `ModalBottomSheet` |
| Loading indicator | Progress | `CircularProgressIndicator`, `LinearProgressIndicator` |

## Adaptive Layouts

### Window Size Classes

```kotlin
@Composable
fun AdaptiveApp() {
    val windowSizeClass = calculateWindowSizeClass(LocalContext.current as Activity)

    when (windowSizeClass.widthSizeClass) {
        WindowWidthSizeClass.Compact -> CompactLayout()   // Phone portrait
        WindowWidthSizeClass.Medium -> MediumLayout()     // Tablet portrait, foldable
        WindowWidthSizeClass.Expanded -> ExpandedLayout() // Tablet landscape, desktop
    }
}
```

### Layout Patterns by Window Size

**Compact (phone):**
- Single pane with bottom navigation
- Full-screen dialogs for complex forms
- Collapsing top app bar for scroll-heavy content

**Medium (tablet portrait, foldable):**
- Optional list-detail split
- Navigation rail instead of bottom bar
- Side sheets instead of bottom sheets

**Expanded (tablet landscape):**
- Permanent navigation drawer
- Two-pane layout (list + detail)
- Supporting panel for contextual info

## Accessibility

### Minimum Requirements

1. **Touch targets** — Minimum 48dp for all interactive elements (Compose enforces this for Material components)
2. **Content descriptions** — Set `contentDescription` on all `Image` and `Icon` composables
3. **Color contrast** — 4.5:1 for normal text, 3:1 for large text (MD3 tokens handle this by default)
4. **Focus order** — Logical reading order for screen readers
5. **Text scaling** — Support up to 200% text scaling without layout breaking

### Compose Accessibility Patterns

```kotlin
// Decorative images
Image(
    painter = painterResource(R.drawable.bg),
    contentDescription = null // null = decorative, TalkBack skips
)

// Semantic grouping
Row(modifier = Modifier.semantics(mergeDescendants = true) {}) {
    Icon(Icons.Default.Star, contentDescription = null)
    Text("4.5 stars")
    // TalkBack reads: "4.5 stars" (merged)
}

// Custom actions
Box(modifier = Modifier.semantics {
    customActions = listOf(
        CustomAccessibilityAction("Delete") { deleteItem(); true }
    )
})
```

## Brand Customization on Top of MD3

### Do

- Override color scheme with brand colors via Material Theme Builder
- Add custom fonts mapped to the typography scale
- Customize shape theme (corner radius) for brand personality
- Add branded illustration style (not Material's style)
- Create custom components that follow MD3 interaction patterns

### Don't

- Override touch target sizes below 48dp
- Use colors outside the color scheme (hardcoded hex values)
- Create custom navigation patterns that break user expectations
- Skip elevation and state layers (they communicate interactivity)
- Mix MD2 and MD3 components in the same app

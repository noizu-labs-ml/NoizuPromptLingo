# Loading States

| Field | Value |
|-------|-------|
| **ID** | loading-states |
| **Type** | Modal |
| **Category** | Accessibility & Performance |
| **User Stories** | US-097 |

## Description

Loading interface with skeleton screens and progress indicators.

## Key Components

- **Skeleton Cards** | Placeholder shapes matching content dimensions (US-097)
- **Progress Indicator** — Generation stage: queued → processing → complete (US-097)
- **Spinner Animation** — General loading indicator (US-097)
- **Submit Button Disabled** | Prevents double submission during loading (US-097)
- **Error State** — Try again button after timeout (US-097)
- **Timeout Message** | Error indication after 10+ seconds (US-097)
- **Screen Reader Announcement** | "Loading [section name]..." (US-097, US-096)

## Interactions

- Skeletons appear within 500ms on slow connections
- Real content replaces skeletons within 5 seconds (3G)
- Progress indicator shows generation stages
- Error state shows after 10 second timeout
- Dimensions match actual to prevent CLS (<0.1)
- Load more pagination shows inline skeletons

## Navigation

- Accessible from: Any navigation or async operation
- Links to: None (temporary state)
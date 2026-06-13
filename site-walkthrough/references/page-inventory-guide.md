# Page Inventory Guide

How to write thorough, machine-readable page inventories.

## Element Types

| Type | Description | Common Actions | Example |
|------|------------|---------------|---------|
| `input` | Text field, textarea, date picker | type, clear, submit | Search bar, email field |
| `button` | Clickable trigger | click | Submit, Add to Cart |
| `link` | Navigation anchor | click | Nav items, breadcrumbs |
| `select` | Dropdown, radio group, checkbox group | select, deselect | Filters, quantity picker |
| `container` | Grouping element | scroll | Product grid, card list |
| `repeating` | Repeated child within a container | click, hover | Product card, list item |
| `navigation` | Pagination, tabs, accordion | click | Page numbers, tab bar |
| `media` | Image, video, audio | play, pause, fullscreen | Hero image, video player |
| `form` | Complete form | fill, submit, reset | Checkout form, login |
| `modal` | Overlay/dialog | open, close, interact | Confirmation dialog |
| `toast` | Notification/alert | dismiss, click-action | Success message |

## Writing Good Selectors

Selectors should be stable across deploys. Priority order:

1. **data-testid** — `[data-testid="add-to-cart"]` (best: exists for testing)
2. **ID** — `#product-search` (good: usually stable)
3. **aria-label** — `[aria-label="Search products"]` (good: accessibility-driven)
4. **Semantic class** — `.product-card` (okay: may change in redesigns)
5. **Tag + position** — `nav > ul > li:nth-child(3)` (fragile: avoid if possible)

If you don't know the selector, use a descriptive placeholder:

```yaml
selector: "[TODO: inspect element]"
```

## Affordance Writing

Affordances describe what users CAN DO, not what elements EXIST. Write them as verb phrases:

```yaml
# Good
affordances:
  - search products by keyword
  - filter by category and price
  - add items to cart
  - view product details

# Bad (describes elements, not actions)
affordances:
  - search bar
  - filter panel
  - add to cart button
  - product cards
```

## Exit Points

Every page should document where users can GO from here:

```yaml
exit_points:
  - page: product-detail
    via: product-card click
  - page: cart
    via: global nav or "View Cart" button
  - page: home
    via: logo click or global nav
  - page: search-results
    via: search submission
```

Exit points are how goal flows know which transitions are possible.

## Auth-Gated Pages

If a page requires authentication:

```yaml
requires_auth: true
auth_redirect: login        # where unauthenticated users go
auth_return: true            # does login redirect back here?
```

Goal flows use this to insert auth gates automatically.

## Dynamic Content

For pages with dynamic content (search results, filtered lists, infinite scroll):

```yaml
dynamic:
  type: search-results       # or: filtered, paginated, infinite-scroll
  empty_state: "No results found"
  loading_state: "Loading..."
  depends_on: search-query    # what determines the content
```

This tells goal flows that the page content isn't static — steps referencing elements here need to account for empty/loading states.

## Inventory Checklist

For each page, verify:

- [ ] All interactive elements captured with IDs and types
- [ ] Selectors are as stable as possible
- [ ] Affordances describe user capabilities, not elements
- [ ] Exit points cover all navigation paths out
- [ ] Auth requirements documented if applicable
- [ ] Dynamic content behavior noted
- [ ] URL pattern is accurate (with path params if needed)
- [ ] Page title matches what users see

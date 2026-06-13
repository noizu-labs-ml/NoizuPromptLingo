# Form Inputs

> Where users do work — errors here cost conversions.

---

## Why This Section Exists

Forms are the primary value exchange in most products. Users give information; the system gives access, results, or confirmation. Every friction point in a form — unclear labels, invisible errors, ambiguous placeholders — is a measurable drop in completion rate. Input styling isn't decoration; it's conversion infrastructure.

## What to Include

### Element Types

- **Text input** — single-line. The default for names, emails, short values.
- **Textarea** — multi-line. For descriptions, messages, notes. Show with a defined height (3-5 rows).
- **Select / Dropdown** — constrained choice. Show with a default placeholder option.
- **Error state** — any input with validation failure. Red border + error message below.
- **Disabled state** — any input that's currently unavailable. Reduced opacity + no interaction.

### States (show for text input at minimum, ideally all types)

- **Empty / Placeholder** — placeholder text visible, border at default color.
- **Filled** — user-entered value replaces placeholder. Border remains default.
- **Focused** — border color darkens or shifts to accent. Clear visual signal that this field is active.
- **Error** — border turns red. Error hint text appears below in red. The field remains editable.
- **Disabled** — opacity reduced to 0.5. Cursor not-allowed. Border lightens.

### Label Conventions

- **Label**: uppercase, small text, positioned above the input. Use the mono or system font at a reduced size (11-12px). Letter-spacing slightly widened.
- **Hint text**: below the input, smaller than the label, in the mono font. Provides context ("Must be at least 8 characters") rather than instruction.
- **Error text**: replaces or appears below hint text. Red. Specific ("Password must include a number") not generic ("Invalid input").

## Best Practices

- **2px borders that darken on focus.** The border change is the primary affordance for "this field is active." It must be obvious, not subtle.
- **Red border on error with descriptive error text.** "Invalid" is not a helpful error message. State what's wrong and, if possible, what to do about it.
- **Placeholder text is an example, not an instruction.** "jane@example.com" is a placeholder. "Enter your email" is a label — put it above the field where it won't disappear on focus.
- **Disabled fields should explain why.** Adjacent text, tooltip, or a small note: "Available after selecting a plan." A grayed-out field with no context is a puzzle, not a UI element.
- **Consistent border treatment with buttons.** If buttons have 2px borders, inputs should too. If buttons have no border-radius, inputs should match. The system is one system.
- **Tab order matters.** Demo the inputs in their logical tab order. If the style guide shows inputs in a random layout, implementers will build them that way.

## Template Usage

Use `InputGroup` to wrap a label and optional hint text around any input child. Props: `label` (string), `hint` (string, optional), `error` (string, optional — replaces hint when present).

Use `InputField` to render the actual input or textarea. Props: `type` (text, textarea, select), `placeholder` (string), `disabled` (boolean), `error` (boolean — triggers red border class).

Wrap demos in `<div className="input-demo">` with a max-width constraint (400-500px) so inputs don't stretch to full viewport width.

Define `.input-field` CSS for the base state, `.input-field:focus` for focus, `.input-field.error` for error, and `.input-field:disabled` for disabled. Update border colors, background, and font to match your theme.

## Anti-Patterns

- **Placeholder text as the only label.** The placeholder disappears on focus. The user can no longer see what the field is for. Always use a persistent label above.
- **Error states without explanation.** A red border with no text forces the user to guess what went wrong.
- **Inconsistent border treatment between inputs and buttons.** If buttons are sharp-cornered with 2px borders and inputs are rounded with 1px borders, the system looks like two systems.
- **Inputs without focus states.** Same accessibility failure as buttons. Keyboard users must see which field is active.
- **Required field markers that appear only after submission.** If a field is required, mark it before the user submits, not after.

## Dependencies

- **02 — Color Palette**: Border colors (default, focus, error), background fills, error red.
- **03 — Typography**: Label font, hint text font/size, input value font.
- **04 — Spacing / Layout**: Padding inside inputs, gap between label and field, gap between field and hint.
- **05 — Buttons**: Border weight and radius must match. Submit buttons appear alongside inputs — they need to feel like the same system.

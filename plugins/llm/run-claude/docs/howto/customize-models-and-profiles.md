## How to: override or add your own models and profiles

**Goal:** add a custom model or profile, or override/disable a built-in one, without editing the installed package.
**Prereqs:** run-claude installed (built-ins already copied to user config on first run via `ensure_initialized()`).

1. Create user-editable templates if you haven't already:
   ```bash
   run-claude install               # profiles + models user templates
   run-claude profiles install       # profiles template only
   ```
2. Add a custom model definition in `~/.config/run-claude/models.yaml`:
   ```yaml
   model_list:
     - model_name: "my-custom-model"
       litellm_params:
         model: openai/gpt-5.5
         api_key: os.environ/OPENAI_API_KEY
   ```
3. Reference it from a profile in `~/.config/run-claude/profiles/<name>.yaml`:
   ```yaml
   meta:
     name: "My Profile"
     opus_model: "my-custom-model"
     sonnet_model: "my-custom-model"
     haiku_model: "some-other-model"
     fable_model: "my-custom-model"
   ```
4. Disable a built-in model entirely by redefining it with `model: null` in your user `models.yaml` — the fallthrough loader treats that as "skip this one."

**Verify:** `run-claude profiles show <name>` prints your model aliases and confirms which file each was loaded from (`Loaded from: ...`, `Models loaded from: ...`); `run-claude models list` / `run-claude models show <name>` confirm the definition resolved as expected.
**Gotchas:**
- Resolution order is **user override > user > built-in** per file, not merged field-by-field — a `model_name` match in a higher-priority file fully replaces the built-in entry.
- `run-claude profiles install` / `run-claude install` refuse to overwrite existing user files unless you pass `--force` — expect "already exist" messages on a second run, that's not a failure.
- Changes to `models.yaml`/profile files aren't picked up by an already-running proxy automatically — either re-enter the directory with `--refresh` (`run-claude enter <token> <profile> --refresh`) or restart the proxy.

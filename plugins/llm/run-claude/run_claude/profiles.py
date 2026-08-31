"""
Profile management for run-claude.

Loads and parses profile YAML files with model definitions.
Supports fall-through profile loading from multiple locations.

Profile search order (first match wins):
1. ~/.config/run-claude/user.profiles.yaml
2. ~/.config/run-claude/profiles.yaml
3. <install>/user.profiles.yaml
4. <install>/profiles.yaml

If a profile entry has `model: null` or `model: false`, it is treated
as not found and the search continues to the next file.
"""

from __future__ import annotations

import os
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

try:
    import yaml
except ImportError:
    yaml = None  # type: ignore


_initialized = False


def ensure_initialized() -> None:
    """Ensure user config is initialized on first run."""
    global _initialized
    if _initialized:
        return
    _initialized = True

    config_dir = get_config_dir()
    marker = config_dir / ".initialized"

    if marker.exists():
        return

    # First run - create user config templates
    _do_first_run_init(config_dir, marker)


# Template for user models.yaml - empty with helpful comments
_USER_MODELS_TEMPLATE = """\
# User model definitions for run-claude
#
# Models defined here override built-in models with the same name.
# Built-in models are in: <install>/run_claude/models.yaml
#
# Format:
# model_list:
#   - model_name: "my-custom-model"
#     litellm_params:
#       model: provider/model-name
#       api_key: os.environ/MY_API_KEY  # References environment variable
#       api_base: https://api.example.com/v1  # Optional
#       drop_params: true  # Drop unsupported params
#
# Example - Add a custom OpenAI-compatible endpoint:
#   - model_name: "my-local-llm"
#     litellm_params:
#       model: openai/my-model
#       api_base: http://localhost:8080/v1
#       api_key: "not-needed"
#       drop_params: true
#
# See built-in models.yaml for more examples.

model_list: []
"""

# Template for user profiles.yaml - empty with helpful comments
_USER_PROFILES_TEMPLATE = """\
# User profiles for run-claude
#
# Profiles defined here override built-in profiles with the same name.
# Built-in profiles are in: <install>/profiles.yaml
#
# Profile search order (first match wins):
# 1. ~/.config/run-claude/user.profiles.yaml  (highest priority overrides)
# 2. ~/.config/run-claude/profiles.yaml       (this file)
# 3. <install>/user.profiles.yaml
# 4. <install>/profiles.yaml                  (built-in defaults)
#
# Format:
# profile-name:
#   name: "Display Name"
#   opus_model: "model-name-for-opus"      # References model from models.yaml
#   sonnet_model: "model-name-for-sonnet"
#   haiku_model: "model-name-for-haiku"
#   fable_model: "model-name-for-fable"    # Optional Claude Code fable alias (defaults to opus_model)
#   extended:                               # Optional: additional models to load
#     - "custom-model-1"
#     - "custom-model-2"
#
# To disable a built-in profile, set model: null
# Example:
#   cerebras:
#     model: null  # Disables cerebras, falls through to lower-priority files
#
# Example - Add a custom profile:
#   my-provider:
#     name: "My Provider"
#     opus_model: "my-custom-model"
#     sonnet_model: "my-custom-model"
#     haiku_model: "my-custom-model"
#     fable_model: "my-custom-model"
"""


def _do_first_run_init(config_dir: Path, marker: Path) -> None:
    """Perform first-run initialization."""
    config_dir.mkdir(parents=True, exist_ok=True)

    installed = 0

    # Create models.yaml template
    dst = get_user_models_file()
    if not dst.exists():
        dst.write_text(_USER_MODELS_TEMPLATE, encoding="utf-8")
        installed += 1

    # Create profiles.yaml template
    dst = get_user_profiles_file()
    if not dst.exists():
        dst.write_text(_USER_PROFILES_TEMPLATE, encoding="utf-8")
        installed += 1

    # Create marker
    marker.touch()

    if installed > 0:
        print(f"run-claude: initialized {config_dir} ({installed} files)", file=sys.stderr)


def get_config_dir() -> Path:
    """Get XDG-compliant config directory."""
    xdg_config = os.environ.get("XDG_CONFIG_HOME")
    if xdg_config:
        base = Path(xdg_config)
    else:
        base = Path.home() / ".config"
    return base / "run-claude"


def get_builtin_dir() -> Path:
    """Get built-in directory (shipped with tool)."""
    pkg_dir = Path(__file__).parent
    # When running from source, profiles.yaml is in parent directory
    if (pkg_dir.parent / "profiles.yaml").exists():
        return pkg_dir.parent
    # When installed via pip, profiles.yaml is inside the package
    return pkg_dir


def get_user_profiles_file() -> Path:
    """Get user profiles.yaml file path."""
    return get_config_dir() / "profiles.yaml"


def get_user_profiles_override_file() -> Path:
    """Get user.profiles.yaml file path (highest priority overrides)."""
    return get_config_dir() / "user.profiles.yaml"


def get_builtin_profiles_file() -> Path:
    """Get built-in profiles.yaml file path."""
    return get_builtin_dir() / "profiles.yaml"


def get_builtin_profiles_override_file() -> Path:
    """Get built-in user.profiles.yaml file path."""
    return get_builtin_dir() / "user.profiles.yaml"


def _get_profiles_files(debug: bool = False) -> list[Path]:
    """
    Get all profile files in priority order (highest to lowest).

    Search order (first match wins):
    1. User override: ~/.config/run-claude/user.profiles.yaml
    2. User config: ~/.config/run-claude/profiles.yaml
    3. Built-in override: <install>/user.profiles.yaml
    4. Built-in: <install>/profiles.yaml
    """
    files = []

    # User override (highest priority)
    user_override = get_user_profiles_override_file()
    if debug:
        print(f"DEBUG: User override profiles: {user_override} (exists={user_override.exists()})", file=sys.stderr)
    if user_override.exists():
        files.append(user_override)

    # User config
    user = get_user_profiles_file()
    if debug:
        print(f"DEBUG: User profiles: {user} (exists={user.exists()})", file=sys.stderr)
    if user.exists():
        files.append(user)

    # Built-in override
    builtin_override = get_builtin_profiles_override_file()
    if debug:
        print(f"DEBUG: Built-in override profiles: {builtin_override} (exists={builtin_override.exists()})", file=sys.stderr)
    if builtin_override.exists():
        files.append(builtin_override)

    # Built-in (lowest priority)
    builtin = get_builtin_profiles_file()
    if debug:
        print(f"DEBUG: Built-in profiles: {builtin} (exists={builtin.exists()})", file=sys.stderr)
    if builtin.exists():
        files.append(builtin)

    if debug:
        print(f"DEBUG: Profile files search order: {files}", file=sys.stderr)

    return files


def get_builtin_models_file() -> Path:
    """Get built-in models definitions file (shipped with tool)."""
    return Path(__file__).parent / "models.yaml"


def get_user_models_file() -> Path:
    """Get user models definitions file."""
    return get_config_dir() / "models.yaml"


def _find_models_files(debug: bool = False) -> list[Path]:
    """
    Find all models files in priority order (lowest to highest).

    Search order (later entries override earlier):
    1. Built-in: <package>/models.yaml
    2. User config: ~/.config/run-claude/models.yaml
    """
    files = []

    # Built-in (lowest priority)
    builtin = get_builtin_models_file()
    if debug:
        print(f"DEBUG: Built-in models: {builtin} (exists={builtin.exists()})", file=sys.stderr)
    if builtin.exists():
        files.append(builtin)

    # User config (highest priority, overrides built-in)
    user = get_user_models_file()
    if debug:
        print(f"DEBUG: User models: {user} (exists={user.exists()})", file=sys.stderr)
    if user.exists():
        files.append(user)

    if debug:
        print(f"DEBUG: Models files search order: {files}", file=sys.stderr)

    return files


@dataclass
class ModelMetadata:
    """Human-readable model metadata for catalog display."""
    description: str = ""
    strengths: str = ""
    weaknesses: str = ""
    provider: str = ""

    @classmethod
    def from_dict(cls, data: dict[str, Any]) -> ModelMetadata:
        return cls(
            description=data.get("description", ""),
            strengths=data.get("strengths", ""),
            weaknesses=data.get("weaknesses", ""),
            provider=data.get("provider", ""),
        )


@dataclass
class ModelDef:
    """LiteLLM model definition."""
    model_name: str
    litellm_params: dict[str, Any] = field(default_factory=dict)
    model_info: dict[str, Any] = field(default_factory=dict)
    metadata: ModelMetadata = field(default_factory=ModelMetadata)

    def to_dict(self) -> dict[str, Any]:
        d: dict[str, Any] = {
            "model_name": self.model_name,
            "litellm_params": self.litellm_params,
        }
        if self.model_info:
            d["model_info"] = self.model_info
        return d

    @classmethod
    def from_dict(cls, data: dict[str, Any]) -> ModelDef:
        metadata_raw = data.get("metadata", {})
        metadata = ModelMetadata.from_dict(metadata_raw) if metadata_raw else ModelMetadata()
        return cls(
            model_name=data.get("model_name", ""),
            litellm_params=data.get("litellm_params", {}),
            model_info=data.get("model_info", {}),
            metadata=metadata,
        )


@dataclass
class ProfileMeta:
    """Profile metadata."""
    name: str = ""
    opus_model: str = ""
    sonnet_model: str = ""
    haiku_model: str = ""
    fable_model: str = ""
    extended: list[str] = field(default_factory=list)

    @classmethod
    def from_dict(cls, data: dict[str, Any]) -> ProfileMeta:
        extended = data.get("extended", [])
        if extended is None:
            extended = []
        return cls(
            name=data.get("name", ""),
            opus_model=data.get("opus_model", ""),
            sonnet_model=data.get("sonnet_model", ""),
            haiku_model=data.get("haiku_model", ""),
            fable_model=data.get("fable_model") or "",
            extended=extended,
        )

    def effective_fable_model(self) -> str:
        """Claude Code fable alias; falls back to opus when fable_model is omitted."""
        return self.fable_model or self.opus_model


@dataclass
class Profile:
    """Agent shim profile."""
    meta: ProfileMeta
    model_list: list[ModelDef] = field(default_factory=list)
    source_path: Path | None = None

    def get_model_names(self) -> list[str]:
        """Get list of model names in this profile."""
        return [m.model_name for m in self.model_list]

    def to_dict(self) -> dict[str, Any]:
        return {
            "meta": {
                "name": self.meta.name,
                "opus_model": self.meta.opus_model,
                "sonnet_model": self.meta.sonnet_model,
                "haiku_model": self.meta.haiku_model,
                "fable_model": self.meta.fable_model,
                "extended": self.meta.extended,
            },
            "model_list": [m.to_dict() for m in self.model_list],
        }

    @classmethod
    def from_dict(cls, data: dict[str, Any], source_path: Path | None = None) -> Profile:
        meta = ProfileMeta.from_dict(data.get("meta", {}))
        model_list = [
            ModelDef.from_dict(m) for m in data.get("model_list", [])
        ]
        return cls(meta=meta, model_list=model_list, source_path=source_path)


# Cache for model definitions
_model_definitions_cache: dict[str, ModelDef] | None = None
_loaded_model_files: list[Path] = []
_loaded_profile_files: dict[str, Path] = {}  # profile_name -> source_path


def _require_yaml() -> None:
    """Raise error if PyYAML not installed."""
    if yaml is None:
        raise RuntimeError(
            "PyYAML is required for profile loading.\n"
            "Install with: pip install pyyaml"
        )


def load_model_definitions(force_reload: bool = False, debug: bool = False) -> dict[str, ModelDef]:
    """
    Load model definitions with base + user override logic.

    Returns a dict mapping model_name -> ModelDef.
    User definitions override base definitions.

    Search order (later entries override earlier):
    1. Built-in: <package>/models.yaml
    2. User config: ~/.config/run-claude/models.yaml
    """
    global _model_definitions_cache, _loaded_model_files

    if _model_definitions_cache is not None and not force_reload:
        return _model_definitions_cache

    _require_yaml()

    models: dict[str, ModelDef] = {}
    _loaded_model_files = []

    # Load from all sources in priority order
    model_files = _find_models_files(debug=debug)
    print(f"[MODELS_FILES] Found {len(model_files)} model file(s)", file=sys.stderr)
    for models_file in model_files:
        _loaded_model_files.append(models_file)
        if debug:
            print(f"DEBUG: Loading models file: {models_file}", file=sys.stderr)
        data = yaml.safe_load(models_file.read_text(encoding="utf-8")) or {}
        count = 0
        for model_data in data.get("model_list", []):
            model_def = ModelDef.from_dict(model_data)
            if model_def.model_name:
                if not model_def.metadata.description and model_def.model_name in models:
                    model_def.metadata = models[model_def.model_name].metadata
                models[model_def.model_name] = model_def
                count += 1
        print(f"[MODELS_LOADED_FROM] {models_file}: {count} model(s)", file=sys.stderr)

    model_names = sorted(models.keys())
    if model_names:
        print(f"[MODELS_AVAILABLE] Total {len(models)} models: {', '.join(model_names)}", file=sys.stderr)

    _model_definitions_cache = models
    return models


def get_model_definition(model_name: str) -> ModelDef | None:
    """Get a specific model definition by name."""
    models = load_model_definitions()
    return models.get(model_name)


def hydrate_model_def(model_def: ModelDef) -> ModelDef:
    """
    Hydrate a model definition by expanding environment variable references.

    Replaces values like 'os.environ/VAR_NAME' with the actual environment variable value.

    Args:
        model_def: Model definition to hydrate

    Returns:
        New ModelDef with hydrated litellm_params
    """
    hydrated_params = {}

    for key, value in model_def.litellm_params.items():
        if isinstance(value, str) and value.startswith("os.environ/"):
            # Extract environment variable name
            env_var = value.replace("os.environ/", "")
            hydrated_value = os.environ.get(env_var)
            if hydrated_value:
                hydrated_params[key] = hydrated_value
                print(f"[HYDRATE] {key}: os.environ/{env_var} -> {hydrated_value[:20]}..." if len(hydrated_value) > 20 else f"[HYDRATE] {key}: os.environ/{env_var} -> {hydrated_value}", file=sys.stderr)
            else:
                # Keep original if env var not found
                hydrated_params[key] = value
                # Print warning in red
                print(f"\033[31m[HYDRATE_WARNING] {key}: os.environ/{env_var} not found, keeping placeholder\033[0m", file=sys.stderr)
        else:
            hydrated_params[key] = value

    return ModelDef(model_name=model_def.model_name, litellm_params=hydrated_params, model_info=model_def.model_info, metadata=model_def.metadata)


# Always-included models (added to every profile)
ALWAYS_INCLUDE_MODELS = ["ultra", "fast", "cheap"]


def resolve_profile_models(profile: Profile, debug: bool = False) -> list[ModelDef]:
    """
    Resolve profile model references to actual model definitions.

    Takes the model names from profile.meta (opus_model, sonnet_model, haiku_model, fable_model)
    and resolves them to ModelDef objects from the model definitions.
    Also always includes 'ultra', 'fast', and 'cheap' models.
    Hydrates environment variable references before returning.
    """
    models = load_model_definitions(debug=debug)
    resolved: list[ModelDef] = []
    seen: set[str] = set()
    not_found: list[str] = []

    # Collect unique model names from profile
    model_names = [
        profile.meta.opus_model,
        profile.meta.sonnet_model,
        profile.meta.haiku_model,
        profile.meta.effective_fable_model(),
    ]

    # Include extended models from profile
    if profile.meta.extended:
        model_names.extend(profile.meta.extended)

    # Always include ultra, fast, and cheap models
    model_names.extend(ALWAYS_INCLUDE_MODELS)

    for name in model_names:
        if name and name not in seen:
            seen.add(name)
            if name in models:
                # Hydrate the model definition before adding to resolved list
                hydrated = hydrate_model_def(models[name])
                resolved.append(hydrated)
                print(f"[MODEL_RESOLVED] '{name}' found in models", file=sys.stderr)
            else:
                not_found.append(name)
                # Print warning in red
                print(f"\033[31m[MODEL_NOT_FOUND] '{name}' - not in models.yaml\033[0m", file=sys.stderr)

    if not_found:
        # Print warning in red
        print(f"\033[31m[PROFILE_RESOLUTION_WARNING] {len(not_found)}/{len([n for n in model_names if n])} models not found\033[0m", file=sys.stderr)

    print(f"[PROFILE_MODELS_RESOLVED] {len(resolved)} models resolved", file=sys.stderr)
    return resolved


def _is_profile_disabled(profile_data: dict[str, Any] | None) -> bool:
    """
    Check if a profile entry is disabled (null/false model field).

    A profile is considered disabled if:
    - The profile_data is None, False, or empty
    - The 'model' field is explicitly null or false
    """
    if not profile_data:
        return True
    if profile_data is False:
        return True
    # Check for explicit model: null or model: false
    if "model" in profile_data:
        model_val = profile_data["model"]
        if model_val is None or model_val is False:
            return True
    return False


# Cache for loaded profiles files
_profiles_cache: dict[Path, dict[str, Any]] = {}


def clear_caches() -> None:
    """Clear all in-memory caches for model and profile definitions."""
    global _model_definitions_cache, _loaded_model_files
    _model_definitions_cache = None
    try:
        _loaded_model_files.clear()
    except Exception:
        pass
    _profiles_cache.clear()


def _load_profiles_file(path: Path, debug: bool = False) -> dict[str, Any]:
    """Load and cache a profiles.yaml file."""
    if path in _profiles_cache:
        return _profiles_cache[path]

    _require_yaml()

    if debug:
        print(f"DEBUG: Loading profiles file: {path}", file=sys.stderr)

    try:
        data = yaml.safe_load(path.read_text(encoding="utf-8")) or {}
    except Exception as e:
        if debug:
            print(f"DEBUG: Error loading {path}: {e}", file=sys.stderr)
        data = {}

    _profiles_cache[path] = data
    return data


def load_profile(name: str, debug: bool = False) -> Profile | None:
    """
    Load a profile by name using fall-through logic.

    Search order (first match wins):
    1. ~/.config/run-claude/user.profiles.yaml
    2. ~/.config/run-claude/profiles.yaml
    3. <install>/user.profiles.yaml
    4. <install>/profiles.yaml

    If a profile entry has `model: null` or `model: false`, it is treated
    as not found and the search continues to the next file.

    After loading, resolves model references from model definitions.
    """
    global _loaded_profile_files
    _require_yaml()

    if debug:
        print(f"DEBUG: Loading profile '{name}'", file=sys.stderr)
        print(f"DEBUG: __file__ = {__file__}", file=sys.stderr)

    # Search through all profile files in priority order
    for profiles_file in _get_profiles_files(debug=debug):
        profiles_data = _load_profiles_file(profiles_file, debug=debug)

        if name in profiles_data:
            profile_data = profiles_data[name]

            if debug:
                print(f"DEBUG: Found '{name}' in {profiles_file}", file=sys.stderr)

            # Check if profile is disabled (null/false model)
            if _is_profile_disabled(profile_data):
                if debug:
                    print(f"DEBUG: Profile '{name}' is disabled in {profiles_file}, continuing search", file=sys.stderr)
                continue

            # Track which profile file was loaded
            _loaded_profile_files[name] = profiles_file

            # Load the profile
            return _load_profile_from_data(name, profile_data, profiles_file, debug=debug)

    if debug:
        print(f"DEBUG: Profile '{name}' not found in any file", file=sys.stderr)
    return None


def _load_profile_from_data(
    name: str,
    data: dict[str, Any],
    source_path: Path,
    debug: bool = False
) -> Profile:
    """Create a Profile from parsed YAML data."""
    # Support both formats:
    # 1. New format with profile data directly under profile name
    # 2. Legacy format with 'meta' key

    if "meta" in data:
        meta_data = data["meta"]
    else:
        meta_data = data

    # Create ProfileMeta
    meta = ProfileMeta.from_dict(meta_data)

    # Use profile name as display name if not specified
    if not meta.name:
        meta.name = name

    # Log profile metadata
    print(f"[PROFILE_LOADED] '{name}' from {source_path}", file=sys.stderr)
    print(f"[PROFILE_MODEL_REFS] opus={meta.opus_model}, sonnet={meta.sonnet_model}, haiku={meta.haiku_model}, fable={meta.effective_fable_model()}", file=sys.stderr)
    if meta.extended:
        print(f"[PROFILE_EXTENDED] {len(meta.extended)} additional models: {', '.join(meta.extended)}", file=sys.stderr)

    profile = Profile(meta=meta, source_path=source_path)

    # Resolve model references to actual definitions
    profile.model_list = resolve_profile_models(profile, debug=debug)

    if debug:
        print(f"DEBUG: Loaded profile '{name}' from {source_path}", file=sys.stderr)

    return profile


def load_profile_file(path: Path, debug: bool = False) -> Profile:
    """
    Load a profile from a specific file path.

    Supports both:
    - Legacy single-profile files (one profile per file)
    - New consolidated format (must specify profile name)
    """
    _require_yaml()

    if debug:
        print(f"DEBUG: Loading profile file: {path}", file=sys.stderr)

    data = yaml.safe_load(path.read_text(encoding="utf-8")) or {}
    profile = Profile.from_dict(data, source_path=path)

    # Use filename as name if not specified in meta
    if not profile.meta.name:
        profile.meta.name = path.stem

    # Resolve model references to actual definitions
    profile.model_list = resolve_profile_models(profile, debug=debug)

    return profile


def list_profiles(debug: bool = False) -> list[str]:
    """
    List all available profile names from all sources.

    Collects profile names from all profiles.yaml files, excluding
    disabled profiles (those with model: null or model: false).
    """
    profiles = set()

    for profiles_file in _get_profiles_files(debug=debug):
        if debug:
            print(f"DEBUG: Scanning {profiles_file} for profiles", file=sys.stderr)

        profiles_data = _load_profiles_file(profiles_file, debug=debug)

        for name, profile_data in profiles_data.items():
            # Skip disabled profiles
            if _is_profile_disabled(profile_data):
                if debug:
                    print(f"DEBUG: Skipping disabled profile: {name}", file=sys.stderr)
                continue

            if debug:
                print(f"DEBUG: Found profile: {name}", file=sys.stderr)
            profiles.add(name)

    if debug:
        print(f"DEBUG: Total profiles found: {len(profiles)}", file=sys.stderr)

    return sorted(profiles)


def list_models() -> list[str]:
    """List all available model names."""
    models = load_model_definitions()
    return sorted(models.keys())


def install_profile(name: str, profile_data: dict[str, Any]) -> Path:
    """
    Install or update a profile in user.profiles.yaml.

    Args:
        name: Profile name (key in the YAML file)
        profile_data: Profile data dictionary

    Returns:
        Path to the user.profiles.yaml file
    """
    _require_yaml()

    user_profiles_file = get_user_profiles_override_file()
    user_profiles_file.parent.mkdir(parents=True, exist_ok=True)

    # Load existing profiles or start fresh
    if user_profiles_file.exists():
        existing = yaml.safe_load(user_profiles_file.read_text(encoding="utf-8")) or {}
    else:
        existing = {}

    # Update with new profile
    existing[name] = profile_data

    # Write back
    user_profiles_file.write_text(
        yaml.safe_dump(existing, default_flow_style=False, allow_unicode=True),
        encoding="utf-8"
    )

    # Clear cache
    if user_profiles_file in _profiles_cache:
        del _profiles_cache[user_profiles_file]

    return user_profiles_file


def get_profile_path(name: str) -> Path | None:
    """
    Get the path to the profiles file containing a profile.

    Returns the first file that contains the profile (non-disabled).
    """
    for profiles_file in _get_profiles_files():
        profiles_data = _load_profiles_file(profiles_file)
        if name in profiles_data:
            profile_data = profiles_data[name]
            if not _is_profile_disabled(profile_data):
                return profiles_file

    return None


def get_loaded_files() -> dict[str, list[Path]]:
    """
    Get the paths to the loaded profiles and models files.

    Returns a dict with 'profiles' and 'models' keys containing lists of paths.
    """
    return {
        "profiles": list(_loaded_profile_files.values()),
        "models": _loaded_model_files.copy(),
    }

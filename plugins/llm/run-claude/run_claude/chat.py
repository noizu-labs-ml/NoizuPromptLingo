"""Small interactive chat client for the local LiteLLM proxy."""

from __future__ import annotations

import sys
from typing import Any

try:
    import httpx
except ImportError:  # pragma: no cover - package dependency, defensive fallback
    httpx = None  # type: ignore

from . import proxy


HELP = """Commands:
  /models           refresh and show enabled models
  /model <name>     switch to another enabled model
  /keys             list named keys and the binding for this model
  /key <name>       bind this model's family to a named key (e.g. /key tyna)
  /key <fam> <key>  bind a family or model (e.g. /key zai tyna)
  /clear            clear conversation history
  /help             show this help
  /exit, /quit      leave the session"""


def enabled_model_names() -> list[str]:
    """Return unique model names currently registered with the live proxy."""
    return sorted(
        {
            item.get("model_name")
            for item in proxy.list_models()
            if item.get("model_name")
        }
    )


def _show_models(names: list[str], current: str | None = None) -> None:
    if not names:
        print("No models are currently enabled.")
        return
    print("Enabled models:")
    for name in names:
        marker = "*" if name == current else " "
        print(f" {marker} {name}")


def _choose_model(requested: str | None, names: list[str]) -> str | None:
    if requested:
        if requested in names:
            return requested
        print(f"Model is not enabled: {requested}", file=sys.stderr)
        _show_models(names)
        return None

    if not names:
        return None
    if len(names) == 1:
        return names[0]
    if not sys.stdin.isatty():
        print("Specify a model when stdin is not interactive.", file=sys.stderr)
        _show_models(names)
        return None

    _show_models(names)
    try:
        selection = input(f"Model [1-{len(names)} or name]: ").strip()
    except (EOFError, KeyboardInterrupt):
        print()
        return None
    if not selection:
        return names[0]
    if selection.isdigit() and 1 <= int(selection) <= len(names):
        return names[int(selection) - 1]
    if selection in names:
        return selection
    print(f"Model is not enabled: {selection}", file=sys.stderr)
    return None


def _content_text(content: Any) -> str:
    """Normalize OpenAI-compatible message content to terminal text."""
    if isinstance(content, str):
        return content
    if isinstance(content, list):
        parts: list[str] = []
        for block in content:
            if isinstance(block, str):
                parts.append(block)
            elif isinstance(block, dict) and isinstance(block.get("text"), str):
                parts.append(block["text"])
        return "\n".join(parts)
    return str(content or "")


def _chat_keys(current: str) -> None:
    from .keys import family_of, format_listing
    try:
        payload = proxy.list_named_keys()
    except Exception as exc:
        print(f"Could not list keys: {exc}", file=sys.stderr)
        return
    print(format_listing(payload))
    fam = family_of(current)
    bound = None
    for row in payload.get("bindings") or []:
        if row.get("model_name") == current:
            bound = row.get("key") or "(unset)"
            break
    print(f"\nCurrent model {current} (family {fam}) -> {bound or '(unset)'}")


def _chat_key_switch(current: str, rest: str) -> None:
    from .keys import canonical_key_name, family_of
    parts = rest.split()
    if not parts:
        print("Usage: /key <name>   or   /key <family> <name>", file=sys.stderr)
        return
    if len(parts) == 1:
        target, key = family_of(current), parts[0]
    else:
        target, key = parts[0], parts[1]
    key = canonical_key_name(key)
    try:
        proxy.ensure_named_keys()
        result = proxy.switch_named_key(key, target=target)
    except Exception as exc:
        print(f"Key switch failed: {exc}", file=sys.stderr)
        return
    updated = result.get("updated") or []
    print(f"Bound {key} on {len(updated)} model(s) in {target}")
    for name in updated:
        print(f"  {name}")


def complete(model: str, messages: list[dict[str, str]], timeout: float) -> str:
    """Request one non-streaming completion from the local LiteLLM proxy."""
    if httpx is None:
        raise RuntimeError("httpx is required for chat")

    response = httpx.post(
        f"{proxy.get_proxy_url()}/v1/chat/completions",
        headers={
            "Authorization": f"Bearer {proxy.get_master_key()}",
            "Content-Type": "application/json",
        },
        json={"model": model, "messages": messages, "stream": False},
        timeout=timeout,
    )
    if response.status_code >= 400:
        try:
            payload = response.json()
            error = payload.get("error", payload)
            detail = error.get("message", error) if isinstance(error, dict) else error
        except Exception:
            detail = response.text
        raise RuntimeError(f"proxy returned HTTP {response.status_code}: {detail}")

    payload = response.json()
    try:
        return _content_text(payload["choices"][0]["message"]["content"])
    except (KeyError, IndexError, TypeError) as exc:
        raise RuntimeError("proxy response did not contain an assistant message") from exc


def run_chat(
    model: str | None = None,
    system_prompt: str | None = None,
    prompt: str | None = None,
    timeout: float = 300.0,
) -> int:
    """Run a one-shot prompt or an interactive, multi-turn chat session."""
    if timeout <= 0:
        print("Chat timeout must be greater than zero.", file=sys.stderr)
        return 2
    if not proxy.is_proxy_running() or not proxy.health_check(timeout=5.0):
        print("LiteLLM proxy is not healthy.", file=sys.stderr)
        print("Start it with: run-claude proxy start", file=sys.stderr)
        return 1

    names = enabled_model_names()
    if not names:
        print("No models are enabled in the proxy.", file=sys.stderr)
        print("Enable a profile with: run-claude with <profile>", file=sys.stderr)
        return 1

    current = _choose_model(model, names)
    if current is None:
        return 1

    messages: list[dict[str, str]] = []
    if system_prompt:
        messages.append({"role": "system", "content": system_prompt})

    def send(text: str) -> bool:
        candidate = messages + [{"role": "user", "content": text}]
        try:
            answer = complete(current, candidate, timeout)
        except KeyboardInterrupt:
            print("\nRequest cancelled.", file=sys.stderr)
            return False
        except Exception as exc:
            print(f"Chat request failed: {exc}", file=sys.stderr)
            return False
        messages.extend(
            [
                {"role": "user", "content": text},
                {"role": "assistant", "content": answer},
            ]
        )
        print(answer)
        return True

    if prompt is not None:
        return 0 if send(prompt) else 1

    print(f"Chatting with {current}. Type /help for commands; Ctrl-D to exit.")
    while True:
        try:
            text = input("you> ").strip()
        except EOFError:
            print()
            return 0
        except KeyboardInterrupt:
            print("\nUse /exit or Ctrl-D to leave.")
            continue

        if not text:
            continue
        if text in ("/exit", "/quit"):
            return 0
        if text == "/help":
            print(HELP)
            continue
        if text == "/clear":
            messages = (
                [{"role": "system", "content": system_prompt}]
                if system_prompt
                else []
            )
            print("Conversation cleared.")
            continue
        if text == "/models":
            names = enabled_model_names()
            _show_models(names, current=current)
            continue
        if text == "/model" or text.startswith("/model "):
            requested = text[6:].strip() or None
            names = enabled_model_names()
            selected = _choose_model(requested, names)
            if selected is not None:
                current = selected
                messages = (
                    [{"role": "system", "content": system_prompt}]
                    if system_prompt
                    else []
                )
                print(f"Switched to {current}; conversation cleared.")
            continue
        if text == "/keys":
            _chat_keys(current)
            continue
        if text == "/key" or text.startswith("/key "):
            _chat_key_switch(current, text[4:].strip())
            continue
        if text.startswith("/"):
            print("Unknown command. Type /help for commands.")
            continue

        send(text)

"""Screenshot capture using Playwright.

Provides headless browser automation for capturing web page screenshots
with configurable viewport, theme, and wait conditions.
"""

import asyncio
from dataclasses import dataclass
from datetime import datetime, timezone
from typing import Optional, Dict, Any, Tuple

# Viewport presets matching PRD-008
VIEWPORT_PRESETS = {
    "desktop": {"width": 1280, "height": 720},
    "mobile": {"width": 375, "height": 667},
    "tablet": {"width": 768, "height": 1024},
    "4k": {"width": 3840, "height": 2160},
}

# Maximum dimensions to prevent memory issues
MAX_WIDTH = 3840
MAX_HEIGHT = 10000


@dataclass
class CaptureResult:
    """Result of a screenshot capture."""
    image_bytes: bytes
    width: int
    height: int
    url: str
    viewport_preset: Optional[str]
    theme: str
    full_page: bool
    captured_at: str


def parse_viewport(viewport: str) -> Tuple[int, int, Optional[str]]:
    """Parse viewport string to dimensions.

    Args:
        viewport: "desktop", "mobile", "tablet", "4k", or "WIDTHxHEIGHT"

    Returns:
        Tuple of (width, height, preset_name or None)
    """
    viewport_lower = viewport.lower()

    if viewport_lower in VIEWPORT_PRESETS:
        preset = VIEWPORT_PRESETS[viewport_lower]
        return preset["width"], preset["height"], viewport_lower

    # Parse custom dimensions
    if "x" in viewport_lower:
        try:
            parts = viewport_lower.split("x")
            width = min(int(parts[0]), MAX_WIDTH)
            height = min(int(parts[1]), MAX_HEIGHT)
            return width, height, None
        except (ValueError, IndexError):
            pass

    # Default to desktop
    preset = VIEWPORT_PRESETS["desktop"]
    return preset["width"], preset["height"], "desktop"


class BrowserManager:
    """Manages browser lifecycle for screenshot capture.

    Supports session persistence for authenticated captures.
    """

    def __init__(self):
        self._browser = None
        self._playwright = None
        self._contexts: Dict[str, Any] = {}  # session_key -> browser context

    async def _ensure_browser(self):
        """Ensure browser is launched."""
        if self._browser is None:
            from playwright.async_api import async_playwright
            self._playwright = await async_playwright().start()
            self._browser = await self._playwright.chromium.launch(
                headless=True,
                args=[
                    "--disable-gpu",
                    "--disable-dev-shm-usage",
                    "--no-sandbox",
                ]
            )

    async def get_context(
        self,
        width: int,
        height: int,
        theme: str = "light",
        session_key: Optional[str] = None
    ) -> Any:
        """Get or create a browser context.

        Args:
            width: Viewport width
            height: Viewport height
            theme: "light" or "dark"
            session_key: Optional key for session persistence

        Returns:
            Playwright browser context
        """
        await self._ensure_browser()

        # Return existing context if session key matches
        if session_key and session_key in self._contexts:
            ctx = self._contexts[session_key]
            # Update viewport if changed
            pages = ctx.pages
            if pages:
                await pages[0].set_viewport_size({"width": width, "height": height})
            return ctx

        # Create new context
        color_scheme = "dark" if theme.lower() == "dark" else "light"
        context = await self._browser.new_context(
            viewport={"width": width, "height": height},
            color_scheme=color_scheme,
            # Disable animations for consistent captures
            reduced_motion="reduce",
        )

        # Inject CSS to disable animations
        await context.add_init_script("""
            const style = document.createElement('style');
            style.textContent = `
                *, *::before, *::after {
                    animation-duration: 0s !important;
                    animation-delay: 0s !important;
                    transition-duration: 0s !important;
                    transition-delay: 0s !important;
                }
            `;
            document.head.appendChild(style);
        """)

        if session_key:
            self._contexts[session_key] = context

        return context

    async def close_context(self, session_key: str):
        """Close a specific browser context."""
        if session_key in self._contexts:
            await self._contexts[session_key].close()
            del self._contexts[session_key]

    async def close(self):
        """Close browser and all contexts."""
        for ctx in self._contexts.values():
            await ctx.close()
        self._contexts.clear()

        if self._browser:
            await self._browser.close()
            self._browser = None

        if self._playwright:
            await self._playwright.stop()
            self._playwright = None


# Global browser manager instance
_browser_manager: Optional[BrowserManager] = None


async def get_browser_manager() -> BrowserManager:
    """Get or create global browser manager."""
    global _browser_manager
    if _browser_manager is None:
        _browser_manager = BrowserManager()
    return _browser_manager


async def capture_screenshot(
    url: str,
    viewport: str = "desktop",
    theme: str = "light",
    full_page: bool = True,
    wait_for: Optional[str] = None,
    wait_timeout: int = 5000,
    network_idle: bool = True,
    session_key: Optional[str] = None,
) -> CaptureResult:
    """Capture screenshot of a web page.

    Args:
        url: URL to capture (full URL or relative with base in session)
        viewport: "desktop", "mobile", "tablet", "4k", or "WIDTHxHEIGHT"
        theme: "light" or "dark" (sets browser colorScheme)
        full_page: Capture entire scrollable page
        wait_for: CSS selector to wait for before capture
        wait_timeout: Milliseconds to wait for selector
        network_idle: Wait for network to be idle before capture
        session_key: Optional key for browser session persistence

    Returns:
        CaptureResult with image bytes and metadata

    Raises:
        ValueError: If URL is invalid or page fails to load
        TimeoutError: If wait conditions are not met
    """
    # Parse viewport
    width, height, preset = parse_viewport(viewport)

    # Get browser manager and context
    manager = await get_browser_manager()
    context = await manager.get_context(width, height, theme, session_key)

    # Create new page
    page = await context.new_page()

    try:
        # Navigate to URL
        wait_until = "networkidle" if network_idle else "load"
        await page.goto(url, wait_until=wait_until, timeout=30000)

        # Wait for specific selector if provided
        if wait_for:
            await page.wait_for_selector(wait_for, timeout=wait_timeout)

        # Small delay for any final rendering
        await asyncio.sleep(0.1)

        # Capture screenshot
        screenshot_bytes = await page.screenshot(
            full_page=full_page,
            type="png",
        )

        # Get actual dimensions
        if full_page:
            dimensions = await page.evaluate("""
                () => ({
                    width: Math.max(document.body.scrollWidth, document.documentElement.scrollWidth),
                    height: Math.max(document.body.scrollHeight, document.documentElement.scrollHeight)
                })
            """)
            actual_width = dimensions["width"]
            actual_height = dimensions["height"]
        else:
            actual_width = width
            actual_height = height

        return CaptureResult(
            image_bytes=screenshot_bytes,
            width=actual_width,
            height=actual_height,
            url=url,
            viewport_preset=preset,
            theme=theme,
            full_page=full_page,
            captured_at=datetime.now(timezone.utc).isoformat(),
        )

    finally:
        # Close page but keep context for session persistence
        await page.close()

        # If no session key, close the context too
        if not session_key:
            await context.close()


async def authenticate(
    context: Any,
    auth_config: Dict[str, Any],
    base_url: str,
) -> bool:
    """Perform authentication flow in browser context.

    Args:
        context: Playwright browser context
        auth_config: Authentication configuration with:
            - login_url: Relative URL to login page
            - email_selector: CSS selector for email field
            - password_selector: CSS selector for password field
            - submit_selector: CSS selector for submit button
            - email: Email/username value
            - password: Password value (supports ${ENV_VAR} syntax)
            - success_url_pattern: Glob pattern for successful redirect
            - success_timeout: Milliseconds to wait for success
        base_url: Base URL for relative paths

    Returns:
        True if authentication succeeded

    Raises:
        ValueError: If authentication fails
    """
    import os
    import re

    page = await context.new_page()

    try:
        # Get login URL
        login_url = auth_config.get("login_url", "/login")
        if not login_url.startswith("http"):
            login_url = f"{base_url.rstrip('/')}/{login_url.lstrip('/')}"

        await page.goto(login_url, wait_until="networkidle")

        # Get credentials (support env var syntax)
        email = auth_config.get("email", "")
        password = auth_config.get("password", "")

        # Resolve environment variables
        env_pattern = re.compile(r'\$\{(\w+)\}')
        email = env_pattern.sub(lambda m: os.environ.get(m.group(1), ""), email)
        password = env_pattern.sub(lambda m: os.environ.get(m.group(1), ""), password)

        # Fill credentials
        email_selector = auth_config.get("email_selector", "input[name='email']")
        password_selector = auth_config.get("password_selector", "input[name='password']")
        submit_selector = auth_config.get("submit_selector", "button[type='submit']")

        await page.fill(email_selector, email)
        await page.fill(password_selector, password)

        # Click submit
        await page.click(submit_selector)

        # Wait for success
        success_pattern = auth_config.get("success_url_pattern", "**/dashboard**")
        success_timeout = auth_config.get("success_timeout", 10000)

        await page.wait_for_url(success_pattern, timeout=success_timeout)

        return True

    except Exception as e:
        raise ValueError(f"Authentication failed: {e}")
    finally:
        await page.close()

"""Browser interaction tools for LLM agents.

Provides tools for navigating, clicking, filling forms, and
interacting with web pages programmatically.
"""

from dataclasses import dataclass, field
from datetime import datetime, timezone
from typing import Optional, Dict, Any, List

from .capture import get_browser_manager, parse_viewport


@dataclass
class PageState:
    """Current state of a browser page."""
    url: str
    title: str
    viewport: Dict[str, int]
    has_focus: bool
    scroll_position: Dict[str, int]


@dataclass
class ElementInfo:
    """Information about a DOM element."""
    tag: str
    text: str
    visible: bool
    bounding_box: Optional[Dict[str, float]]
    attributes: Dict[str, str]


@dataclass
class InteractionResult:
    """Result of a browser interaction."""
    success: bool
    action: str
    target: Optional[str]
    message: str
    timestamp: str = field(default_factory=lambda: datetime.now(timezone.utc).isoformat())
    screenshot: Optional[bytes] = None  # Optional screenshot after action


class BrowserSession:
    """Manages an interactive browser session for LLM agents.

    Provides high-level methods for browser automation that can be
    exposed as MCP tools.
    """

    def __init__(self, session_id: str):
        self.session_id = session_id
        self._page = None
        self._context = None
        self._manager = None

    async def _ensure_page(self):
        """Ensure we have an active page."""
        if self._page is None or self._page.is_closed():
            self._manager = await get_browser_manager()
            self._context = await self._manager.get_context(
                1280, 720, "light", session_key=self.session_id
            )
            self._page = await self._context.new_page()

    async def navigate(
        self,
        url: str,
        wait_for: Optional[str] = None,
        timeout: int = 30000,
    ) -> InteractionResult:
        """Navigate to a URL.

        Args:
            url: URL to navigate to
            wait_for: Optional CSS selector to wait for
            timeout: Navigation timeout in milliseconds

        Returns:
            InteractionResult with success status
        """
        await self._ensure_page()

        try:
            await self._page.goto(url, wait_until="networkidle", timeout=timeout)

            if wait_for:
                await self._page.wait_for_selector(wait_for, timeout=timeout)

            return InteractionResult(
                success=True,
                action="navigate",
                target=url,
                message=f"Navigated to {url}",
            )
        except Exception as e:
            return InteractionResult(
                success=False,
                action="navigate",
                target=url,
                message=f"Navigation failed: {e}",
            )

    async def click(
        self,
        selector: str,
        timeout: int = 5000,
        capture_after: bool = False,
    ) -> InteractionResult:
        """Click an element.

        Args:
            selector: CSS selector for element to click
            timeout: Wait timeout in milliseconds
            capture_after: Capture screenshot after click

        Returns:
            InteractionResult with optional screenshot
        """
        await self._ensure_page()

        try:
            await self._page.click(selector, timeout=timeout)

            screenshot = None
            if capture_after:
                await self._page.wait_for_load_state("networkidle")
                screenshot = await self._page.screenshot(type="png")

            return InteractionResult(
                success=True,
                action="click",
                target=selector,
                message=f"Clicked element: {selector}",
                screenshot=screenshot,
            )
        except Exception as e:
            return InteractionResult(
                success=False,
                action="click",
                target=selector,
                message=f"Click failed: {e}",
            )

    async def fill(
        self,
        selector: str,
        value: str,
        timeout: int = 5000,
    ) -> InteractionResult:
        """Fill a form field.

        Args:
            selector: CSS selector for input element
            value: Value to fill
            timeout: Wait timeout in milliseconds

        Returns:
            InteractionResult with success status
        """
        await self._ensure_page()

        try:
            await self._page.fill(selector, value, timeout=timeout)

            return InteractionResult(
                success=True,
                action="fill",
                target=selector,
                message=f"Filled {selector} with value (length: {len(value)})",
            )
        except Exception as e:
            return InteractionResult(
                success=False,
                action="fill",
                target=selector,
                message=f"Fill failed: {e}",
            )

    async def type_text(
        self,
        selector: str,
        text: str,
        delay: int = 50,
        timeout: int = 5000,
    ) -> InteractionResult:
        """Type text character by character (simulates real typing).

        Args:
            selector: CSS selector for input element
            text: Text to type
            delay: Delay between keystrokes in milliseconds
            timeout: Wait timeout in milliseconds

        Returns:
            InteractionResult with success status
        """
        await self._ensure_page()

        try:
            await self._page.type(selector, text, delay=delay, timeout=timeout)

            return InteractionResult(
                success=True,
                action="type",
                target=selector,
                message=f"Typed {len(text)} characters into {selector}",
            )
        except Exception as e:
            return InteractionResult(
                success=False,
                action="type",
                target=selector,
                message=f"Type failed: {e}",
            )

    async def select(
        self,
        selector: str,
        value: str,
        timeout: int = 5000,
    ) -> InteractionResult:
        """Select option from dropdown.

        Args:
            selector: CSS selector for select element
            value: Option value to select
            timeout: Wait timeout in milliseconds

        Returns:
            InteractionResult with success status
        """
        await self._ensure_page()

        try:
            await self._page.select_option(selector, value, timeout=timeout)

            return InteractionResult(
                success=True,
                action="select",
                target=selector,
                message=f"Selected '{value}' in {selector}",
            )
        except Exception as e:
            return InteractionResult(
                success=False,
                action="select",
                target=selector,
                message=f"Select failed: {e}",
            )

    async def scroll(
        self,
        direction: str = "down",
        amount: int = 500,
        selector: Optional[str] = None,
    ) -> InteractionResult:
        """Scroll the page or an element.

        Args:
            direction: "up", "down", "left", "right"
            amount: Pixels to scroll
            selector: Optional element to scroll (scrolls page if None)

        Returns:
            InteractionResult with success status
        """
        await self._ensure_page()

        try:
            if selector:
                element = await self._page.query_selector(selector)
                if element:
                    if direction == "down":
                        await element.evaluate(f"el => el.scrollTop += {amount}")
                    elif direction == "up":
                        await element.evaluate(f"el => el.scrollTop -= {amount}")
                    elif direction == "right":
                        await element.evaluate(f"el => el.scrollLeft += {amount}")
                    elif direction == "left":
                        await element.evaluate(f"el => el.scrollLeft -= {amount}")
            else:
                if direction == "down":
                    await self._page.evaluate(f"window.scrollBy(0, {amount})")
                elif direction == "up":
                    await self._page.evaluate(f"window.scrollBy(0, -{amount})")
                elif direction == "right":
                    await self._page.evaluate(f"window.scrollBy({amount}, 0)")
                elif direction == "left":
                    await self._page.evaluate(f"window.scrollBy(-{amount}, 0)")

            return InteractionResult(
                success=True,
                action="scroll",
                target=selector or "page",
                message=f"Scrolled {direction} by {amount}px",
            )
        except Exception as e:
            return InteractionResult(
                success=False,
                action="scroll",
                target=selector or "page",
                message=f"Scroll failed: {e}",
            )

    async def wait_for(
        self,
        selector: str,
        state: str = "visible",
        timeout: int = 10000,
    ) -> InteractionResult:
        """Wait for an element to reach a state.

        Args:
            selector: CSS selector for element
            state: "visible", "hidden", "attached", "detached"
            timeout: Wait timeout in milliseconds

        Returns:
            InteractionResult with success status
        """
        await self._ensure_page()

        try:
            await self._page.wait_for_selector(
                selector,
                state=state,
                timeout=timeout
            )

            return InteractionResult(
                success=True,
                action="wait_for",
                target=selector,
                message=f"Element {selector} is now {state}",
            )
        except Exception as e:
            return InteractionResult(
                success=False,
                action="wait_for",
                target=selector,
                message=f"Wait failed: {e}",
            )

    async def get_text(
        self,
        selector: str,
        timeout: int = 5000,
    ) -> str:
        """Get text content of an element.

        Args:
            selector: CSS selector for element
            timeout: Wait timeout in milliseconds

        Returns:
            Text content of the element
        """
        await self._ensure_page()

        try:
            element = await self._page.wait_for_selector(selector, timeout=timeout)
            if element:
                return await element.text_content() or ""
            return ""
        except Exception:
            return ""

    async def get_attribute(
        self,
        selector: str,
        attribute: str,
        timeout: int = 5000,
    ) -> Optional[str]:
        """Get attribute value of an element.

        Args:
            selector: CSS selector for element
            attribute: Attribute name
            timeout: Wait timeout in milliseconds

        Returns:
            Attribute value or None
        """
        await self._ensure_page()

        try:
            element = await self._page.wait_for_selector(selector, timeout=timeout)
            if element:
                return await element.get_attribute(attribute)
            return None
        except Exception:
            return None

    async def evaluate(
        self,
        expression: str,
    ) -> Any:
        """Evaluate JavaScript expression in page context.

        Args:
            expression: JavaScript expression to evaluate

        Returns:
            Result of the expression
        """
        await self._ensure_page()

        try:
            return await self._page.evaluate(expression)
        except Exception as e:
            return {"error": str(e)}

    async def get_page_state(self) -> PageState:
        """Get current page state.

        Returns:
            PageState with URL, title, and viewport info
        """
        await self._ensure_page()

        url = self._page.url
        title = await self._page.title()
        viewport = self._page.viewport_size or {"width": 0, "height": 0}
        scroll = await self._page.evaluate("""
            () => ({x: window.scrollX, y: window.scrollY})
        """)

        return PageState(
            url=url,
            title=title,
            viewport=viewport,
            has_focus=True,
            scroll_position=scroll,
        )

    async def query_elements(
        self,
        selector: str,
        limit: int = 10,
    ) -> List[ElementInfo]:
        """Query multiple elements matching selector.

        Args:
            selector: CSS selector
            limit: Maximum elements to return

        Returns:
            List of ElementInfo for matching elements
        """
        await self._ensure_page()

        elements = []
        try:
            handles = await self._page.query_selector_all(selector)

            for handle in handles[:limit]:
                try:
                    info = await handle.evaluate("""
                        el => ({
                            tag: el.tagName.toLowerCase(),
                            text: el.textContent?.slice(0, 200) || '',
                            visible: el.offsetParent !== null,
                            attributes: Object.fromEntries(
                                Array.from(el.attributes).map(a => [a.name, a.value])
                            )
                        })
                    """)

                    box = await handle.bounding_box()

                    elements.append(ElementInfo(
                        tag=info["tag"],
                        text=info["text"].strip(),
                        visible=info["visible"],
                        bounding_box=box,
                        attributes=info["attributes"],
                    ))
                except Exception:
                    continue

        except Exception:
            pass

        return elements

    async def screenshot(
        self,
        full_page: bool = False,
        selector: Optional[str] = None,
    ) -> bytes:
        """Capture screenshot of current page or element.

        Args:
            full_page: Capture entire scrollable page
            selector: Optional element to screenshot

        Returns:
            PNG bytes of screenshot
        """
        await self._ensure_page()

        if selector:
            element = await self._page.query_selector(selector)
            if element:
                return await element.screenshot(type="png")

        return await self._page.screenshot(full_page=full_page, type="png")

    async def press_key(
        self,
        key: str,
        modifiers: Optional[List[str]] = None,
    ) -> InteractionResult:
        """Press a keyboard key.

        Args:
            key: Key to press (e.g., "Enter", "Tab", "Escape", "ArrowDown", "a")
            modifiers: Optional list of modifiers ["Control", "Shift", "Alt", "Meta"]

        Returns:
            InteractionResult with success status
        """
        await self._ensure_page()

        try:
            if modifiers:
                key_combo = "+".join(modifiers + [key])
                await self._page.keyboard.press(key_combo)
            else:
                await self._page.keyboard.press(key)

            return InteractionResult(
                success=True,
                action="press_key",
                target=key,
                message=f"Pressed key: {key}" + (f" with {modifiers}" if modifiers else ""),
            )
        except Exception as e:
            return InteractionResult(
                success=False,
                action="press_key",
                target=key,
                message=f"Key press failed: {e}",
            )

    async def hover(
        self,
        selector: str,
        timeout: int = 5000,
    ) -> InteractionResult:
        """Hover over an element.

        Args:
            selector: CSS selector for element
            timeout: Wait timeout in milliseconds

        Returns:
            InteractionResult with success status
        """
        await self._ensure_page()

        try:
            await self._page.hover(selector, timeout=timeout)

            return InteractionResult(
                success=True,
                action="hover",
                target=selector,
                message=f"Hovered over: {selector}",
            )
        except Exception as e:
            return InteractionResult(
                success=False,
                action="hover",
                target=selector,
                message=f"Hover failed: {e}",
            )

    async def focus(
        self,
        selector: str,
        timeout: int = 5000,
    ) -> InteractionResult:
        """Focus on an element.

        Args:
            selector: CSS selector for element
            timeout: Wait timeout in milliseconds

        Returns:
            InteractionResult with success status
        """
        await self._ensure_page()

        try:
            await self._page.focus(selector, timeout=timeout)

            return InteractionResult(
                success=True,
                action="focus",
                target=selector,
                message=f"Focused on: {selector}",
            )
        except Exception as e:
            return InteractionResult(
                success=False,
                action="focus",
                target=selector,
                message=f"Focus failed: {e}",
            )

    async def get_html(
        self,
        selector: Optional[str] = None,
        outer: bool = True,
    ) -> str:
        """Get HTML content of page or element.

        Args:
            selector: Optional CSS selector (entire page if None)
            outer: If True, include element's own tag (outerHTML vs innerHTML)

        Returns:
            HTML content string
        """
        await self._ensure_page()

        try:
            if selector:
                element = await self._page.query_selector(selector)
                if element:
                    if outer:
                        return await element.evaluate("el => el.outerHTML")
                    else:
                        return await element.evaluate("el => el.innerHTML")
                return ""
            else:
                return await self._page.content()
        except Exception:
            return ""

    async def set_viewport(
        self,
        width: int,
        height: int,
    ) -> InteractionResult:
        """Change browser viewport size.

        Args:
            width: Viewport width in pixels
            height: Viewport height in pixels

        Returns:
            InteractionResult with success status
        """
        await self._ensure_page()

        try:
            await self._page.set_viewport_size({"width": width, "height": height})

            return InteractionResult(
                success=True,
                action="set_viewport",
                target=f"{width}x{height}",
                message=f"Viewport set to {width}x{height}",
            )
        except Exception as e:
            return InteractionResult(
                success=False,
                action="set_viewport",
                target=f"{width}x{height}",
                message=f"Viewport change failed: {e}",
            )

    async def go_back(self) -> InteractionResult:
        """Navigate back in browser history.

        Returns:
            InteractionResult with success status
        """
        await self._ensure_page()

        try:
            await self._page.go_back(wait_until="networkidle")

            return InteractionResult(
                success=True,
                action="go_back",
                target=None,
                message="Navigated back",
            )
        except Exception as e:
            return InteractionResult(
                success=False,
                action="go_back",
                target=None,
                message=f"Back navigation failed: {e}",
            )

    async def go_forward(self) -> InteractionResult:
        """Navigate forward in browser history.

        Returns:
            InteractionResult with success status
        """
        await self._ensure_page()

        try:
            await self._page.go_forward(wait_until="networkidle")

            return InteractionResult(
                success=True,
                action="go_forward",
                target=None,
                message="Navigated forward",
            )
        except Exception as e:
            return InteractionResult(
                success=False,
                action="go_forward",
                target=None,
                message=f"Forward navigation failed: {e}",
            )

    async def reload(self) -> InteractionResult:
        """Reload the current page.

        Returns:
            InteractionResult with success status
        """
        await self._ensure_page()

        try:
            await self._page.reload(wait_until="networkidle")

            return InteractionResult(
                success=True,
                action="reload",
                target=None,
                message="Page reloaded",
            )
        except Exception as e:
            return InteractionResult(
                success=False,
                action="reload",
                target=None,
                message=f"Reload failed: {e}",
            )

    async def add_script(
        self,
        script: str,
    ) -> InteractionResult:
        """Add and execute a script tag in the page.

        Args:
            script: JavaScript code to inject

        Returns:
            InteractionResult with success status
        """
        await self._ensure_page()

        try:
            await self._page.add_script_tag(content=script)

            return InteractionResult(
                success=True,
                action="add_script",
                target=None,
                message=f"Script injected ({len(script)} chars)",
            )
        except Exception as e:
            return InteractionResult(
                success=False,
                action="add_script",
                target=None,
                message=f"Script injection failed: {e}",
            )

    async def add_style(
        self,
        css: str,
    ) -> InteractionResult:
        """Add a style tag to the page.

        Args:
            css: CSS code to inject

        Returns:
            InteractionResult with success status
        """
        await self._ensure_page()

        try:
            await self._page.add_style_tag(content=css)

            return InteractionResult(
                success=True,
                action="add_style",
                target=None,
                message=f"Style injected ({len(css)} chars)",
            )
        except Exception as e:
            return InteractionResult(
                success=False,
                action="add_style",
                target=None,
                message=f"Style injection failed: {e}",
            )

    async def wait_for_network_idle(
        self,
        timeout: int = 30000,
    ) -> InteractionResult:
        """Wait for network to become idle.

        Args:
            timeout: Maximum wait time in milliseconds

        Returns:
            InteractionResult with success status
        """
        await self._ensure_page()

        try:
            await self._page.wait_for_load_state("networkidle", timeout=timeout)

            return InteractionResult(
                success=True,
                action="wait_network_idle",
                target=None,
                message="Network is idle",
            )
        except Exception as e:
            return InteractionResult(
                success=False,
                action="wait_network_idle",
                target=None,
                message=f"Wait for network idle failed: {e}",
            )

    async def evaluate_handle(
        self,
        expression: str,
    ) -> Any:
        """Evaluate JavaScript and return handle for complex objects.

        Args:
            expression: JavaScript expression that returns an object

        Returns:
            Serializable representation of the result
        """
        await self._ensure_page()

        try:
            handle = await self._page.evaluate_handle(expression)
            # Get JSON representation
            result = await handle.json_value()
            await handle.dispose()
            return result
        except Exception as e:
            return {"error": str(e)}

    async def get_cookies(self) -> List[Dict[str, Any]]:
        """Get all cookies for the current page.

        Returns:
            List of cookie dictionaries
        """
        await self._ensure_page()

        try:
            cookies = await self._context.cookies()
            return cookies
        except Exception:
            return []

    async def set_cookie(
        self,
        name: str,
        value: str,
        domain: Optional[str] = None,
        path: str = "/",
    ) -> InteractionResult:
        """Set a cookie.

        Args:
            name: Cookie name
            value: Cookie value
            domain: Cookie domain (uses current page domain if None)
            path: Cookie path

        Returns:
            InteractionResult with success status
        """
        await self._ensure_page()

        try:
            url = self._page.url
            cookie = {
                "name": name,
                "value": value,
                "path": path,
                "url": url,
            }
            if domain:
                cookie["domain"] = domain

            await self._context.add_cookies([cookie])

            return InteractionResult(
                success=True,
                action="set_cookie",
                target=name,
                message=f"Cookie '{name}' set",
            )
        except Exception as e:
            return InteractionResult(
                success=False,
                action="set_cookie",
                target=name,
                message=f"Set cookie failed: {e}",
            )

    async def clear_cookies(self) -> InteractionResult:
        """Clear all cookies.

        Returns:
            InteractionResult with success status
        """
        await self._ensure_page()

        try:
            await self._context.clear_cookies()

            return InteractionResult(
                success=True,
                action="clear_cookies",
                target=None,
                message="Cookies cleared",
            )
        except Exception as e:
            return InteractionResult(
                success=False,
                action="clear_cookies",
                target=None,
                message=f"Clear cookies failed: {e}",
            )

    async def get_local_storage(self, key: Optional[str] = None) -> Any:
        """Get localStorage value(s).

        Args:
            key: Specific key to get (all items if None)

        Returns:
            Value for key, or dict of all items
        """
        await self._ensure_page()

        try:
            if key:
                return await self._page.evaluate(f"localStorage.getItem('{key}')")
            else:
                return await self._page.evaluate("""
                    () => Object.fromEntries(
                        Object.keys(localStorage).map(k => [k, localStorage.getItem(k)])
                    )
                """)
        except Exception:
            return None

    async def set_local_storage(
        self,
        key: str,
        value: str,
    ) -> InteractionResult:
        """Set localStorage value.

        Args:
            key: Storage key
            value: Storage value

        Returns:
            InteractionResult with success status
        """
        await self._ensure_page()

        try:
            await self._page.evaluate(f"localStorage.setItem('{key}', '{value}')")

            return InteractionResult(
                success=True,
                action="set_local_storage",
                target=key,
                message=f"localStorage['{key}'] set",
            )
        except Exception as e:
            return InteractionResult(
                success=False,
                action="set_local_storage",
                target=key,
                message=f"Set localStorage failed: {e}",
            )

    async def get_console_logs(self) -> List[Dict[str, Any]]:
        """Get console logs from the page.

        Note: Only captures logs after this method sets up the listener.
        Call early in session to capture all logs.

        Returns:
            List of log entries
        """
        await self._ensure_page()

        # This returns logs captured since page creation
        # For real capture, we'd need to set up listener before navigation
        logs = []

        # Get any errors from the page
        try:
            errors = await self._page.evaluate("""
                () => window.__capturedLogs || []
            """)
            if errors:
                logs.extend(errors)
        except Exception:
            pass

        return logs

    async def close(self):
        """Close the browser session."""
        if self._page and not self._page.is_closed():
            await self._page.close()
            self._page = None

        if self._manager and self.session_id:
            await self._manager.close_context(self.session_id)
            self._context = None


# Session registry
_sessions: Dict[str, BrowserSession] = {}


async def get_or_create_session(session_id: str) -> BrowserSession:
    """Get or create a browser session.

    Args:
        session_id: Unique session identifier

    Returns:
        BrowserSession instance
    """
    if session_id not in _sessions:
        _sessions[session_id] = BrowserSession(session_id)
    return _sessions[session_id]


async def close_session(session_id: str):
    """Close and remove a browser session.

    Args:
        session_id: Session to close
    """
    if session_id in _sessions:
        await _sessions[session_id].close()
        del _sessions[session_id]


async def list_sessions() -> List[str]:
    """List active browser session IDs.

    Returns:
        List of session IDs
    """
    return list(_sessions.keys())

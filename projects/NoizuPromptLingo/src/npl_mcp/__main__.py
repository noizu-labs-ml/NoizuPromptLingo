#!/usr/bin/env python3
"""Main entry point for running the MCP server directly.

This allows `python -m npl_mcp` to start the server.
"""

import sys

from npl_mcp.launcher import main

if __name__ == "__main__":
    main()
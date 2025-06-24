# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Lua-based TUI (Text User Interface) text browser application built with the Hype framework. The browser features an address bar at the bottom and displays formatted content (starting with JSON) in the main area.

## Running the Code

To run the TUI text browser:
```bash
lua hello.lua
```

## Architecture

The application uses a vertical flex layout with two main components:
- **Content View** (top): Scrollable text area that displays formatted content with color syntax highlighting
- **Address Input** (bottom): Input field for entering URLs, responds to Enter key

Key components:
- `tui.newFlex()` with column direction for vertical layout
- `tui.newTextView()` for the main content display with scrolling and dynamic colors
- `tui.newInputField()` for the address bar with enter key handling
- Custom JSON formatter with syntax highlighting using TUI color codes

## Features

- JSON formatting with proper indentation and syntax highlighting
- Color-coded output (cyan for keys, green for strings, yellow for numbers, red for booleans)
- Responsive layout with address bar fixed at bottom
- Keyboard navigation (Enter to submit URL)
- Scrollable content area for large responses

## Development Notes

- Uses Hype's built-in HTTP client with `http.get()` for fetching URLs
- Automatically detects and formats JSON responses with syntax highlighting
- Falls back to plain text display for non-JSON content
- Comprehensive error handling for network failures and HTTP errors
- TUI framework provides cross-platform terminal interface
- No external dependencies beyond Hype's built-in libraries

## HTTP Integration

The browser uses Hype's HTTP module:
- `http.get(url, callback)` for making HTTP requests
- Async callback pattern with error handling
- Response object contains `status`, `body`, and other HTTP response data
- Supports any URL that returns text or JSON content
---
description: This is an extremly helpful tool that allows you to analyze the logs of the current `next dev` browser instance and capture screenshots of it, etc.
globs: 
alwaysApply: false
---
# Browser Tools MCP Server

This document outlines the features and activation for the Browser Tools MCP server.

## Activation

To activate the Browser Tools MCP server, run the following command in your terminal:

```bash
pnpm dlx @agentdeskai/browser-tools-mcp@1.2.0
```

## Features

### Analyzing Logs for Debugging & Validation

- **Get Console Logs**: Returns the most recent console logs.
- **Get Console Errors**: Returns the most recent console errors.
- **Get XHR Network Logs**: Returns all of the most recent XHR requests that resulted in an HTTP success response code (e.g., 200 or 300).
- **Get XHR Network Errors**: Returns the most recent XHR requests that returned a 400 or 500 HTTP error response code.

Example Usage: _"Can you check console and network logs to see what went wrong?"_ The agent will automatically use all four tools if you ask this when debugging.

- **Wipe Logs**: Deletes all logs stored on the server.

Example Usage: _"Wipe the logs"_ The agent will delete all logs stored in the server so that you have a fresh slate for debugging. This is useful if you don't want to refresh the browser to reset/wipe your logs.

### Updating & Debugging UI Components

- **Capture Screenshot**: Sends a screenshot to `/user/Downloads/mcp-screenshots` (by default).

Example Usage: _"Something doesn't look right in the UI. Can you take a screenshot?"_

_Suggestion:_ Set a custom path in the dev tools panel so screenshots are sent directly to the AI code editor's workspace/current project. Then you can easily drag and drop screenshots into your AI chat interface.

- **Get currently selected element**: Returns the currently selected element.

Example Usage: _"Can you edit the currently selected element to do x, y and z?"_

When using the Chrome DevTools, you can use the Element Selector tool to select any component in your UI. After selecting an element, you'll be able to ask the agent to edit or find the currently selected element in your code. This makes traversing through a codebase and making UI changes much easier.

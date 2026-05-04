# Portwarden

Portwarden is a macOS menu bar app for viewing active TCP listening ports and terminating the owning process.

It combines:

- a Zig core library that enumerates listening ports via macOS process APIs
- a SwiftUI macOS app that displays the results in a menu bar window

## What it does

- Lists active listening IPv4 TCP ports
- Shows the process name, port number, and PID
- Lets you refresh the list
- Lets you send `SIGTERM` to a selected process
- Runs as a `MenuBarExtra` app in the macOS menu bar

## Project structure

- `core/ports.zig` — Zig scanner implementation exported for Swift
- `build.zig` — Zig build that produces the executable, static library, and generated header
- `macos/portwarden/` — Xcode/macOS app project
- `macos/portwarden/portwarden/PortScanner.swift` — Swift wrapper around the Zig bridge
- `macos/portwarden/portwarden/PortViewModel.swift` — app state and refresh/kill actions
- `macos/portwarden/portwarden/portwardenApp.swift` — menu bar UI entry point

## Requirements

- macOS
- [Zig](https://ziglang.org/) installed
- Xcode / Xcode Command Line Tools

This project uses macOS-specific APIs such as `libproc`, so it is not intended to run on Linux or Windows.

## How it works

The Zig layer exports C-callable functions:

- `scanner_init()`
- `scanner_deinit()`
- `get_ports(out_len)`

The Swift app calls those functions to fetch port/process data and render it in the UI.
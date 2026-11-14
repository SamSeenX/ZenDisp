# BRAIN.md - Architecture and Decisions

## Core Architecture

ZenDisp is a native Swift menu bar application for macOS 13+ (Ventura and newer).

* **Language and Frameworks:** Swift 5.9+ with AppKit, ScreenCaptureKit, QuartzCore, Metal, and IOKit.
* **Virtual Display Engine:** Invokes `CGVirtualDisplayDescriptor`, `CGVirtualDisplayMode`, and `CGVirtualDisplay` via Objective-C runtime reflection (`NSClassFromString`). Unique serial identifiers prevent WindowServer mode caching.
* **Stream Viewer (PiP):** Uses ScreenCaptureKit (`SCStream`) with 60 fps `kCVPixelFormatType_32BGRA` zero-copy `IOSurface` frames bound to `CALayer` for GPU-accelerated scaling.
* **Input Translation:** Mouse coordinate mapping and synthetic event taps forward cursor and keyboard interactions to the virtual display.
* **DDC and Dimming:** `IOAVService` over I2C on Apple Silicon for hardware VCP 0x10 luminance control, with gamma table fallback via `CGSetDisplayTransferByTable`.

## Key Technical Decisions

* Zero third-party dependencies to keep memory consumption under 30 MB.
* Strict modularity with each source file under 200 lines.
* Ad-hoc code signing and manual bundle structure via `scripts/build_app.sh` allowing direct CLI compilation without requiring Xcode GUI.

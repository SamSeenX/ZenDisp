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
* Strict modularity with each source file under 200 lines (target under 180 lines).
* Dual Menu Bar and Dock presence (LSUIElement = false) with custom AppIcon.icns compiled from vector SVG.
* Frosted glass vibrancy (NSVisualEffectView with hudWindow material) and card-based modular component architecture for Preferences UI.
* Menu Bar Controller: Dedicated MenuBarController builds interactive status menus showing live virtual displays, individual window teardown controls, and seamless HiDPI hot-reloading with geometry preservation.
* Custom Layout Snapshots: Dynamic layout capture serializes active virtual monitors, their DPI states, and exact window coordinates into persistent LayoutGroups.
* Ad-hoc or local trusted keychain certificate code signing and manual bundle structure via `scripts/build_app.sh` allowing direct CLI compilation without requiring Xcode GUI.

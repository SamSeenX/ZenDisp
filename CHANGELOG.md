# CHANGELOG.md

All notable updates and milestones for ZenDisp are documented here.

## [0.3.0] - 2026-11-16
### Added
* Replaced synthetic event simulation with CursorRouter snap-to-virtual cursor teleportation.
* Added automatic cursor release to host display on three-finger Space swipe via NSWorkspace activeSpaceDidChangeNotification.
* Added manual cursor release hotkey (Option + Escape or Command + Escape) to jump cursor back to the host display instantly.
* Added Release Cursor to Main Screen menu item in status menu.

## [0.2.2] - 2026-11-14
### Fixed
* Fixed TCC permission loop by binding ad-hoc code signature directly to designated requirement identifier "com.samseen.ZenDisp".
* Added NSScreenCaptureUsageDescription to Info.plist.
* Updated build pipeline to install directly into /Applications/ZenDisp.app and strip Gatekeeper quarantine attributes (xattr -cr) to eliminate App Translocation.

## [0.2.1] - 2026-11-14
### Fixed
* Added preflight checks (CGPreflightScreenCaptureAccess and AXIsProcessTrusted) to prevent repetitive authorization prompts on launch once granted.
* Applied stable bundle identifier (com.samseen.ZenDisp) during ad-hoc codesigning to preserve macOS TCC permissions across builds.
* Refactored menu creation in AppDelegate to keep source files under 150 lines.

## [0.2.0] - 2026-11-14
### Added
* Enabled live mouse cursor capture on the PiP stream via ScreenCaptureKit.
* Implemented direct mouse click and drag forwarding in InputForwarder, translating local window coordinates to the virtual display global coordinate space.
* Added support for left click, right click, dragging, and scroll wheel directly inside the PiP stream window.

## [0.1.1] - 2026-11-14
### Fixed
* Replaced Swift protocol casting with native Key-Value Coding and direct C function pointers to resolve SIGABRT abort during virtual display instantiation.
* Added explicit macOS system authorization triggers for Screen Recording (CGRequestScreenCaptureAccess) and Accessibility (AXIsProcessTrustedWithOptions) on launch.

## [0.1.0] - 2026-11-14
### Added
* Dynamic CGVirtualDisplay engine supporting 1600x900, 1080p, and 1440p presets.
* ScreenCaptureKit stream receiver using zero-copy IOSurface frames.
* Picture-in-Picture floating window with GPU aspect-fit downscaling and full-screen toggle.
* NSStatusBar menu bar interface with dynamic state display and hotkey triggers.
* Emergency panic reset hotkey (Option + Command + Control + R) for teardown and ColorSync restore.
* Build script with ad-hoc signing producing standalone ZenDisp.app bundle.

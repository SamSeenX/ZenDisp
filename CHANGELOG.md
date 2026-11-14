# CHANGELOG.md

All notable updates and milestones for ZenDisp are documented here.

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

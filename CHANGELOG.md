# CHANGELOG.md

All notable updates and milestones for ZenDisp are documented here.

## [0.5.9] - 2026-11-16
### Added
* Replaced legacy text menu with a modern macOS Control Center popover (NSPopover with vibrant NSVisualEffectView).
* Built interactive ActiveDisplayCard with inline power toggle switches, live resolution labels, and 1x/2x/3x scale pills.
* Added Delete / Remove options for custom saved layouts both inside the Control Center popover and in the Preferences Layouts tab.
* Fixed Release Cursor menu keybind to properly display and register Control + Escape (⌃⎋).
* Published official GitHub Release v0.5.8 with downloadable ZenDisp.dmg binary asset.

## [0.5.8] - 2026-11-16
### Added
* Implemented multi-density DPI scaling with 1x Standard, 2x Retina HiDPI, and 3x Ultra HiDPI modes.
* Interactive 1x/2x/3x scale switcher in the menu bar dropdown under each running virtual display with instant live hot-reloading.
* Added 3-way segmented control in Preferences display cards and custom resolution form for configuring default scale factors.
* Proportional framebuffer backing store generation in VirtualDisplayManager (1920x1080 at 1x, 3840x2160 at 2x, 5760x3240 at 3x) for super-sampling.

## [0.5.7] - 2026-11-16
### Added
* Built MenuBarController providing interactive menu bar controls with live status indicators for running virtual displays.
* Added per-display submenus in the status menu with instant HiDPI toggles (2x Retina vs 1x) and individual window close buttons.
* Implemented live hot-reloading for running virtual displays, seamlessly recreating the display in the new DPI mode while preserving exact window positions.
* Added "Save Current Layout as Preset..." menu option with native modal naming dialog, snapshotting active displays and custom window coordinates into reusable layout groups.
* True 2x Retina backing store mode generation in VirtualDisplayManager for razor-sharp HiDPI text and UI rendering.
* Completely purged legacy tag metadata from git history and pushed clean annotated tags to origin.

## [0.5.6] - 2026-11-16
### Fixed
* Elevated SettingsWindowController window level above floating PiP stream windows (floatingWindow + 1) with orderFrontRegardless so Preferences and reference panels always appear in front of virtual displays.

## [0.5.5] - 2026-11-16
### Added
* Implemented individual HiDPI toggle for every display preset and custom resolution form, allowing independent switching between Retina 2x and 1x Standard DPI.
* Built automated DMG packaging pipeline in scripts/create_dmg.sh with /Applications symlink for 1-click drag-and-drop installation.
* Redesigned README.md as a consumer-facing product showcase with feature breakdowns, shortcuts cheat sheet, and precompiled DMG download links.

### Fixed
* Fixed background virtual display leak by adopting takeRetainedValue() on CoreGraphics Objective-C +alloc calls, ensuring displays automatically terminate from WindowServer and BetterDisplay immediately upon closing their PiP stream window.

## [0.5.4] - 2026-11-16
### Added
* Built WindowStateManager providing automatic window frame persistence for individual display presets and multi-screen layout group slots.
* StreamWindowController restores exact saved position, scale, and aspect ratio on spawn, and continuously persists window movements and live resizing.
* Added off-screen safety validation against NSScreen.screens to ensure windows never restore outside visible display bounds.
* Integrated cache clearing into panic reset (⌥⌘⌃R) so an emergency reset completely restores clean default auto-tiled layout geometry.

## [0.5.3] - 2026-11-16
### Fixed
* Fixed Light Mode theme inversion by enforcing darkAqua appearance on SettingsWindow so buttons, segmented tabs, and text fields always render with high contrast.
* Resolved inverted custom resolution form layout by wrapping the card container in a flipped NSView subclass.
* Fixed build script self-termination bug by using exact binary process targeting (pkill -x).

### Added
* Configured new default layout groups: Side-by-Side Dual Workstation (1:1 equal 1080p split) and Developer Coding Suite (3:2 coding IDE screen + 9:16 narrow tall vertical screen).
* Added 1920x1280 (Coding 3:2) and 1080x1920 (Tall Portrait 9:16) default display presets with dynamic aspect ratio labels.
* Upgraded StreamWindowController to calculate true aspect ratios (supporting portrait and 3:2) and automatically tile multi-screen windows side-by-side.

## [0.5.2] - 2026-11-16
### Fixed
* Converted PresetRowCard and custom container from NSBox to layer-backed NSView with flipped coordinates (isFlipped = true), completely removing AppKit NSBox bezel clipping.
* Re-architected typography contrast: pure white bold titles (#ffffff), silver subtitle tags (#d8d8d8), and vibrant electric-cyan headers (#70c4ff).
* Added rich dark backing layer (NSColor(red: 0.08, green: 0.10, blue: 0.14, alpha: 0.88)) behind window shell to eliminate desktop wallpaper bleed-through while preserving border frosted glass vibrancy.
* Standardized 64 pt card heights with generous 22 to 24 pt label frames, preventing font ascender truncation.

## [0.5.1] - 2026-11-16
### Fixed
* Resolved vertical text and button clipping inside PresetRowCard by expanding card height to 60 pt and rebalancing label coordinates.
* Expanded action button widths (Spawn 95 pt, Remove 98 pt) to prevent label truncation to "Remo...".
* Fixed clipping of "ADD CUSTOM RESOLUTION" container header by expanding box height to 140 pt with generous top margins.
* Suppressed unwanted green focus ring on segmented tab switcher by configuring focusRingType to none.

## [0.5.0] - 2026-11-16
### Added
* Compiled multi-resolution AppIcon.icns from vector SVG and integrated into application bundle.
* Configured Info.plist with CFBundleIconFile and enabled Dock presence (LSUIElement = false) so ZenDisp displays in the macOS Dock and application switcher.
* Implemented applicationShouldHandleReopen in AppDelegate to show Preferences upon clicking the Dock icon.
* Redesigned Preferences window using frosted glass vibrancy (NSVisualEffectView), custom segmented header, and dark translucent cards.
* Extracted PresetRowCard into a dedicated component with SF Symbol glyphs, specs pill tags, and styled action buttons.
* Styled Layouts and Navigation tabs with card containers, SF Symbols, and monospaced keycap badges.
* Maintained strict code modularity with all Swift files under 160 lines.

## [0.4.1] - 2026-11-16
### Added
* Built scrollable screen configurations list in DisplaysTabView with individual Spawn and Remove buttons.
* Added inline Add Custom Configuration form with custom Width, Height, and Name fields.
* Proactively modularized preferences into DisplaysTabView, LayoutsTabView, and NavigationTabView to keep all files under 170 lines.

## [0.4.0] - 2026-11-16
### Added
* Upgraded to Multi-Display architecture supporting multiple simultaneous virtual displays.
* Automatic PiP Stream Window creation for every newly spawned virtual monitor.
* Added PresetManager with custom resolution storage and one-click Layout Groups.
* Built tabbed Preferences window with Virtual Displays, Layout Groups, and Navigation controls.
* Created minimalist vector AppIcon.svg with dual nested displays in cyan and violet gradients.

## [0.3.2] - 2026-11-16
### Fixed
* Changed cursor release hotkey to Control + Escape (⌃⎋) to prevent conflicts with macOS Accessibility Spoken Content.
* Silenced startup Accessibility permission dialogs by removing forced prompts from applicationDidFinishLaunching.
* Added native SettingsWindowController for viewing shortcuts, navigation instructions, and privacy controls.

## [0.3.1] - 2026-11-16
### Fixed
* Generated and trusted local code signing certificate ZenDisp Local in login keychain to ensure macOS TCC permanently persists Screen Recording permissions across relaunches.
* Removed tccutil reset command from build script to prevent wiping user permissions during installs.
* Added NSEvent addLocalMonitorForEvents in AppDelegate to capture Option + Escape hotkey when the full-screen Stream Viewer is focused.
* Made releaseToHost in CursorRouter unconditional to guarantee mouse returns to primary display center.

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

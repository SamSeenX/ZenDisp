import Cocoa
import Carbon

public final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private var statusItem: NSStatusItem!
    private let statusMenu = NSMenu()
    private var eventMonitor: Any?
    private var localMonitor: Any?
    
    public func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupMenu()
        setupPanicHotkey()
        requestSystemPermissions()
    }
    
    private func requestSystemPermissions() {
        // Do not pop modal dialogs on launch.
        // ScreenCaptureKit triggers permission on stream start.
    }
    
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.title = "ZenDisp"
            button.image = NSImage(systemSymbolName: "display.2", accessibilityDescription: "ZenDisp")
            button.imagePosition = .imageLeading
        }
        statusItem.menu = statusMenu
        statusMenu.delegate = self
    }
    
    @discardableResult
    private func addItem(_ title: String, action: Selector?, key: String = "", enabled: Bool = true) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: key)
        item.target = self
        item.isEnabled = enabled
        statusMenu.addItem(item)
        return item
    }

    private func setupMenu() {
        statusMenu.removeAllItems()
        addItem("ZenDisp v1.0", action: nil, enabled: false)
        let isAct = VirtualDisplayManager.shared.isDisplayActive
        let statusTitle = isAct ? "Status: Active (\(VirtualDisplayManager.shared.activePreset?.name ?? "Virtual"))" : "Status: No Virtual Display"
        addItem(statusTitle, action: nil, enabled: false)
        statusMenu.addItem(NSMenuItem.separator())
        
        addItem("Spawn 1600x900 Display", action: #selector(spawn900p), key: "1")
        addItem("Spawn 1920x1080 Display", action: #selector(spawn1080p), key: "2")
        addItem("Spawn 2560x1440 Display", action: #selector(spawn1440p), key: "3")
        addItem("Teardown Virtual Display", action: #selector(teardownActiveDisplay), key: "t", enabled: isAct)
        statusMenu.addItem(NSMenuItem.separator())
        
        let isVis = StreamWindowController.shared.isWindowVisible
        addItem("Open PiP Viewer", action: #selector(openPiPViewer), key: "p", enabled: isAct)
        addItem("Close PiP Viewer", action: #selector(closePiPViewer), key: "w", enabled: isVis)
        addItem("Toggle Full-Screen Stream", action: #selector(toggleFullScreen), key: "f", enabled: isVis)
        addItem("Release Cursor to Main Screen (⌃⎋)", action: #selector(releaseCursor), key: "\u{1b}", enabled: isAct)
        statusMenu.addItem(NSMenuItem.separator())
        
        addItem("Preferences...", action: #selector(openPreferences), key: ",")
        addItem("Check System Permissions...", action: #selector(checkPermissionsMenu))
        let panic = addItem("Panic Reset All (⌥⌘⌃R)", action: #selector(panicReset), key: "r")
        panic.keyEquivalentModifierMask = [.option, .command, .control]
        statusMenu.addItem(NSMenuItem.separator())
        addItem("Quit ZenDisp", action: #selector(quitApp), key: "q")
    }
    
    public func menuWillOpen(_ menu: NSMenu) {
        setupMenu()
    }
    
    @objc private func spawn900p() {
        spawnDisplay(preset: .preset900p)
    }
    
    @objc private func spawn1080p() {
        spawnDisplay(preset: .preset1080p)
    }
    
    @objc private func spawn1440p() {
        spawnDisplay(preset: .preset1440p)
    }
    
    private func spawnDisplay(preset: DisplayPreset) {
        let success = VirtualDisplayManager.shared.createDisplay(preset: preset)
        if success, let displayID = VirtualDisplayManager.shared.activeDisplayID {
            StreamWindowController.shared.showStream(displayID: displayID)
        }
        setupMenu()
    }
    
    @objc private func teardownActiveDisplay() {
        StreamWindowController.shared.closeStream()
        VirtualDisplayManager.shared.teardownDisplay()
        setupMenu()
    }
    
    @objc private func openPiPViewer() {
        guard let displayID = VirtualDisplayManager.shared.activeDisplayID else { return }
        StreamWindowController.shared.showStream(displayID: displayID)
        setupMenu()
    }
    
    @objc private func closePiPViewer() {
        StreamWindowController.shared.closeStream()
        setupMenu()
    }
    
    @objc private func toggleFullScreen() {
        StreamWindowController.shared.toggleFullScreen()
    }
    
    @objc private func checkPermissionsMenu() {
        if #available(macOS 11.0, *) {
            _ = CGRequestScreenCaptureAccess()
        }
        let opts = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(opts)
    }

    @objc private func openPreferences() {
        SettingsWindowController.shared.showWindow()
    }
    
    @objc private func releaseCursor() {
        CursorRouter.shared.releaseToHost()
    }

    @objc private func panicReset() {
        CursorRouter.shared.reset()
        StreamWindowController.shared.closeStream()
        VirtualDisplayManager.shared.teardownDisplay()
        CGDisplayRestoreColorSyncSettings()
        setupMenu()
    }
    
    private func setupPanicHotkey() {
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            if flags == [.option, .command, .control] && event.keyCode == 15 {
                DispatchQueue.main.async { self?.panicReset() }
            } else if flags.contains(.control) && event.keyCode == 53 {
                DispatchQueue.main.async { self?.releaseCursor() }
            }
        }
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            if flags.contains(.control) && event.keyCode == 53 {
                DispatchQueue.main.async { self?.releaseCursor() }
                return nil
            }
            return event
        }
    }
    
    @objc private func quitApp() {
        panicReset()
        NSApp.terminate(nil)
    }
    
    public func applicationWillTerminate(_ notification: Notification) {
        panicReset()
    }
}

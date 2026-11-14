import Cocoa
import Carbon

public final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private var statusItem: NSStatusItem!
    private let statusMenu = NSMenu()
    private var eventMonitor: Any?
    
    public func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupMenu()
        setupPanicHotkey()
        requestSystemPermissions()
    }
    
    private func requestSystemPermissions() {
        if #available(macOS 11.0, *) {
            _ = CGRequestScreenCaptureAccess()
        }
        let opts = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(opts)
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
    
    private func setupMenu() {
        statusMenu.removeAllItems()
        
        let headerItem = NSMenuItem(title: "ZenDisp v1.0", action: nil, keyEquivalent: "")
        headerItem.isEnabled = false
        statusMenu.addItem(headerItem)
        
        let isDisplayActive = VirtualDisplayManager.shared.isDisplayActive
        let statusTitle = isDisplayActive
            ? "Status: Active (\(VirtualDisplayManager.shared.activePreset?.name ?? "Virtual"))"
            : "Status: No Virtual Display"
        let currentStatusItem = NSMenuItem(title: statusTitle, action: nil, keyEquivalent: "")
        currentStatusItem.isEnabled = false
        statusMenu.addItem(currentStatusItem)
        
        statusMenu.addItem(NSMenuItem.separator())
        
        let p900 = NSMenuItem(title: "Spawn 1600x900 Display", action: #selector(spawn900p), keyEquivalent: "1")
        p900.target = self
        statusMenu.addItem(p900)
        
        let p1080 = NSMenuItem(title: "Spawn 1920x1080 Display", action: #selector(spawn1080p), keyEquivalent: "2")
        p1080.target = self
        statusMenu.addItem(p1080)
        
        let p1440 = NSMenuItem(title: "Spawn 2560x1440 Display", action: #selector(spawn1440p), keyEquivalent: "3")
        p1440.target = self
        statusMenu.addItem(p1440)
        
        let teardown = NSMenuItem(title: "Teardown Virtual Display", action: #selector(teardownActiveDisplay), keyEquivalent: "t")
        teardown.target = self
        teardown.isEnabled = isDisplayActive
        statusMenu.addItem(teardown)
        
        statusMenu.addItem(NSMenuItem.separator())
        
        let openPip = NSMenuItem(title: "Open PiP Viewer", action: #selector(openPiPViewer), keyEquivalent: "p")
        openPip.target = self
        openPip.isEnabled = isDisplayActive
        statusMenu.addItem(openPip)
        
        let closePip = NSMenuItem(title: "Close PiP Viewer", action: #selector(closePiPViewer), keyEquivalent: "w")
        closePip.target = self
        closePip.isEnabled = StreamWindowController.shared.isWindowVisible
        statusMenu.addItem(closePip)
        
        let fullScreen = NSMenuItem(title: "Toggle Full-Screen Stream", action: #selector(toggleFullScreen), keyEquivalent: "f")
        fullScreen.target = self
        fullScreen.isEnabled = StreamWindowController.shared.isWindowVisible
        statusMenu.addItem(fullScreen)
        
        statusMenu.addItem(NSMenuItem.separator())
        
        let permItem = NSMenuItem(title: "Check System Permissions...", action: #selector(checkPermissionsMenu), keyEquivalent: "")
        permItem.target = self
        statusMenu.addItem(permItem)
        
        let panicItem = NSMenuItem(title: "Panic Reset All (⌥⌘⌃R)", action: #selector(panicReset), keyEquivalent: "r")
        panicItem.keyEquivalentModifierMask = [.option, .command, .control]
        panicItem.target = self
        statusMenu.addItem(panicItem)
        
        statusMenu.addItem(NSMenuItem.separator())
        
        let quitItem = NSMenuItem(title: "Quit ZenDisp", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        statusMenu.addItem(quitItem)
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
        requestSystemPermissions()
    }
    
    @objc private func panicReset() {
        StreamWindowController.shared.closeStream()
        VirtualDisplayManager.shared.teardownDisplay()
        CGDisplayRestoreColorSyncSettings()
        setupMenu()
    }
    
    private func setupPanicHotkey() {
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            if flags == [.option, .command, .control] && event.keyCode == 15 {
                DispatchQueue.main.async {
                    self?.panicReset()
                }
            }
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

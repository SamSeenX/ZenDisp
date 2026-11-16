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
        addItem("ZenDisp Multi-Display", action: nil, enabled: false)
        let count = VirtualDisplayManager.shared.activeCount
        let statusTitle = count > 0 ? "Active Virtual Displays: \(count)" : "No Active Virtual Displays"
        addItem(statusTitle, action: nil, enabled: false)
        statusMenu.addItem(NSMenuItem.separator())
        
        for preset in PresetManager.shared.allPresets {
            let item = NSMenuItem(title: "Spawn \(preset.name)", action: #selector(spawnPresetAction(_:)), keyEquivalent: "")
            item.representedObject = preset
            item.target = self
            statusMenu.addItem(item)
        }
        
        let groups = PresetManager.shared.layoutGroups
        if !groups.isEmpty {
            statusMenu.addItem(NSMenuItem.separator())
            let groupMenu = NSMenu()
            for group in groups {
                let gItem = NSMenuItem(title: "Launch \(group.name) (\(group.presets.count) screens)", action: #selector(launchGroupAction(_:)), keyEquivalent: "")
                gItem.representedObject = group
                gItem.target = self
                groupMenu.addItem(gItem)
            }
            let groupParent = NSMenuItem(title: "Layout Groups", action: nil, keyEquivalent: "")
            groupParent.submenu = groupMenu
            statusMenu.addItem(groupParent)
        }
        
        statusMenu.addItem(NSMenuItem.separator())
        addItem("Teardown All Displays", action: #selector(teardownAllAction), key: "t", enabled: count > 0)
        addItem("Release Cursor to Main Screen (⌃⎋)", action: #selector(releaseCursor), key: "\u{1b}", enabled: count > 0)
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
    
    @objc private func spawnPresetAction(_ sender: NSMenuItem) {
        if let preset = sender.representedObject as? DisplayPreset {
            _ = VirtualDisplayManager.shared.createDisplay(preset: preset)
            setupMenu()
        }
    }
    
    @objc private func launchGroupAction(_ sender: NSMenuItem) {
        if let group = sender.representedObject as? LayoutGroup {
            VirtualDisplayManager.shared.launchGroup(group)
            setupMenu()
        }
    }
    
    @objc private func teardownAllAction() {
        VirtualDisplayManager.shared.teardownAllDisplays()
        CursorRouter.shared.reset()
        setupMenu()
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
        VirtualDisplayManager.shared.teardownAllDisplays()
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

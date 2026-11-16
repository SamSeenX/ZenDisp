import Cocoa
import Carbon

public final class MenuBarController: NSObject, NSMenuDelegate {
    public static let shared = MenuBarController()
    private var statusMenu: NSMenu?
    
    private override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(dataDidChange), name: PresetManager.didChangeNotification, object: nil)
    }
    
    @objc private func dataDidChange() {
        if let menu = statusMenu {
            buildMenu(menu)
        }
    }
    
    public func menuWillOpen(_ menu: NSMenu) {
        buildMenu(menu)
    }
    
    @discardableResult
    private func addItem(_ menu: NSMenu, title: String, action: Selector?, key: String = "", obj: Any? = nil) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: key)
        item.target = self
        item.representedObject = obj
        menu.addItem(item)
        return item
    }
    
    public func buildMenu(_ menu: NSMenu) {
        self.statusMenu = menu
        menu.removeAllItems()
        
        let header = addItem(menu, title: "ZenDisp Multi-Display", action: nil)
        header.isEnabled = false
        
        let activeList = VirtualDisplayManager.shared.activeDisplaysList()
        let count = activeList.count
        let countItem = addItem(menu, title: count > 0 ? "Active Virtual Displays (\(count))" : "No Active Displays", action: nil)
        countItem.isEnabled = false
        menu.addItem(NSMenuItem.separator())
        
        if count > 0 {
            for (id, preset) in activeList {
                let dispItem = addItem(menu, title: "🟢 \(preset.name) • \(preset.scaleLabel)", action: nil)
                let sub = NSMenu()
                let scales: [(UInt, String)] = [
                    (1, "1x Standard (1080p Backing)"),
                    (2, "2x HiDPI Retina (4K Backing)"),
                    (3, "3x HiDPI Ultra (6K Backing)")
                ]
                for (s, label) in scales {
                    let check = preset.scaleFactor == s ? "✓ " : "    "
                    let item = addItem(sub, title: "\(check)\(label)", action: #selector(setActiveScaleAction(_:)), obj: [id, s])
                    if preset.scaleFactor == s { item.state = .on }
                }
                sub.addItem(NSMenuItem.separator())
                addItem(sub, title: "Close This Window", action: #selector(closeActiveDisplay(_:)), obj: id)
                dispItem.submenu = sub
            }
            addItem(menu, title: "Save Current Layout as Preset...", action: #selector(saveLayoutAction))
            addItem(menu, title: "Teardown All Displays", action: #selector(teardownAllAction), key: "t")
            addItem(menu, title: "Release Cursor to Main Screen (⌃⎋)", action: #selector(releaseCursor), key: "\u{1b}")
            menu.addItem(NSMenuItem.separator())
        }
        
        let presetParent = addItem(menu, title: "Display Presets", action: nil)
        let presetSub = NSMenu()
        for preset in PresetManager.shared.allPresets {
            let modeStr = preset.isHiDPI ? "HiDPI" : "1x"
            addItem(presetSub, title: "\(preset.name) (\(modeStr))", action: #selector(spawnPresetAction(_:)), obj: preset)
        }
        presetParent.submenu = presetSub
        
        let groups = PresetManager.shared.layoutGroups
        if !groups.isEmpty {
            let groupParent = addItem(menu, title: "Layout Groups", action: nil)
            let groupMenu = NSMenu()
            for group in groups {
                addItem(groupMenu, title: "Launch \(group.name) (\(group.presets.count) screens)", action: #selector(launchGroupAction(_:)), obj: group)
            }
            groupParent.submenu = groupMenu
        }
        
        menu.addItem(NSMenuItem.separator())
        addItem(menu, title: "Preferences...", action: #selector(openPreferences), key: ",")
        addItem(menu, title: "Check System Permissions...", action: #selector(checkPermissionsMenu))
        let panic = addItem(menu, title: "Panic Reset All (⌥⌘⌃R)", action: #selector(panicReset), key: "r")
        panic.keyEquivalentModifierMask = [.option, .command, .control]
        menu.addItem(NSMenuItem.separator())
        addItem(menu, title: "Quit ZenDisp", action: #selector(quitApp), key: "q")
    }
    
    @objc private func setActiveScaleAction(_ sender: NSMenuItem) {
        guard let arr = sender.representedObject as? [Any],
              let id = arr[0] as? CGDirectDisplayID,
              let scale = arr[1] as? UInt else { return }
        VirtualDisplayManager.shared.setScale(scale, for: id)
    }
    
    @objc private func toggleActiveDisplayHiDPI(_ sender: NSMenuItem) {
        guard let id = sender.representedObject as? CGDirectDisplayID else { return }
        VirtualDisplayManager.shared.toggleHiDPI(for: id)
    }
    
    @objc private func closeActiveDisplay(_ sender: NSMenuItem) {
        guard let id = sender.representedObject as? CGDirectDisplayID else { return }
        VirtualDisplayManager.shared.teardownDisplay(id: id)
    }
    
    @objc private func saveLayoutAction() {
        let alert = NSAlert()
        alert.messageText = "Save Workspace Layout"
        alert.informativeText = "Enter a name for this multi-display preset:"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Save")
        alert.addButton(withTitle: "Cancel")
        let input = NSTextField(frame: NSRect(x: 0, y: 0, width: 280, height: 24))
        input.stringValue = "Workspace Layout \(PresetManager.shared.layoutGroups.count + 1)"
        alert.accessoryView = input
        alert.window.initialFirstResponder = input
        
        NSApp.activate(ignoringOtherApps: true)
        if alert.runModal() == .alertFirstButtonReturn {
            let name = input.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            if !name.isEmpty { PresetManager.shared.saveCurrentLayout(name: name) }
        }
    }
    
    @objc private func spawnPresetAction(_ sender: NSMenuItem) {
        if let preset = sender.representedObject as? DisplayPreset {
            _ = VirtualDisplayManager.shared.createDisplay(preset: preset)
        }
    }
    
    @objc private func launchGroupAction(_ sender: NSMenuItem) {
        if let group = sender.representedObject as? LayoutGroup {
            VirtualDisplayManager.shared.launchGroup(group)
        }
    }
    
    @objc private func teardownAllAction() {
        VirtualDisplayManager.shared.teardownAllDisplays()
        CursorRouter.shared.reset()
    }
    
    @objc private func releaseCursor() {
        CursorRouter.shared.releaseToHost()
    }
    
    @objc private func openPreferences() {
        SettingsWindowController.shared.showWindow()
    }
    
    @objc private func checkPermissionsMenu() {
        if #available(macOS 11.0, *) {
            _ = CGRequestScreenCaptureAccess()
        }
        let opts = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(opts)
    }
    
    @objc public func panicReset() {
        WindowStateManager.shared.clearSavedFrames()
        CursorRouter.shared.reset()
        VirtualDisplayManager.shared.teardownAllDisplays()
        CGDisplayRestoreColorSyncSettings()
        if let menu = statusMenu { buildMenu(menu) }
    }
    
    @objc private func quitApp() {
        panicReset()
        NSApp.terminate(nil)
    }
}

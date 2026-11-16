import Cocoa

public final class MenuPopoverController: NSObject, NSPopoverDelegate {
    public static let shared = MenuPopoverController()
    private let popover = NSPopover()
    private let popoverView = MenuPopoverView(frame: NSRect(x: 0, y: 0, width: 340, height: 380))
    private var statusButton: NSStatusBarButton?
    
    private override init() {
        super.init()
        setupPopover()
        NotificationCenter.default.addObserver(self, selector: #selector(dataDidChange), name: PresetManager.didChangeNotification, object: nil)
    }
    
    private func setupPopover() {
        popover.behavior = .transient
        popover.delegate = self
        let vc = NSViewController()
        vc.view = popoverView
        popover.contentViewController = vc
    }
    
    public func registerButton(_ button: NSStatusBarButton) {
        self.statusButton = button
        button.target = self
        button.action = #selector(statusButtonClicked(_:))
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
    }
    
    @objc private func dataDidChange() {
        if popover.isShown {
            popoverView.rebuild()
            updatePopoverSize()
        }
    }
    
    @objc public func statusButtonClicked(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent
        if event?.type == .rightMouseUp {
            MenuBarController.shared.showMenuUnder(sender)
            return
        }
        togglePopover(sender)
    }
    
    public func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            popover.performClose(sender)
        } else if let btn = statusButton {
            popoverView.rebuild()
            updatePopoverSize()
            popover.show(relativeTo: btn.bounds, of: btn, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    private func updatePopoverSize() {
        let activeCount = VirtualDisplayManager.shared.activeCount
        let groupCount = PresetManager.shared.layoutGroups.count
        let h = 210 + CGFloat(activeCount * 84) + CGFloat(groupCount * 42)
        let finalH = min(max(h, 300), 540)
        popover.contentSize = NSSize(width: 340, height: finalH)
    }
    
    public func promptSaveLayout() {
        popover.performClose(nil)
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
}

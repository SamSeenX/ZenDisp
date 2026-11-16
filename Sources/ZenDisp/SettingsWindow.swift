import Cocoa

public final class SettingsWindowController: NSWindowController {
    public static let shared = SettingsWindowController()
    
    private var widthField: NSTextField!
    private var heightField: NSTextField!
    private var nameField: NSTextField!
    
    private init() {
        let win = NSWindow(
            contentRect: NSRect(x: 200, y: 200, width: 520, height: 380),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        win.title = "ZenDisp Preferences"
        win.isReleasedWhenClosed = false
        super.init(window: win)
        setupTabs()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTabs() {
        guard let win = window else { return }
        let tabView = NSTabView(frame: win.contentView?.bounds ?? NSRect(x: 0, y: 0, width: 520, height: 380))
        
        let tab1 = NSTabViewItem(identifier: "displays")
        tab1.label = "Virtual Displays"
        tab1.view = buildDisplaysTab()
        tabView.addTabViewItem(tab1)
        
        let tab2 = NSTabViewItem(identifier: "layouts")
        tab2.label = "Layout Groups"
        tab2.view = buildLayoutsTab()
        tabView.addTabViewItem(tab2)
        
        let tab3 = NSTabViewItem(identifier: "nav")
        tab3.label = "Navigation"
        tab3.view = buildNavigationTab()
        tabView.addTabViewItem(tab3)
        
        win.contentView = tabView
    }
    
    private func buildDisplaysTab() -> NSView {
        let view = NSView(frame: NSRect(x: 0, y: 0, width: 500, height: 340))
        
        let title = NSTextField(labelWithString: "Create Custom Resolution Display")
        title.font = NSFont.boldSystemFont(ofSize: 13)
        title.frame = NSRect(x: 20, y: 300, width: 350, height: 20)
        view.addSubview(title)
        
        let lblW = NSTextField(labelWithString: "Width:")
        lblW.frame = NSRect(x: 20, y: 265, width: 50, height: 20)
        view.addSubview(lblW)
        widthField = NSTextField(frame: NSRect(x: 75, y: 263, width: 80, height: 22))
        widthField.stringValue = "1920"
        view.addSubview(widthField)
        
        let lblH = NSTextField(labelWithString: "Height:")
        lblH.frame = NSRect(x: 175, y: 265, width: 50, height: 20)
        view.addSubview(lblH)
        heightField = NSTextField(frame: NSRect(x: 230, y: 263, width: 80, height: 22))
        heightField.stringValue = "1080"
        view.addSubview(heightField)
        
        let lblN = NSTextField(labelWithString: "Name:")
        lblN.frame = NSRect(x: 20, y: 225, width: 50, height: 20)
        view.addSubview(lblN)
        nameField = NSTextField(frame: NSRect(x: 75, y: 223, width: 235, height: 22))
        nameField.stringValue = "Custom Workspace"
        view.addSubview(nameField)
        
        let addBtn = NSButton(title: "Add & Spawn Custom Screen", target: self, action: #selector(addCustomScreen))
        addBtn.bezelStyle = .rounded
        addBtn.frame = NSRect(x: 70, y: 175, width: 245, height: 32)
        view.addSubview(addBtn)
        
        let desc = NSTextField(wrappingLabelWithString: "Every newly created virtual display automatically launches its own aspect-fit PiP window. Arrange and resize them into any custom multi-screen arrangement.")
        desc.frame = NSRect(x: 20, y: 90, width: 460, height: 60)
        desc.font = NSFont.systemFont(ofSize: 11)
        view.addSubview(desc)
        
        let teardownBtn = NSButton(title: "Teardown All Active Displays", target: self, action: #selector(teardownAll))
        teardownBtn.bezelStyle = .rounded
        teardownBtn.frame = NSRect(x: 20, y: 30, width: 240, height: 32)
        view.addSubview(teardownBtn)
        
        return view
    }
    
    private func buildLayoutsTab() -> NSView {
        let view = NSView(frame: NSRect(x: 0, y: 0, width: 500, height: 340))
        let title = NSTextField(labelWithString: "One-Click Layout Groups")
        title.font = NSFont.boldSystemFont(ofSize: 13)
        title.frame = NSRect(x: 20, y: 300, width: 300, height: 20)
        view.addSubview(title)
        
        var yPos = 240
        for (index, group) in PresetManager.shared.layoutGroups.enumerated() {
            let label = NSTextField(labelWithString: "\(group.name) (\(group.presets.count) Displays)")
            label.frame = NSRect(x: 20, y: yPos, width: 280, height: 22)
            view.addSubview(label)
            
            let btn = NSButton(title: "Launch", target: self, action: #selector(launchGroupFromBtn(_:)))
            btn.bezelStyle = .rounded
            btn.tag = index
            btn.frame = NSRect(x: 310, y: yPos - 5, width: 100, height: 32)
            view.addSubview(btn)
            yPos -= 50
        }
        return view
    }
    
    private func buildNavigationTab() -> NSView {
        let view = NSView(frame: NSRect(x: 0, y: 0, width: 500, height: 340))
        let navTitle = NSTextField(labelWithString: "Cursor Navigation & Hotkeys")
        navTitle.font = NSFont.boldSystemFont(ofSize: 13)
        navTitle.frame = NSRect(x: 20, y: 300, width: 300, height: 20)
        view.addSubview(navTitle)
        
        let hotkeyText = NSTextField(wrappingLabelWithString: "Cursor Release Shortcut:\n⌃⎋ (Control + Escape) instantly teleports your pointer back to your main monitor center.\n\nThree-Finger Swipe:\nSwiping between Spaces frees the cursor automatically.\n\nDirect Clicking:\nClick anywhere inside a PiP window to instantly snap your hardware cursor to that virtual display.")
        hotkeyText.frame = NSRect(x: 20, y: 130, width: 460, height: 150)
        hotkeyText.font = NSFont.systemFont(ofSize: 12)
        view.addSubview(hotkeyText)
        
        let permBtn = NSButton(title: "Open Privacy & Security Settings...", target: self, action: #selector(openSecuritySettings))
        permBtn.bezelStyle = .rounded
        permBtn.frame = NSRect(x: 20, y: 40, width: 260, height: 32)
        view.addSubview(permBtn)
        return view
    }
    
    @objc private func addCustomScreen() {
        let w = UInt(widthField.stringValue) ?? 1920
        let h = UInt(heightField.stringValue) ?? 1080
        let name = nameField.stringValue.isEmpty ? "\(w)x\(h)" : nameField.stringValue
        let preset = PresetManager.shared.addCustomPreset(width: w, height: h, name: name)
        _ = VirtualDisplayManager.shared.createDisplay(preset: preset)
    }
    
    @objc private func launchGroupFromBtn(_ sender: NSButton) {
        let groups = PresetManager.shared.layoutGroups
        if sender.tag >= 0 && sender.tag < groups.count {
            VirtualDisplayManager.shared.launchGroup(groups[sender.tag])
        }
    }
    
    @objc private func teardownAll() {
        VirtualDisplayManager.shared.teardownAllDisplays()
        CursorRouter.shared.reset()
    }
    
    @objc private func openSecuritySettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture") {
            NSWorkspace.shared.open(url)
        }
    }
    
    public func showWindow() {
        window?.center()
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

import Cocoa

public final class SettingsWindowController: NSWindowController {
    public static let shared = SettingsWindowController()
    
    private init() {
        let win = NSWindow(
            contentRect: NSRect(x: 200, y: 200, width: 520, height: 420),
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
        let bounds = NSRect(x: 0, y: 0, width: 520, height: 420)
        let tabView = NSTabView(frame: bounds)
        
        let tab1 = NSTabViewItem(identifier: "displays")
        tab1.label = "Virtual Displays"
        tab1.view = DisplaysTabView(frame: bounds)
        tabView.addTabViewItem(tab1)
        
        let tab2 = NSTabViewItem(identifier: "layouts")
        tab2.label = "Layout Groups"
        tab2.view = LayoutsTabView(frame: bounds)
        tabView.addTabViewItem(tab2)
        
        let tab3 = NSTabViewItem(identifier: "nav")
        tab3.label = "Navigation"
        tab3.view = NavigationTabView(frame: bounds)
        tabView.addTabViewItem(tab3)
        
        win.contentView = tabView
    }
    
    public func showWindow() {
        window?.center()
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

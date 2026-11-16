import Cocoa

public final class SettingsWindowController: NSWindowController {
    public static let shared = SettingsWindowController()
    
    private init() {
        let win = NSWindow(
            contentRect: NSRect(x: 200, y: 200, width: 440, height: 260),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        win.title = "ZenDisp Preferences"
        win.isReleasedWhenClosed = false
        super.init(window: win)
        setupUI()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        guard let win = window else { return }
        let content = NSView(frame: win.contentView?.bounds ?? NSRect(x: 0, y: 0, width: 440, height: 260))
        
        let titleLabel = NSTextField(labelWithString: "ZenDisp Keyboard & Navigation Settings")
        titleLabel.font = NSFont.boldSystemFont(ofSize: 14)
        titleLabel.frame = NSRect(x: 24, y: 210, width: 390, height: 22)
        content.addSubview(titleLabel)
        
        let hotkeyDesc = NSTextField(wrappingLabelWithString: "Cursor Release Hotkey:\nPress ⌃⎋ (Control + Escape) at any time to instantly pull the cursor back to your main screen center.")
        hotkeyDesc.frame = NSRect(x: 24, y: 145, width: 390, height: 50)
        hotkeyDesc.font = NSFont.systemFont(ofSize: 12)
        content.addSubview(hotkeyDesc)
        
        let gestureDesc = NSTextField(wrappingLabelWithString: "Trackpad Gesture:\nIn full-screen mode, 3-finger horizontal swipe automatically releases your cursor when switching back to your main desktop.")
        gestureDesc.frame = NSRect(x: 24, y: 85, width: 390, height: 50)
        gestureDesc.font = NSFont.systemFont(ofSize: 12)
        content.addSubview(gestureDesc)
        
        let permBtn = NSButton(title: "Open Privacy & Security Settings...", target: self, action: #selector(openSystemSettings))
        permBtn.bezelStyle = .rounded
        permBtn.frame = NSRect(x: 20, y: 25, width: 260, height: 32)
        content.addSubview(permBtn)
        
        win.contentView = content
    }
    
    public func showWindow() {
        window?.center()
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc private func openSystemSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture") {
            NSWorkspace.shared.open(url)
        }
    }
}

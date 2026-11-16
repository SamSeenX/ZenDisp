import Cocoa

public final class NavigationTabView: NSView {
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupUI()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        let navTitle = NSTextField(labelWithString: "Cursor Navigation & Hotkeys")
        navTitle.font = NSFont.boldSystemFont(ofSize: 13)
        navTitle.frame = NSRect(x: 20, y: 345, width: 300, height: 20)
        addSubview(navTitle)
        
        let hotkeyText = NSTextField(wrappingLabelWithString: "Cursor Release Shortcut:\n⌃⎋ (Control + Escape) instantly teleports your pointer back to your main monitor center.\n\nThree-Finger Swipe:\nSwiping between Spaces frees the cursor automatically.\n\nDirect Clicking:\nClick anywhere inside a PiP window to instantly snap your hardware cursor to that virtual display.")
        hotkeyText.frame = NSRect(x: 20, y: 160, width: 460, height: 160)
        hotkeyText.font = NSFont.systemFont(ofSize: 12)
        addSubview(hotkeyText)
        
        let permBtn = NSButton(title: "Open Privacy & Security Settings...", target: self, action: #selector(openSecuritySettings))
        permBtn.bezelStyle = .rounded
        permBtn.frame = NSRect(x: 20, y: 40, width: 260, height: 32)
        addSubview(permBtn)
    }
    
    @objc private func openSecuritySettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture") {
            NSWorkspace.shared.open(url)
        }
    }
}

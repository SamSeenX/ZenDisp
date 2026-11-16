import Cocoa

public final class NavigationTabView: NSView {
    public override var isFlipped: Bool { true }
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupUI()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        let sectionHeader = NSTextField(labelWithString: "CURSOR NAVIGATION & HOTKEYS")
        sectionHeader.font = NSFont.systemFont(ofSize: 11, weight: .bold)
        sectionHeader.textColor = NSColor(red: 0.44, green: 0.78, blue: 1.0, alpha: 1.0)
        sectionHeader.frame = NSRect(x: 10, y: 4, width: 350, height: 20)
        addSubview(sectionHeader)
        
        let c1 = makeNavCard(
            y: 32,
            iconName: "keyboard",
            title: "Release Cursor to Host",
            sub: "Instantly returns mouse pointer to primary physical monitor center",
            badge: "⌃  ⎋  (Control + Escape)"
        )
        addSubview(c1)
        
        let c2 = makeNavCard(
            y: 114,
            iconName: "exclamationmark.shield",
            title: "Emergency Panic Unbind",
            sub: "Force-resets all cursor capture if pointer is trapped",
            badge: "⌥  ⌘  ⌃  R"
        )
        addSubview(c2)
        
        let c3 = makeNavCard(
            y: 196,
            iconName: "hand.draw",
            title: "Trackpad Gestures & Click Snap",
            sub: "Click inside PiP to teleport cursor. Three-finger swipe Spaces auto-releases.",
            badge: "Space Swipe / Click"
        )
        addSubview(c3)
        
        let secBtn = NSButton(title: "Open Screen Recording Permissions...", target: self, action: #selector(openSecuritySettings))
        secBtn.bezelStyle = .rounded
        secBtn.image = NSImage(systemSymbolName: "lock.shield", accessibilityDescription: nil)
        secBtn.imagePosition = .imageLeading
        secBtn.frame = NSRect(x: 10, y: 286, width: 300, height: 32)
        addSubview(secBtn)
    }
    
    private func makeNavCard(y: CGFloat, iconName: String, title: String, sub: String, badge: String) -> NSView {
        let card = NSView(frame: NSRect(x: 10, y: y, width: 520, height: 72))
        card.wantsLayer = true
        card.layer?.cornerRadius = 10
        card.layer?.borderWidth = 1.0
        card.layer?.borderColor = NSColor(white: 0.32, alpha: 0.65).cgColor
        card.layer?.backgroundColor = NSColor(white: 0.16, alpha: 0.92).cgColor
        
        let icon = NSImageView(frame: NSRect(x: 16, y: 22, width: 26, height: 26))
        icon.image = NSImage(systemSymbolName: iconName, accessibilityDescription: nil)
        icon.contentTintColor = NSColor(red: 0.44, green: 0.78, blue: 1.0, alpha: 1.0)
        card.addSubview(icon)
        
        let t = NSTextField(labelWithString: title)
        t.font = NSFont.systemFont(ofSize: 14, weight: .bold)
        t.textColor = .white
        t.frame = NSRect(x: 52, y: 12, width: 280, height: 22)
        card.addSubview(t)
        
        let s = NSTextField(labelWithString: sub)
        s.font = NSFont.systemFont(ofSize: 11, weight: .medium)
        s.textColor = NSColor(white: 0.85, alpha: 1.0)
        s.frame = NSRect(x: 52, y: 36, width: 280, height: 22)
        card.addSubview(s)
        
        let bBox = NSView(frame: NSRect(x: 335, y: 18, width: 172, height: 36))
        bBox.wantsLayer = true
        bBox.layer?.cornerRadius = 6
        bBox.layer?.backgroundColor = NSColor(white: 0.10, alpha: 0.85).cgColor
        bBox.layer?.borderWidth = 1.0
        bBox.layer?.borderColor = NSColor(white: 0.30, alpha: 0.70).cgColor
        
        let bLabel = NSTextField(labelWithString: badge)
        bLabel.font = NSFont.monospacedSystemFont(ofSize: 11, weight: .bold)
        bLabel.textColor = NSColor(red: 0.44, green: 0.78, blue: 1.0, alpha: 1.0)
        bLabel.alignment = .center
        bLabel.frame = NSRect(x: 0, y: 8, width: 172, height: 20)
        bBox.addSubview(bLabel)
        card.addSubview(bBox)
        
        return card
    }
    
    @objc private func openSecuritySettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture") {
            NSWorkspace.shared.open(url)
        }
    }
}

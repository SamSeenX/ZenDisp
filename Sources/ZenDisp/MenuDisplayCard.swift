import Cocoa

final class ActiveDisplayCard: NSView {
    override var isFlipped: Bool { true }
    private let displayID: CGDirectDisplayID
    private let preset: DisplayPreset
    
    init(id: CGDirectDisplayID, preset: DisplayPreset, width: CGFloat) {
        self.displayID = id
        self.preset = preset
        super.init(frame: NSRect(x: 0, y: 0, width: width, height: 76))
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        wantsLayer = true
        layer?.cornerRadius = 8
        layer?.backgroundColor = NSColor(white: 0.18, alpha: 0.85).cgColor
        layer?.borderWidth = 1.0
        layer?.borderColor = NSColor(white: 0.30, alpha: 0.50).cgColor
        
        let icon = NSImageView(frame: NSRect(x: 10, y: 10, width: 20, height: 20))
        icon.image = NSImage(systemSymbolName: "display", accessibilityDescription: nil)
        icon.contentTintColor = NSColor(red: 0.44, green: 0.78, blue: 1.0, alpha: 1.0)
        addSubview(icon)
        
        let title = NSTextField(labelWithString: preset.name)
        title.font = NSFont.systemFont(ofSize: 12, weight: .bold)
        title.textColor = .white
        title.frame = NSRect(x: 34, y: 8, width: bounds.width - 90, height: 16)
        addSubview(title)
        
        let sub = NSTextField(labelWithString: "\(preset.width) × \(preset.height) • \(preset.aspectLabel)")
        sub.font = NSFont.systemFont(ofSize: 10, weight: .medium)
        sub.textColor = NSColor(white: 0.75, alpha: 1.0)
        sub.frame = NSRect(x: 34, y: 26, width: bounds.width - 90, height: 14)
        addSubview(sub)
        
        let toggle = NSSwitch(frame: NSRect(x: bounds.width - 48, y: 10, width: 38, height: 20))
        toggle.state = .on
        toggle.target = self
        toggle.action = #selector(toggleClosed)
        addSubview(toggle)
        
        let scaleSeg = NSSegmentedControl(labels: ["1x", "2x Retina", "3x Ultra"], trackingMode: .selectOne, target: self, action: #selector(scaleChanged(_:)))
        scaleSeg.selectedSegment = Int(max(1, min(preset.scaleFactor, 3)) - 1)
        scaleSeg.frame = NSRect(x: 10, y: 46, width: bounds.width - 20, height: 22)
        addSubview(scaleSeg)
    }
    
    @objc private func toggleClosed() {
        VirtualDisplayManager.shared.teardownDisplay(id: displayID)
    }
    
    @objc private func scaleChanged(_ sender: NSSegmentedControl) {
        let scale = UInt(sender.selectedSegment + 1)
        VirtualDisplayManager.shared.setScale(scale, for: displayID)
    }
}

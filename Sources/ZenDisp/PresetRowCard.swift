import Cocoa

final class PresetButton: NSButton {
    var preset: DisplayPreset?
}

final class PresetRowCard: NSView {
    public override var isFlipped: Bool { true }
    
    private let preset: DisplayPreset
    private let onSpawn: (DisplayPreset) -> Void
    private let onRemove: (DisplayPreset) -> Void
    
    init(preset: DisplayPreset, onSpawn: @escaping (DisplayPreset) -> Void, onRemove: @escaping (DisplayPreset) -> Void) {
        self.preset = preset
        self.onSpawn = onSpawn
        self.onRemove = onRemove
        super.init(frame: NSRect(x: 0, y: 0, width: 505, height: 64))
        setupCard()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCard() {
        wantsLayer = true
        layer?.cornerRadius = 10
        layer?.borderWidth = 1.0
        layer?.borderColor = NSColor(white: 0.32, alpha: 0.65).cgColor
        layer?.backgroundColor = NSColor(white: 0.16, alpha: 0.92).cgColor
        
        heightAnchor.constraint(equalToConstant: 64).isActive = true
        widthAnchor.constraint(equalToConstant: 505).isActive = true
        
        let icon = NSImageView(frame: NSRect(x: 14, y: 19, width: 26, height: 26))
        icon.image = NSImage(systemSymbolName: "display", accessibilityDescription: nil)
        icon.contentTintColor = NSColor(red: 0.44, green: 0.78, blue: 1.0, alpha: 1.0)
        addSubview(icon)
        
        let title = NSTextField(labelWithString: preset.name)
        title.font = NSFont.systemFont(ofSize: 13, weight: .bold)
        title.textColor = .white
        title.frame = NSRect(x: 46, y: 11, width: 220, height: 22)
        addSubview(title)
        
        let specs = NSTextField(labelWithString: "\(preset.width) × \(preset.height) • \(preset.aspectLabel)")
        specs.font = NSFont.systemFont(ofSize: 10, weight: .medium)
        specs.textColor = NSColor(white: 0.85, alpha: 1.0)
        specs.frame = NSRect(x: 46, y: 34, width: 220, height: 18)
        addSubview(specs)
        
        let scaleSegment = NSSegmentedControl(labels: ["1x", "2x", "3x"], trackingMode: .selectOne, target: self, action: #selector(scaleChanged(_:)))
        scaleSegment.selectedSegment = Int(max(1, min(preset.scaleFactor, 3)) - 1)
        scaleSegment.frame = NSRect(x: 280, y: 18, width: 100, height: 26)
        addSubview(scaleSegment)
        
        let launchBtn = PresetButton(image: NSImage(systemSymbolName: "play.circle.fill", accessibilityDescription: "Launch")!, target: self, action: #selector(spawnClicked))
        launchBtn.bezelStyle = .inline
        launchBtn.isBordered = false
        launchBtn.contentTintColor = NSColor(red: 0.44, green: 0.78, blue: 1.0, alpha: 1.0)
        launchBtn.toolTip = "Launch"
        launchBtn.frame = NSRect(x: 400, y: 16, width: 32, height: 32)
        launchBtn.preset = preset
        addSubview(launchBtn)
        
        let removeBtn = PresetButton(image: NSImage(systemSymbolName: "trash.circle.fill", accessibilityDescription: "Delete")!, target: self, action: #selector(removeClicked))
        removeBtn.bezelStyle = .inline
        removeBtn.isBordered = false
        removeBtn.contentTintColor = NSColor.systemRed
        removeBtn.toolTip = "Delete"
        removeBtn.frame = NSRect(x: 448, y: 16, width: 32, height: 32)
        removeBtn.isEnabled = preset.isCustom
        removeBtn.preset = preset
        addSubview(removeBtn)
    }
    
    @objc private func scaleChanged(_ sender: NSSegmentedControl) {
        let scale = UInt(sender.selectedSegment + 1)
        PresetManager.shared.setScale(scale, for: preset.id)
    }
    
    @objc private func spawnClicked() {
        onSpawn(preset)
    }
    
    @objc private func removeClicked() {
        onRemove(preset)
    }
}

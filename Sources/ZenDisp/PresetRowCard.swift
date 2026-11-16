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
        
        let icon = NSImageView(frame: NSRect(x: 16, y: 19, width: 26, height: 26))
        let img = NSImage(systemSymbolName: "display", accessibilityDescription: nil)
        icon.image = img
        icon.contentTintColor = NSColor(red: 0.44, green: 0.78, blue: 1.0, alpha: 1.0)
        addSubview(icon)
        
        let title = NSTextField(labelWithString: preset.name)
        title.font = NSFont.systemFont(ofSize: 14, weight: .bold)
        title.textColor = .white
        title.frame = NSRect(x: 52, y: 11, width: 235, height: 22)
        addSubview(title)
        
        let specs = NSTextField(labelWithString: "\(preset.width) × \(preset.height) • \(preset.aspectLabel) • 60Hz")
        specs.font = NSFont.systemFont(ofSize: 11, weight: .medium)
        specs.textColor = NSColor(white: 0.85, alpha: 1.0)
        specs.frame = NSRect(x: 52, y: 34, width: 235, height: 18)
        addSubview(specs)
        
        let spawnBtn = PresetButton(title: "Spawn", target: self, action: #selector(spawnClicked))
        spawnBtn.bezelStyle = .rounded
        spawnBtn.image = NSImage(systemSymbolName: "play.fill", accessibilityDescription: nil)
        spawnBtn.imagePosition = .imageLeading
        spawnBtn.frame = NSRect(x: 295, y: 16, width: 95, height: 32)
        spawnBtn.preset = preset
        addSubview(spawnBtn)
        
        let removeBtn = PresetButton(title: "Remove", target: self, action: #selector(removeClicked))
        removeBtn.bezelStyle = .rounded
        removeBtn.image = NSImage(systemSymbolName: "trash", accessibilityDescription: nil)
        removeBtn.imagePosition = .imageLeading
        removeBtn.frame = NSRect(x: 398, y: 16, width: 95, height: 32)
        removeBtn.isEnabled = preset.isCustom
        removeBtn.preset = preset
        addSubview(removeBtn)
    }
    
    @objc private func spawnClicked() {
        onSpawn(preset)
    }
    
    @objc private func removeClicked() {
        onRemove(preset)
    }
}

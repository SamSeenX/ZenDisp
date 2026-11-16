import Cocoa

public final class LayoutsTabView: NSView {
    public override var isFlipped: Bool { true }
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupUI()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        let sectionHeader = NSTextField(labelWithString: "MULTI-SCREEN WORKSPACE LAYOUTS")
        sectionHeader.font = NSFont.systemFont(ofSize: 11, weight: .bold)
        sectionHeader.textColor = NSColor(red: 0.44, green: 0.78, blue: 1.0, alpha: 1.0)
        sectionHeader.frame = NSRect(x: 10, y: 4, width: 350, height: 20)
        addSubview(sectionHeader)
        
        let desc = NSTextField(wrappingLabelWithString: "Launch coordinated multi-screen layouts with a single click. Each virtual monitor automatically opens its own floating Picture-in-Picture window.")
        desc.frame = NSRect(x: 10, y: 28, width: 520, height: 36)
        desc.font = NSFont.systemFont(ofSize: 12)
        desc.textColor = NSColor(white: 0.85, alpha: 1.0)
        addSubview(desc)
        
        var yPos: CGFloat = 75
        for (index, group) in PresetManager.shared.layoutGroups.enumerated() {
            let card = NSView(frame: NSRect(x: 10, y: yPos, width: 520, height: 64))
            card.wantsLayer = true
            card.layer?.cornerRadius = 10
            card.layer?.borderWidth = 1.0
            card.layer?.borderColor = NSColor(white: 0.32, alpha: 0.65).cgColor
            card.layer?.backgroundColor = NSColor(white: 0.16, alpha: 0.92).cgColor
            
            let icon = NSImageView(frame: NSRect(x: 16, y: 19, width: 26, height: 26))
            icon.image = NSImage(systemSymbolName: "square.grid.2x2", accessibilityDescription: nil)
            icon.contentTintColor = NSColor(red: 0.44, green: 0.78, blue: 1.0, alpha: 1.0)
            card.addSubview(icon)
            
            let title = NSTextField(labelWithString: group.name)
            title.font = NSFont.systemFont(ofSize: 14, weight: .bold)
            title.textColor = .white
            title.frame = NSRect(x: 52, y: 11, width: 300, height: 22)
            card.addSubview(title)
            
            let presetNames = group.presets.map { $0.name }.joined(separator: " + ")
            let sub = NSTextField(labelWithString: "\(group.presets.count) Displays: \(presetNames)")
            sub.font = NSFont.systemFont(ofSize: 11, weight: .medium)
            sub.textColor = NSColor(white: 0.85, alpha: 1.0)
            sub.frame = NSRect(x: 52, y: 34, width: 300, height: 18)
            card.addSubview(sub)
            
            let btn = NSButton(title: "Launch Layout", target: self, action: #selector(launchGroupFromBtn(_:)))
            btn.bezelStyle = .rounded
            btn.image = NSImage(systemSymbolName: "play.fill", accessibilityDescription: nil)
            btn.imagePosition = .imageLeading
            btn.tag = index
            btn.frame = NSRect(x: 360, y: 16, width: 145, height: 32)
            card.addSubview(btn)
            
            addSubview(card)
            yPos += 74
        }
    }
    
    @objc private func launchGroupFromBtn(_ sender: NSButton) {
        let groups = PresetManager.shared.layoutGroups
        if sender.tag >= 0 && sender.tag < groups.count {
            VirtualDisplayManager.shared.launchGroup(groups[sender.tag])
        }
    }
}

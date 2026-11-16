import Cocoa

final class MenuPresetRow: NSView {
    override var isFlipped: Bool { true }
    private var onLaunchBlock: ((Int) -> Void)?
    private var tagIndex: Int = 0
    
    init(preset: DisplayPreset, index: Int, onLaunch: @escaping (Int) -> Void) {
        super.init(frame: NSRect(x: 0, y: 0, width: 316, height: 30))
        self.onLaunchBlock = onLaunch
        self.tagIndex = index
        wantsLayer = true
        layer?.cornerRadius = 6
        layer?.backgroundColor = NSColor(white: 0.15, alpha: 0.50).cgColor
        widthAnchor.constraint(equalToConstant: 316).isActive = true
        heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        let iconName = preset.height > preset.width ? "iphone" : "display"
        let icon = NSImageView(frame: NSRect(x: 8, y: 6, width: 18, height: 18))
        icon.image = NSImage(systemSymbolName: iconName, accessibilityDescription: nil)
        icon.contentTintColor = NSColor(red: 0.44, green: 0.78, blue: 1.0, alpha: 1.0)
        addSubview(icon)
        
        let name = NSTextField(labelWithString: "\(preset.name) • \(preset.scaleLabel)")
        name.font = NSFont.systemFont(ofSize: 11, weight: .medium)
        name.textColor = .white
        name.frame = NSRect(x: 32, y: 6, width: 245, height: 18)
        addSubview(name)
        
        let btn = NSButton(image: NSImage(systemSymbolName: "play.circle.fill", accessibilityDescription: "Launch")!, target: self, action: #selector(launchClicked))
        btn.bezelStyle = .inline
        btn.isBordered = false
        btn.contentTintColor = NSColor(red: 0.44, green: 0.78, blue: 1.0, alpha: 1.0)
        btn.toolTip = "Launch"
        btn.frame = NSRect(x: 286, y: 4, width: 22, height: 22)
        addSubview(btn)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    @objc private func launchClicked() { onLaunchBlock?(tagIndex) }
}

final class MenuGroupRow: NSView {
    override var isFlipped: Bool { true }
    private var onLaunchBlock: ((Int) -> Void)?
    private var onDeleteBlock: ((Int) -> Void)?
    private var tagIndex: Int = 0
    
    init(group: LayoutGroup, index: Int, onLaunch: @escaping (Int) -> Void, onDelete: @escaping (Int) -> Void) {
        super.init(frame: NSRect(x: 0, y: 0, width: 316, height: 30))
        self.onLaunchBlock = onLaunch
        self.onDeleteBlock = onDelete
        self.tagIndex = index
        wantsLayer = true
        layer?.cornerRadius = 6
        layer?.backgroundColor = NSColor(white: 0.15, alpha: 0.50).cgColor
        widthAnchor.constraint(equalToConstant: 316).isActive = true
        heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        let icon = NSImageView(frame: NSRect(x: 8, y: 6, width: 18, height: 18))
        icon.image = NSImage(systemSymbolName: "square.grid.2x2.fill", accessibilityDescription: nil)
        icon.contentTintColor = NSColor(red: 0.44, green: 0.78, blue: 1.0, alpha: 1.0)
        addSubview(icon)
        
        let name = NSTextField(labelWithString: group.name)
        name.font = NSFont.systemFont(ofSize: 11, weight: .semibold)
        name.textColor = .white
        name.frame = NSRect(x: 32, y: 6, width: index >= 2 ? 224 : 245, height: 18)
        addSubview(name)
        
        let btn = NSButton(image: NSImage(systemSymbolName: "play.circle.fill", accessibilityDescription: "Launch")!, target: self, action: #selector(launchClicked))
        btn.bezelStyle = .inline
        btn.isBordered = false
        btn.contentTintColor = NSColor(red: 0.44, green: 0.78, blue: 1.0, alpha: 1.0)
        btn.toolTip = "Launch"
        btn.frame = NSRect(x: index >= 2 ? 260 : 286, y: 4, width: 22, height: 22)
        addSubview(btn)
        
        if index >= 2 {
            let del = NSButton(image: NSImage(systemSymbolName: "trash.circle.fill", accessibilityDescription: "Delete")!, target: self, action: #selector(deleteClicked))
            del.bezelStyle = .inline
            del.isBordered = false
            del.contentTintColor = NSColor.systemRed
            del.toolTip = "Delete Layout"
            del.frame = NSRect(x: 286, y: 4, width: 22, height: 22)
            addSubview(del)
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
    @objc private func launchClicked() { onLaunchBlock?(tagIndex) }
    @objc private func deleteClicked() { onDeleteBlock?(tagIndex) }
}

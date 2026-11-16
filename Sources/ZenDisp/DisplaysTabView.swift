import Cocoa

final class FlippedCardView: NSView {
    public override var isFlipped: Bool { true }
}

public final class DisplaysTabView: NSView {
    public override var isFlipped: Bool { true }
    
    private var widthField: NSTextField!
    private var heightField: NSTextField!
    private var nameField: NSTextField!
    private var listContainer: NSStackView!
    private var statusLabel: NSTextField!
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshList), name: PresetManager.didChangeNotification, object: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        let sectionHeader = NSTextField(labelWithString: "PRESET RESOLUTIONS")
        sectionHeader.font = NSFont.systemFont(ofSize: 11, weight: .bold)
        sectionHeader.textColor = NSColor(red: 0.44, green: 0.78, blue: 1.0, alpha: 1.0)
        sectionHeader.frame = NSRect(x: 10, y: 4, width: 250, height: 20)
        addSubview(sectionHeader)
        
        let scroll = NSScrollView(frame: NSRect(x: 10, y: 28, width: 520, height: 215))
        scroll.hasVerticalScroller = true
        scroll.drawsBackground = false
        scroll.borderType = .noBorder
        
        listContainer = NSStackView()
        listContainer.orientation = .vertical
        listContainer.alignment = .leading
        listContainer.spacing = 8
        listContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let clip = NSClipView()
        clip.drawsBackground = false
        clip.documentView = listContainer
        scroll.contentView = clip
        addSubview(scroll)
        
        setupAddCard()
        setupFooter()
        refreshList()
    }
    
    private func setupAddCard() {
        let card = FlippedCardView(frame: NSRect(x: 10, y: 252, width: 520, height: 135))
        card.wantsLayer = true
        card.layer?.cornerRadius = 10
        card.layer?.borderWidth = 1.0
        card.layer?.borderColor = NSColor(white: 0.32, alpha: 0.65).cgColor
        card.layer?.backgroundColor = NSColor(white: 0.16, alpha: 0.92).cgColor
        
        let boxTitle = NSTextField(labelWithString: "ADD CUSTOM RESOLUTION")
        boxTitle.font = NSFont.systemFont(ofSize: 11, weight: .bold)
        boxTitle.textColor = NSColor(red: 0.44, green: 0.78, blue: 1.0, alpha: 1.0)
        boxTitle.frame = NSRect(x: 14, y: 12, width: 250, height: 20)
        card.addSubview(boxTitle)
        
        let lblW = NSTextField(labelWithString: "Width:")
        lblW.frame = NSRect(x: 14, y: 46, width: 45, height: 20)
        lblW.textColor = .white
        lblW.font = NSFont.systemFont(ofSize: 12)
        card.addSubview(lblW)
        widthField = NSTextField(frame: NSRect(x: 62, y: 43, width: 70, height: 24))
        widthField.stringValue = "1920"
        card.addSubview(widthField)
        
        let lblH = NSTextField(labelWithString: "Height:")
        lblH.frame = NSRect(x: 145, y: 46, width: 48, height: 20)
        lblH.textColor = .white
        lblH.font = NSFont.systemFont(ofSize: 12)
        card.addSubview(lblH)
        heightField = NSTextField(frame: NSRect(x: 198, y: 43, width: 70, height: 24))
        heightField.stringValue = "1080"
        card.addSubview(heightField)
        
        let lblN = NSTextField(labelWithString: "Label:")
        lblN.frame = NSRect(x: 282, y: 46, width: 42, height: 20)
        lblN.textColor = .white
        lblN.font = NSFont.systemFont(ofSize: 12)
        card.addSubview(lblN)
        nameField = NSTextField(frame: NSRect(x: 328, y: 43, width: 178, height: 24))
        nameField.stringValue = "Workspace Screen"
        card.addSubview(nameField)
        
        let addBtn = NSButton(title: "Add Display Preset", target: self, action: #selector(addPresetAction))
        addBtn.bezelStyle = .rounded
        addBtn.image = NSImage(systemSymbolName: "plus.circle.fill", accessibilityDescription: nil)
        addBtn.imagePosition = .imageLeading
        addBtn.frame = NSRect(x: 320, y: 84, width: 186, height: 32)
        card.addSubview(addBtn)
        addSubview(card)
    }
    
    private func setupFooter() {
        statusLabel = NSTextField(labelWithString: "Active Displays: 0")
        statusLabel.font = NSFont.systemFont(ofSize: 12, weight: .semibold)
        statusLabel.textColor = .white
        statusLabel.frame = NSRect(x: 14, y: 402, width: 250, height: 22)
        addSubview(statusLabel)
        
        let teardownBtn = NSButton(title: "Teardown All Displays", target: self, action: #selector(teardownAllAction))
        teardownBtn.bezelStyle = .rounded
        teardownBtn.image = NSImage(systemSymbolName: "xmark.circle.fill", accessibilityDescription: nil)
        teardownBtn.imagePosition = .imageLeading
        teardownBtn.frame = NSRect(x: 310, y: 396, width: 220, height: 32)
        addSubview(teardownBtn)
    }
    
    @objc public func refreshList() {
        listContainer.arrangedSubviews.forEach {
            listContainer.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        for preset in PresetManager.shared.allPresets {
            let card = PresetRowCard(
                preset: preset,
                onSpawn: { [weak self] p in
                    _ = VirtualDisplayManager.shared.createDisplay(preset: p)
                    self?.refreshList()
                },
                onRemove: { p in
                    PresetManager.shared.removeCustomPreset(id: p.id)
                }
            )
            listContainer.addArrangedSubview(card)
        }
        let count = VirtualDisplayManager.shared.activeCount
        statusLabel.stringValue = count > 0 ? "Active Displays: \(count)" : "No Active Displays"
    }
    
    @objc private func addPresetAction() {
        let w = UInt(widthField.stringValue) ?? 1920
        let h = UInt(heightField.stringValue) ?? 1080
        let name = nameField.stringValue.isEmpty ? "\(w)x\(h)" : nameField.stringValue
        _ = PresetManager.shared.addCustomPreset(width: w, height: h, name: name)
    }
    
    @objc private func teardownAllAction() {
        VirtualDisplayManager.shared.teardownAllDisplays()
        CursorRouter.shared.reset()
        refreshList()
    }
}

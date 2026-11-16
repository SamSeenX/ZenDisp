import Cocoa

final class PresetButton: NSButton {
    var preset: DisplayPreset?
}

public final class DisplaysTabView: NSView {
    private var widthField: NSTextField!
    private var heightField: NSTextField!
    private var nameField: NSTextField!
    private var listContainer: NSStackView!
    private var scrollView: NSScrollView!
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshList), name: PresetManager.didChangeNotification, object: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        let title = NSTextField(labelWithString: "Screen Configurations")
        title.font = NSFont.boldSystemFont(ofSize: 13)
        title.frame = NSRect(x: 20, y: 345, width: 300, height: 20)
        addSubview(title)
        
        scrollView = NSScrollView(frame: NSRect(x: 20, y: 155, width: 480, height: 180))
        scrollView.hasVerticalScroller = true
        scrollView.borderType = .bezelBorder
        
        listContainer = NSStackView()
        listContainer.orientation = .vertical
        listContainer.alignment = .leading
        listContainer.spacing = 8
        listContainer.edgeInsets = NSEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        listContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let clip = NSClipView()
        clip.documentView = listContainer
        scrollView.contentView = clip
        addSubview(scrollView)
        
        let addTitle = NSTextField(labelWithString: "Add Custom Configuration")
        addTitle.font = NSFont.boldSystemFont(ofSize: 12)
        addTitle.frame = NSRect(x: 20, y: 125, width: 200, height: 18)
        addSubview(addTitle)
        
        let lblW = NSTextField(labelWithString: "W:")
        lblW.frame = NSRect(x: 20, y: 95, width: 22, height: 20)
        addSubview(lblW)
        widthField = NSTextField(frame: NSRect(x: 44, y: 93, width: 65, height: 22))
        widthField.stringValue = "1920"
        addSubview(widthField)
        
        let lblH = NSTextField(labelWithString: "H:")
        lblH.frame = NSRect(x: 115, y: 95, width: 22, height: 20)
        addSubview(lblH)
        heightField = NSTextField(frame: NSRect(x: 139, y: 93, width: 65, height: 22))
        heightField.stringValue = "1080"
        addSubview(heightField)
        
        let lblN = NSTextField(labelWithString: "Name:")
        lblN.frame = NSRect(x: 215, y: 95, width: 45, height: 20)
        addSubview(lblN)
        nameField = NSTextField(frame: NSRect(x: 262, y: 93, width: 140, height: 22))
        nameField.stringValue = "Workspace Screen"
        addSubview(nameField)
        
        let addBtn = NSButton(title: "Add", target: self, action: #selector(addPresetAction))
        addBtn.bezelStyle = .rounded
        addBtn.frame = NSRect(x: 410, y: 88, width: 90, height: 32)
        addSubview(addBtn)
        
        let teardownBtn = NSButton(title: "Teardown All Active Displays", target: self, action: #selector(teardownAllAction))
        teardownBtn.bezelStyle = .rounded
        teardownBtn.frame = NSRect(x: 16, y: 25, width: 220, height: 32)
        addSubview(teardownBtn)
        
        refreshList()
    }
    
    @objc public func refreshList() {
        for v in listContainer.arrangedSubviews {
            listContainer.removeArrangedSubview(v)
            v.removeFromSuperview()
        }
        
        for preset in PresetManager.shared.allPresets {
            let row = NSView(frame: NSRect(x: 0, y: 0, width: 450, height: 30))
            row.heightAnchor.constraint(equalToConstant: 30).isActive = true
            row.widthAnchor.constraint(equalToConstant: 450).isActive = true
            
            let nameLbl = NSTextField(labelWithString: "\(preset.name) (\(preset.width)x\(preset.height))")
            nameLbl.frame = NSRect(x: 0, y: 5, width: 280, height: 20)
            row.addSubview(nameLbl)
            
            let spawnBtn = PresetButton(title: "Spawn", target: self, action: #selector(spawnPresetFromBtn(_:)))
            spawnBtn.bezelStyle = .rounded
            spawnBtn.frame = NSRect(x: 285, y: 0, width: 75, height: 28)
            spawnBtn.preset = preset
            row.addSubview(spawnBtn)
            
            let removeBtn = PresetButton(title: "Remove", target: self, action: #selector(removePresetFromBtn(_:)))
            removeBtn.bezelStyle = .rounded
            removeBtn.frame = NSRect(x: 365, y: 0, width: 80, height: 28)
            removeBtn.isEnabled = preset.isCustom
            removeBtn.preset = preset
            row.addSubview(removeBtn)
            
            listContainer.addArrangedSubview(row)
        }
    }
    
    @objc private func addPresetAction() {
        let w = UInt(widthField.stringValue) ?? 1920
        let h = UInt(heightField.stringValue) ?? 1080
        let name = nameField.stringValue.isEmpty ? "\(w)x\(h)" : nameField.stringValue
        _ = PresetManager.shared.addCustomPreset(width: w, height: h, name: name)
    }
    
    @objc private func spawnPresetFromBtn(_ sender: PresetButton) {
        if let preset = sender.preset {
            _ = VirtualDisplayManager.shared.createDisplay(preset: preset)
        }
    }
    
    @objc private func removePresetFromBtn(_ sender: PresetButton) {
        if let preset = sender.preset {
            PresetManager.shared.removeCustomPreset(id: preset.id)
        }
    }
    
    @objc private func teardownAllAction() {
        VirtualDisplayManager.shared.teardownAllDisplays()
        CursorRouter.shared.reset()
    }
}

import Cocoa

public final class LayoutsTabView: NSView {
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupUI()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        let title = NSTextField(labelWithString: "One-Click Multi-Screen Layout Groups")
        title.font = NSFont.boldSystemFont(ofSize: 13)
        title.frame = NSRect(x: 20, y: 345, width: 350, height: 20)
        addSubview(title)
        
        let desc = NSTextField(wrappingLabelWithString: "Launch preconfigured multi-screen arrangements with a single click. Each display in the group spawns with its own floating stream window.")
        desc.frame = NSRect(x: 20, y: 295, width: 460, height: 40)
        desc.font = NSFont.systemFont(ofSize: 11)
        addSubview(desc)
        
        var yPos = 245
        for (index, group) in PresetManager.shared.layoutGroups.enumerated() {
            let label = NSTextField(labelWithString: "\(group.name) (\(group.presets.count) Displays)")
            label.font = NSFont.systemFont(ofSize: 12)
            label.frame = NSRect(x: 20, y: yPos, width: 280, height: 22)
            addSubview(label)
            
            let btn = NSButton(title: "Launch", target: self, action: #selector(launchGroupFromBtn(_:)))
            btn.bezelStyle = .rounded
            btn.tag = index
            btn.frame = NSRect(x: 320, y: yPos - 5, width: 90, height: 32)
            addSubview(btn)
            yPos -= 50
        }
    }
    
    @objc private func launchGroupFromBtn(_ sender: NSButton) {
        let groups = PresetManager.shared.layoutGroups
        if sender.tag >= 0 && sender.tag < groups.count {
            VirtualDisplayManager.shared.launchGroup(groups[sender.tag])
        }
    }
}

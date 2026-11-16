import Cocoa

public final class MenuPopoverView: NSVisualEffectView {
    public override var isFlipped: Bool { true }
    private let contentStack = NSStackView()
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        material = .popover
        blendingMode = .behindWindow
        state = .active
        wantsLayer = true
        setupStack()
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    private func setupStack() {
        contentStack.orientation = .vertical
        contentStack.spacing = 8
        contentStack.alignment = .leading
        contentStack.edgeInsets = NSEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    public func rebuild() {
        for v in contentStack.arrangedSubviews {
            contentStack.removeArrangedSubview(v)
            v.removeFromSuperview()
        }
        contentStack.addArrangedSubview(makeHeader())
        
        let activeList = VirtualDisplayManager.shared.activeDisplaysList()
        contentStack.addArrangedSubview(makeSectionHeader(activeList.isEmpty ? "NO ACTIVE DISPLAYS" : "ACTIVE DISPLAYS (\(activeList.count))"))
        
        for (id, preset) in activeList {
            let card = ActiveDisplayCard(id: id, preset: preset, width: 316)
            card.heightAnchor.constraint(equalToConstant: 76).isActive = true
            card.widthAnchor.constraint(equalToConstant: 316).isActive = true
            contentStack.addArrangedSubview(card)
        }
        
        contentStack.addArrangedSubview(makeActionsRow(hasActive: !activeList.isEmpty))
        contentStack.addArrangedSubview(makeSectionHeader("PRESETS & LAYOUT GROUPS"))
        
        for group in PresetManager.shared.layoutGroups { contentStack.addArrangedSubview(makeGroupRow(group)) }
        contentStack.addArrangedSubview(makeFooter())
    }
    
    private func makeHeader() -> NSView {
        let bar = NSView(frame: NSRect(x: 0, y: 0, width: 316, height: 26))
        bar.widthAnchor.constraint(equalToConstant: 316).isActive = true
        bar.heightAnchor.constraint(equalToConstant: 26).isActive = true
        
        let title = NSTextField(labelWithString: "ZenDisp Control")
        title.font = NSFont.systemFont(ofSize: 13, weight: .bold)
        title.textColor = .white
        title.frame = NSRect(x: 0, y: 2, width: 200, height: 22)
        bar.addSubview(title)
        
        let gear = NSButton(image: NSImage(systemSymbolName: "gearshape.fill", accessibilityDescription: "Preferences")!, target: self, action: #selector(openPreferences))
        gear.bezelStyle = .inline
        gear.isBordered = false
        gear.frame = NSRect(x: 292, y: 2, width: 24, height: 22)
        bar.addSubview(gear)
        return bar
    }
    
    private func makeSectionHeader(_ title: String) -> NSTextField {
        let lbl = NSTextField(labelWithString: title)
        lbl.font = NSFont.systemFont(ofSize: 10, weight: .bold)
        lbl.textColor = NSColor(red: 0.44, green: 0.78, blue: 1.0, alpha: 1.0)
        lbl.widthAnchor.constraint(equalToConstant: 316).isActive = true
        return lbl
    }
    
    private func makeActionsRow(hasActive: Bool) -> NSView {
        let row = NSView(frame: NSRect(x: 0, y: 0, width: 316, height: 32))
        row.widthAnchor.constraint(equalToConstant: 316).isActive = true
        row.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        let relBtn = NSButton(title: "Release Cursor ⌃⎋", target: self, action: #selector(releaseCursor))
        relBtn.bezelStyle = .rounded
        relBtn.frame = NSRect(x: 0, y: 0, width: 154, height: 30)
        relBtn.isEnabled = hasActive
        row.addSubview(relBtn)
        
        let saveBtn = NSButton(title: "Save Layout", target: self, action: #selector(saveLayout))
        saveBtn.bezelStyle = .rounded
        saveBtn.image = NSImage(systemSymbolName: "camera.fill", accessibilityDescription: nil)
        saveBtn.imagePosition = .imageLeading
        saveBtn.frame = NSRect(x: 162, y: 0, width: 154, height: 30)
        saveBtn.isEnabled = hasActive
        row.addSubview(saveBtn)
        return row
    }
    
    private func makeGroupRow(_ group: LayoutGroup) -> NSView {
        let row = NSView(frame: NSRect(x: 0, y: 0, width: 316, height: 34))
        row.wantsLayer = true
        row.layer?.cornerRadius = 6
        row.layer?.backgroundColor = NSColor(white: 0.15, alpha: 0.60).cgColor
        row.widthAnchor.constraint(equalToConstant: 316).isActive = true
        row.heightAnchor.constraint(equalToConstant: 34).isActive = true
        
        let icon = NSImageView(frame: NSRect(x: 8, y: 8, width: 18, height: 18))
        icon.image = NSImage(systemSymbolName: "square.grid.2x2.fill", accessibilityDescription: nil)
        icon.contentTintColor = NSColor(red: 0.44, green: 0.78, blue: 1.0, alpha: 1.0)
        row.addSubview(icon)
        
        let name = NSTextField(labelWithString: group.name)
        name.font = NSFont.systemFont(ofSize: 11, weight: .semibold)
        name.textColor = .white
        name.frame = NSRect(x: 32, y: 8, width: 210, height: 18)
        row.addSubview(name)
        
        let index = PresetManager.shared.layoutGroups.firstIndex(of: group) ?? 0
        let btn = NSButton(title: "Launch", target: self, action: #selector(launchGroupClicked(_:)))
        btn.bezelStyle = .inline
        btn.frame = NSRect(x: 234, y: 6, width: 52, height: 22)
        btn.tag = index
        row.addSubview(btn)
        
        if index >= 2 {
            let del = NSButton(image: NSImage(systemSymbolName: "xmark.circle.fill", accessibilityDescription: "Delete")!, target: self, action: #selector(deleteGroupClicked(_:)))
            del.bezelStyle = .inline
            del.isBordered = false
            del.contentTintColor = NSColor.systemRed
            del.frame = NSRect(x: 290, y: 6, width: 20, height: 22)
            del.tag = index
            row.addSubview(del)
        }
        return row
    }
    
    private func makeFooter() -> NSView {
        let foot = NSView(frame: NSRect(x: 0, y: 0, width: 316, height: 30))
        foot.widthAnchor.constraint(equalToConstant: 316).isActive = true
        foot.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        let panicBtn = NSButton(title: "Panic Reset ⌥⌘⌃R", target: self, action: #selector(panicReset))
        panicBtn.bezelStyle = .inline
        panicBtn.contentTintColor = NSColor.systemRed
        panicBtn.frame = NSRect(x: 0, y: 4, width: 150, height: 22)
        foot.addSubview(panicBtn)
        
        let quitBtn = NSButton(title: "Quit ZenDisp", target: self, action: #selector(quitApp))
        quitBtn.bezelStyle = .inline
        quitBtn.frame = NSRect(x: 236, y: 4, width: 80, height: 22)
        foot.addSubview(quitBtn)
        return foot
    }
    
    @objc private func openPreferences() { SettingsWindowController.shared.showWindow() }
    @objc private func releaseCursor() { CursorRouter.shared.releaseToHost() }
    @objc private func panicReset() { MenuBarController.shared.panicReset() }
    @objc private func quitApp() { NSApp.terminate(nil) }
    @objc private func saveLayout() { MenuPopoverController.shared.promptSaveLayout() }
    @objc private func deleteGroupClicked(_ sender: NSButton) {
        let groups = PresetManager.shared.layoutGroups
        if sender.tag >= 0 && sender.tag < groups.count {
            PresetManager.shared.removeLayoutGroup(id: groups[sender.tag].id)
        }
    }
    @objc private func launchGroupClicked(_ sender: NSButton) {
        let groups = PresetManager.shared.layoutGroups
        if sender.tag >= 0 && sender.tag < groups.count {
            VirtualDisplayManager.shared.launchGroup(groups[sender.tag])
        }
    }
}

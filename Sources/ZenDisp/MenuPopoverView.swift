import Cocoa

public final class MenuPopoverView: NSVisualEffectView {
    public override var isFlipped: Bool { true }
    private let contentStack = NSStackView()
    private let scroll = NSScrollView()
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        material = .popover
        blendingMode = .behindWindow
        state = .active
        wantsLayer = true
        setupUI()
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        scroll.frame = bounds
        scroll.autoresizingMask = [.width, .height]
        scroll.hasVerticalScroller = true
        scroll.drawsBackground = false
        addSubview(scroll)
        
        contentStack.orientation = .vertical
        contentStack.spacing = 6
        contentStack.alignment = .leading
        contentStack.edgeInsets = NSEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        
        let clip = NSClipView()
        clip.drawsBackground = false
        clip.documentView = contentStack
        scroll.contentView = clip
        
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: clip.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: clip.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: clip.trailingAnchor)
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
        contentStack.addArrangedSubview(makeSectionHeader("INDIVIDUAL DISPLAYS"))
        
        for (idx, preset) in PresetManager.shared.allPresets.enumerated() {
            let row = MenuPresetRow(preset: preset, index: idx) { i in
                let p = PresetManager.shared.allPresets
                if i >= 0 && i < p.count { _ = VirtualDisplayManager.shared.createDisplay(preset: p[i]) }
            }
            contentStack.addArrangedSubview(row)
        }
        
        contentStack.addArrangedSubview(makeSectionHeader("WORKSPACE LAYOUT GROUPS"))
        for (idx, group) in PresetManager.shared.layoutGroups.enumerated() {
            let row = MenuGroupRow(group: group, index: idx, onLaunch: { i in
                let g = PresetManager.shared.layoutGroups
                if i >= 0 && i < g.count { VirtualDisplayManager.shared.launchGroup(g[i]) }
            }, onDelete: { i in
                let g = PresetManager.shared.layoutGroups
                if i >= 0 && i < g.count { PresetManager.shared.removeLayoutGroup(id: g[i].id) }
            })
            contentStack.addArrangedSubview(row)
        }
        
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
        let row = NSView(frame: NSRect(x: 0, y: 0, width: 316, height: 30))
        row.widthAnchor.constraint(equalToConstant: 316).isActive = true
        row.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        let relBtn = NSButton(title: "Release Cursor ⌃⎋", target: self, action: #selector(releaseCursor))
        relBtn.bezelStyle = .rounded
        relBtn.frame = NSRect(x: 0, y: 0, width: 154, height: 28)
        relBtn.isEnabled = hasActive
        row.addSubview(relBtn)
        
        let saveBtn = NSButton(title: "Save Layout", target: self, action: #selector(saveLayout))
        saveBtn.bezelStyle = .rounded
        saveBtn.image = NSImage(systemSymbolName: "camera.fill", accessibilityDescription: nil)
        saveBtn.imagePosition = .imageLeading
        saveBtn.frame = NSRect(x: 162, y: 0, width: 154, height: 28)
        saveBtn.isEnabled = hasActive
        row.addSubview(saveBtn)
        return row
    }
    
    private func makeFooter() -> NSView {
        let foot = NSView(frame: NSRect(x: 0, y: 0, width: 316, height: 26))
        foot.widthAnchor.constraint(equalToConstant: 316).isActive = true
        foot.heightAnchor.constraint(equalToConstant: 26).isActive = true
        
        let panicBtn = NSButton(title: "Panic Reset ⌥⌘⌃R", target: self, action: #selector(panicReset))
        panicBtn.bezelStyle = .inline
        panicBtn.contentTintColor = NSColor.systemRed
        panicBtn.frame = NSRect(x: 0, y: 2, width: 150, height: 22)
        foot.addSubview(panicBtn)
        
        let quitBtn = NSButton(title: "Quit ZenDisp", target: self, action: #selector(quitApp))
        quitBtn.bezelStyle = .inline
        quitBtn.frame = NSRect(x: 236, y: 2, width: 80, height: 22)
        foot.addSubview(quitBtn)
        return foot
    }
    
    @objc private func openPreferences() { SettingsWindowController.shared.showWindow() }
    @objc private func releaseCursor() { CursorRouter.shared.releaseToHost() }
    @objc private func panicReset() { MenuBarController.shared.panicReset() }
    @objc private func quitApp() { NSApp.terminate(nil) }
    @objc private func saveLayout() { MenuPopoverController.shared.promptSaveLayout() }
}

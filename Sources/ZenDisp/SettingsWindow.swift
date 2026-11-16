import Cocoa

public final class SettingsWindowController: NSWindowController {
    public static let shared = SettingsWindowController()
    
    private var segmentedControl: NSSegmentedControl!
    private var containerView: NSView!
    private var displaysView: DisplaysTabView!
    private var layoutsView: LayoutsTabView!
    private var navigationView: NavigationTabView!
    
    private init() {
        let win = NSWindow(
            contentRect: NSRect(x: 200, y: 200, width: 580, height: 530),
            styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        win.titlebarAppearsTransparent = true
        win.titleVisibility = .hidden
        win.isMovableByWindowBackground = true
        win.isReleasedWhenClosed = false
        win.appearance = NSAppearance(named: .darkAqua)
        super.init(window: win)
        setupVisualShell()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupVisualShell() {
        guard let win = window else { return }
        let visualEffect = NSVisualEffectView(frame: win.contentView?.bounds ?? .zero)
        visualEffect.autoresizingMask = [.width, .height]
        visualEffect.material = .hudWindow
        visualEffect.blendingMode = .behindWindow
        visualEffect.state = .active
        win.contentView = visualEffect
        
        let tint = NSView(frame: visualEffect.bounds)
        tint.autoresizingMask = [.width, .height]
        tint.wantsLayer = true
        tint.layer?.backgroundColor = NSColor(red: 0.08, green: 0.10, blue: 0.14, alpha: 0.88).cgColor
        visualEffect.addSubview(tint)
        
        let header = NSView(frame: NSRect(x: 20, y: 460, width: 540, height: 50))
        let iconView = NSImageView(frame: NSRect(x: 6, y: 10, width: 32, height: 32))
        iconView.image = NSImage(named: "AppIcon") ?? NSImage(systemSymbolName: "display.2", accessibilityDescription: nil)
        header.addSubview(iconView)
        
        let titleLabel = NSTextField(labelWithString: "ZenDisp")
        titleLabel.font = NSFont.systemFont(ofSize: 15, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.frame = NSRect(x: 46, y: 24, width: 140, height: 20)
        header.addSubview(titleLabel)
        
        let subLabel = NSTextField(labelWithString: "Virtual Displays & PiP Studio")
        subLabel.font = NSFont.systemFont(ofSize: 11, weight: .medium)
        subLabel.textColor = NSColor(white: 0.82, alpha: 1.0)
        subLabel.frame = NSRect(x: 46, y: 6, width: 200, height: 16)
        header.addSubview(subLabel)
        
        segmentedControl = NSSegmentedControl(
            labels: ["Displays", "Layouts", "Navigation"],
            trackingMode: .selectOne,
            target: self,
            action: #selector(tabChanged(_:))
        )
        segmentedControl.selectedSegment = 0
        segmentedControl.segmentStyle = .texturedRounded
        segmentedControl.focusRingType = .none
        segmentedControl.frame = NSRect(x: 290, y: 12, width: 240, height: 26)
        header.addSubview(segmentedControl)
        visualEffect.addSubview(header)
        
        containerView = NSView(frame: NSRect(x: 20, y: 15, width: 540, height: 440))
        visualEffect.addSubview(containerView)
        
        let tabFrame = NSRect(x: 0, y: 0, width: 540, height: 440)
        displaysView = DisplaysTabView(frame: tabFrame)
        layoutsView = LayoutsTabView(frame: tabFrame)
        navigationView = NavigationTabView(frame: tabFrame)
        
        containerView.addSubview(displaysView)
    }
    
    @objc private func tabChanged(_ sender: NSSegmentedControl) {
        containerView.subviews.forEach { $0.removeFromSuperview() }
        switch sender.selectedSegment {
        case 0:
            containerView.addSubview(displaysView)
        case 1:
            containerView.addSubview(layoutsView)
        case 2:
            containerView.addSubview(navigationView)
        default:
            break
        }
    }
    
    public func showWindow() {
        window?.center()
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

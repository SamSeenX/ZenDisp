import Cocoa

public final class StreamWindowController: NSWindowController, NSWindowDelegate {
    public let displayID: CGDirectDisplayID
    private let streamView: StreamView
    
    public init(displayID: CGDirectDisplayID, title: String, index: Int) {
        self.displayID = displayID
        let offset = CGFloat(index * 40)
        let initialRect = NSRect(x: 100 + offset, y: 100 + offset, width: 800, height: 450)
        let window = NSWindow(
            contentRect: initialRect,
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "ZenDisp - \(title)"
        window.isReleasedWhenClosed = false
        window.backgroundColor = .black
        window.level = .floating
        window.collectionBehavior = [.fullScreenPrimary]
        window.contentAspectRatio = NSSize(width: 16, height: 9)
        window.minSize = NSSize(width: 400, height: 225)
        
        self.streamView = StreamView(frame: NSRect(x: 0, y: 0, width: 800, height: 450))
        super.init(window: window)
        window.delegate = self
        window.contentView = streamView
        
        window.makeKeyAndOrderFront(nil)
        streamView.startCapture(displayID: displayID) { _ in }
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func closeStream() {
        streamView.stopCapture()
        window?.orderOut(nil)
    }
    
    public func toggleFullScreen() {
        window?.toggleFullScreen(nil)
    }
    
    public func windowWillClose(_ notification: Notification) {
        streamView.stopCapture()
        VirtualDisplayManager.shared.teardownDisplay(id: displayID)
    }
}

public final class StreamWindowManager {
    public static let shared = StreamWindowManager()
    private var windows: [CGDirectDisplayID: StreamWindowController] = [:]
    
    private init() {}
    
    public var hasWindows: Bool { !windows.isEmpty }
    public var windowCount: Int { windows.count }
    
    public func openWindow(for displayID: CGDirectDisplayID, title: String) {
        if let existing = windows[displayID] {
            existing.window?.makeKeyAndOrderFront(nil)
            return
        }
        let controller = StreamWindowController(displayID: displayID, title: title, index: windows.count)
        windows[displayID] = controller
    }
    
    public func closeWindow(for displayID: CGDirectDisplayID) {
        windows[displayID]?.closeStream()
        windows.removeValue(forKey: displayID)
    }
    
    public func closeAllWindows() {
        for (_, controller) in windows {
            controller.closeStream()
        }
        windows.removeAll()
    }
    
    public func toggleFullScreen(for displayID: CGDirectDisplayID? = nil) {
        if let id = displayID, let controller = windows[id] {
            controller.toggleFullScreen()
        } else {
            windows.values.first?.toggleFullScreen()
        }
    }
}

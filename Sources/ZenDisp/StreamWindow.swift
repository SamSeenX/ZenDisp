import Cocoa

public final class StreamWindowController: NSWindowController, NSWindowDelegate {
    public let displayID: CGDirectDisplayID
    private let streamView: StreamView
    private let storageKey: String
    
    public init(displayID: CGDirectDisplayID, title: String, width: UInt = 1920, height: UInt = 1080, index: Int, storageKey: String = "") {
        self.displayID = displayID
        self.storageKey = storageKey
        let isPortrait = height > width
        let w: CGFloat = isPortrait ? 380 : (width * 2 == height * 3 ? 640 : 720)
        let h: CGFloat = CGFloat(Double(w) * Double(height) / Double(width))
        let screenW = NSScreen.main?.visibleFrame.width ?? 1440
        let screenH = NSScreen.main?.visibleFrame.height ?? 900
        let xPos = min(50 + CGFloat(index) * (w + 20), screenW - w - 20)
        let yPos = max(screenH - h - 60 - CGFloat(index * 20), 50)
        let defaultRect = NSRect(x: xPos, y: yPos, width: w, height: h)
        let initialRect = WindowStateManager.shared.savedFrame(for: storageKey) ?? defaultRect
        
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
        window.contentAspectRatio = NSSize(width: Int(width), height: Int(height))
        window.minSize = NSSize(width: max(w * 0.4, 240), height: max(h * 0.4, 180))
        
        self.streamView = StreamView(frame: NSRect(x: 0, y: 0, width: initialRect.width, height: initialRect.height))
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
    
    public func windowDidMove(_ notification: Notification) {
        if let win = window, !storageKey.isEmpty {
            WindowStateManager.shared.saveFrame(win.frame, for: storageKey)
        }
    }
    
    public func windowDidEndLiveResize(_ notification: Notification) {
        if let win = window, !storageKey.isEmpty {
            WindowStateManager.shared.saveFrame(win.frame, for: storageKey)
        }
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
    
    public func openWindow(for displayID: CGDirectDisplayID, title: String, width: UInt = 1920, height: UInt = 1080, storageKey: String = "") {
        if let existing = windows[displayID] {
            existing.window?.makeKeyAndOrderFront(nil)
            return
        }
        let controller = StreamWindowController(
            displayID: displayID,
            title: title,
            width: width,
            height: height,
            index: windows.count,
            storageKey: storageKey
        )
        windows[displayID] = controller
    }
    
    public func closeWindow(for displayID: CGDirectDisplayID) {
        windows[displayID]?.closeStream()
        windows.removeValue(forKey: displayID)
    }
    
    public func window(for displayID: CGDirectDisplayID) -> NSWindow? {
        return windows[displayID]?.window
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

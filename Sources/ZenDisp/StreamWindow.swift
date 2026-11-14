import Cocoa

public final class StreamWindowController: NSWindowController, NSWindowDelegate {
    public static let shared = StreamWindowController()
    
    private let streamView = StreamView(frame: NSRect(x: 0, y: 0, width: 960, height: 540))
    private var isPresented = false
    
    private init() {
        let initialRect = NSRect(x: 100, y: 100, width: 960, height: 540)
        let window = NSWindow(
            contentRect: initialRect,
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "ZenDisp Stream Viewer (PiP)"
        window.isReleasedWhenClosed = false
        window.backgroundColor = .black
        window.level = .floating
        window.collectionBehavior = [.fullScreenPrimary]
        window.contentAspectRatio = NSSize(width: 16, height: 9)
        window.minSize = NSSize(width: 480, height: 270)
        
        super.init(window: window)
        window.delegate = self
        window.contentView = streamView
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var isWindowVisible: Bool {
        return window?.isVisible ?? false
    }
    
    public func showStream(displayID: CGDirectDisplayID) {
        guard let window = window else { return }
        
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        isPresented = true
        
        streamView.startCapture(displayID: displayID) { [weak self] success in
            if !success {
                DispatchQueue.main.async {
                    self?.window?.title = "ZenDisp Stream Viewer (Waiting for Screen Recording Permission...)"
                }
            } else {
                DispatchQueue.main.async {
                    self?.window?.title = "ZenDisp Stream Viewer (PiP Live)"
                }
            }
        }
    }
    
    public func closeStream() {
        streamView.stopCapture()
        window?.orderOut(nil)
        isPresented = false
    }
    
    public func toggleFullScreen() {
        window?.toggleFullScreen(nil)
    }
    
    public func windowWillClose(_ notification: Notification) {
        streamView.stopCapture()
        isPresented = false
    }
}

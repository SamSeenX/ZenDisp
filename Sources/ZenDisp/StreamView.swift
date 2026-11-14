import Cocoa
import ScreenCaptureKit
import CoreMedia
import QuartzCore

public final class StreamView: NSView, SCStreamOutput, SCStreamDelegate {
    private var stream: SCStream?
    private var isStreaming = false
    private let renderLayer = CALayer()
    private var targetDisplayID: CGDirectDisplayID?
    
    public override var isFlipped: Bool {
        return true
    }
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupLayer()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayer()
    }
    
    private func setupLayer() {
        wantsLayer = true
        renderLayer.contentsGravity = .resizeAspect
        renderLayer.backgroundColor = NSColor.black.cgColor
        layer = renderLayer
    }
    
    public func startCapture(displayID: CGDirectDisplayID, completion: @escaping (Bool) -> Void) {
        stopCapture()
        self.targetDisplayID = displayID
        
        SCShareableContent.getExcludingDesktopWindows(false, onScreenWindowsOnly: true) { [weak self] content, error in
            guard let self = self, let content = content, error == nil else {
                DispatchQueue.main.async { completion(false) }
                return
            }
            
            guard let targetDisplay = content.displays.first(where: { $0.displayID == displayID }) else {
                DispatchQueue.main.async { completion(false) }
                return
            }
            
            let filter = SCContentFilter(display: targetDisplay, excludingWindows: [])
            let config = SCStreamConfiguration()
            config.width = targetDisplay.width
            config.height = targetDisplay.height
            config.minimumFrameInterval = CMTime(value: 1, timescale: 60)
            config.queueDepth = 3
            config.showsCursor = true
            config.pixelFormat = kCVPixelFormatType_32BGRA
            
            do {
                let stream = SCStream(filter: filter, configuration: config, delegate: self)
                try stream.addStreamOutput(self, type: .screen, sampleHandlerQueue: DispatchQueue.main)
                stream.startCapture { captureError in
                    DispatchQueue.main.async {
                        if captureError == nil {
                            self.stream = stream
                            self.isStreaming = true
                            completion(true)
                        } else {
                            completion(false)
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async { completion(false) }
            }
        }
    }
    
    public func stopCapture() {
        guard isStreaming, let stream = stream else { return }
        stream.stopCapture { _ in }
        self.stream = nil
        self.isStreaming = false
        self.targetDisplayID = nil
        DispatchQueue.main.async {
            self.renderLayer.contents = nil
        }
    }
    
    public override func mouseDown(with event: NSEvent) {
        guard let id = targetDisplayID else { super.mouseDown(with: event); return }
        let location = convert(event.locationInWindow, from: nil)
        InputForwarder.shared.forwardClick(localPoint: location, viewSize: bounds.size, displayID: id, button: .left)
    }
    
    public override func rightMouseDown(with event: NSEvent) {
        guard let id = targetDisplayID else { super.rightMouseDown(with: event); return }
        let location = convert(event.locationInWindow, from: nil)
        InputForwarder.shared.forwardClick(localPoint: location, viewSize: bounds.size, displayID: id, button: .right)
    }
    
    public override func mouseDragged(with event: NSEvent) {
        guard let id = targetDisplayID else { super.mouseDragged(with: event); return }
        let location = convert(event.locationInWindow, from: nil)
        InputForwarder.shared.forwardDrag(localPoint: location, viewSize: bounds.size, displayID: id)
    }
    
    public override func scrollWheel(with event: NSEvent) {
        guard let id = targetDisplayID else { super.scrollWheel(with: event); return }
        let location = convert(event.locationInWindow, from: nil)
        let dY = Int32(event.scrollingDeltaY * 4)
        let dX = Int32(event.scrollingDeltaX * 4)
        InputForwarder.shared.forwardScroll(localPoint: location, viewSize: bounds.size, displayID: id, deltaY: dY, deltaX: dX)
    }
    
    public func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
        guard type == .screen else { return }
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        guard let ioSurface = CVPixelBufferGetIOSurface(imageBuffer)?.takeUnretainedValue() else { return }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        renderLayer.contents = ioSurface
        CATransaction.commit()
    }
    
    public func stream(_ stream: SCStream, didStopWithError error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.stopCapture()
        }
    }
    
    deinit {
        stopCapture()
    }
}

import Cocoa
import ScreenCaptureKit
import CoreMedia
import QuartzCore

public final class StreamView: NSView, SCStreamOutput, SCStreamDelegate {
    private var stream: SCStream?
    private var isStreaming = false
    private let renderLayer = CALayer()
    private var targetDisplayID: CGDirectDisplayID?

    public override var isFlipped: Bool { true }
    public override var acceptsFirstResponder: Bool { true }

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
        targetDisplayID = displayID

        SCShareableContent.getExcludingDesktopWindows(false, onScreenWindowsOnly: true) { [weak self] content, error in
            guard let self, let content, error == nil else {
                DispatchQueue.main.async { completion(false) }
                return
            }
            guard let disp = content.displays.first(where: { $0.displayID == displayID }) else {
                DispatchQueue.main.async { completion(false) }
                return
            }
            let filter = SCContentFilter(display: disp, excludingWindows: [])
            let config = SCStreamConfiguration()
            config.width = disp.width
            config.height = disp.height
            config.minimumFrameInterval = CMTime(value: 1, timescale: 60)
            config.queueDepth = 3
            config.showsCursor = true
            config.pixelFormat = kCVPixelFormatType_32BGRA
            do {
                let s = SCStream(filter: filter, configuration: config, delegate: self)
                try s.addStreamOutput(self, type: .screen, sampleHandlerQueue: .main)
                s.startCapture { err in
                    DispatchQueue.main.async {
                        if err == nil {
                            self.stream = s
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
        guard isStreaming, let s = stream else { return }
        s.stopCapture { _ in }
        stream = nil
        isStreaming = false
        targetDisplayID = nil
        DispatchQueue.main.async { self.renderLayer.contents = nil }
    }

    // MARK: - Mouse: snap cursor to virtual display on click, leave it there

    public override func mouseDown(with event: NSEvent) {
        guard let id = targetDisplayID else { super.mouseDown(with: event); return }
        window?.makeFirstResponder(self)
        let pt = convert(event.locationInWindow, from: nil)
        CursorRouter.shared.snapToVirtual(localPoint: pt, viewSize: bounds.size, displayID: id)
    }

    public override func rightMouseDown(with event: NSEvent) {
        guard let id = targetDisplayID else { super.rightMouseDown(with: event); return }
        let pt = convert(event.locationInWindow, from: nil)
        CursorRouter.shared.snapToVirtual(localPoint: pt, viewSize: bounds.size, displayID: id)
    }

    // Scroll is forwarded synthetically since it has no position concept on warp
    public override func scrollWheel(with event: NSEvent) {
        guard let id = targetDisplayID else { super.scrollWheel(with: event); return }
        guard let target = CursorRouter.shared.mapToVirtualGlobal(
            local: convert(event.locationInWindow, from: nil),
            viewSize: bounds.size,
            displayID: id
        ) else { return }
        if let ev = CGEvent(scrollWheelEvent2Source: nil, units: .pixel, wheelCount: 2,
                            wheel1: Int32(event.scrollingDeltaY * 4),
                            wheel2: Int32(event.scrollingDeltaX * 4), wheel3: 0) {
            ev.location = target
            ev.post(tap: .cghidEventTap)
        }
    }

    // MARK: - Frame rendering

    public func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
        guard type == .screen,
              let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
              let ioSurface = CVPixelBufferGetIOSurface(imageBuffer)?.takeUnretainedValue() else { return }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        renderLayer.contents = ioSurface
        CATransaction.commit()
    }

    public func stream(_ stream: SCStream, didStopWithError error: Error) {
        DispatchQueue.main.async { self.stopCapture() }
    }

    deinit { stopCapture() }
}

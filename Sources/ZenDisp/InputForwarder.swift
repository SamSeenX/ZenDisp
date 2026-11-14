import Cocoa
import CoreGraphics

public final class InputForwarder {
    public static let shared = InputForwarder()
    
    private init() {}
    
    public func aspectFitRect(viewSize: CGSize, displaySize: CGSize) -> CGRect {
        guard viewSize.width > 0, viewSize.height > 0, displaySize.width > 0, displaySize.height > 0 else {
            return CGRect(origin: .zero, size: viewSize)
        }
        let viewAspect = viewSize.width / viewSize.height
        let dispAspect = displaySize.width / displaySize.height
        
        if viewAspect > dispAspect {
            let renderHeight = viewSize.height
            let renderWidth = renderHeight * dispAspect
            let offsetX = (viewSize.width - renderWidth) / 2.0
            return CGRect(x: offsetX, y: 0, width: renderWidth, height: renderHeight)
        } else {
            let renderWidth = viewSize.width
            let renderHeight = renderWidth / dispAspect
            let offsetY = (viewSize.height - renderHeight) / 2.0
            return CGRect(x: 0, y: offsetY, width: renderWidth, height: renderHeight)
        }
    }
    
    public func mapToGlobalPoint(localPoint: CGPoint, viewSize: CGSize, displayID: CGDirectDisplayID) -> CGPoint? {
        let displayBounds = CGDisplayBounds(displayID)
        let fitRect = aspectFitRect(viewSize: viewSize, displaySize: displayBounds.size)
        
        guard fitRect.contains(localPoint), fitRect.width > 0, fitRect.height > 0 else {
            return nil
        }
        
        let normalizedX = (localPoint.x - fitRect.origin.x) / fitRect.width
        let normalizedY = (localPoint.y - fitRect.origin.y) / fitRect.height
        
        let globalX = displayBounds.origin.x + (normalizedX * displayBounds.width)
        let globalY = displayBounds.origin.y + (normalizedY * displayBounds.height)
        
        return CGPoint(x: globalX, y: globalY)
    }
    
    public func forwardClick(localPoint: CGPoint, viewSize: CGSize, displayID: CGDirectDisplayID, button: CGMouseButton = .left) {
        guard let targetPoint = mapToGlobalPoint(localPoint: localPoint, viewSize: viewSize, displayID: displayID) else {
            return
        }
        
        let originalPos = NSEvent.mouseLocation
        let flippedOriginalY = (NSScreen.screens.first?.frame.height ?? 1080) - originalPos.y
        let hostCursor = CGPoint(x: originalPos.x, y: flippedOriginalY)
        
        let downType: CGEventType = (button == .right) ? .rightMouseDown : .leftMouseDown
        let upType: CGEventType = (button == .right) ? .rightMouseUp : .leftMouseUp
        
        if let moveEvt = CGEvent(mouseEventSource: nil, mouseType: .mouseMoved, mouseCursorPosition: targetPoint, mouseButton: button) {
            moveEvt.post(tap: .cghidEventTap)
        }
        
        if let downEvt = CGEvent(mouseEventSource: nil, mouseType: downType, mouseCursorPosition: targetPoint, mouseButton: button) {
            downEvt.post(tap: .cghidEventTap)
        }
        
        usleep(15000)
        
        if let upEvt = CGEvent(mouseEventSource: nil, mouseType: upType, mouseCursorPosition: targetPoint, mouseButton: button) {
            upEvt.post(tap: .cghidEventTap)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
            CGWarpMouseCursorPosition(hostCursor)
        }
    }
    
    public func forwardDrag(localPoint: CGPoint, viewSize: CGSize, displayID: CGDirectDisplayID) {
        guard let targetPoint = mapToGlobalPoint(localPoint: localPoint, viewSize: viewSize, displayID: displayID) else {
            return
        }
        if let dragEvt = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDragged, mouseCursorPosition: targetPoint, mouseButton: .left) {
            dragEvt.post(tap: .cghidEventTap)
        }
    }
    
    public func forwardScroll(localPoint: CGPoint, viewSize: CGSize, displayID: CGDirectDisplayID, deltaY: Int32, deltaX: Int32) {
        guard let targetPoint = mapToGlobalPoint(localPoint: localPoint, viewSize: viewSize, displayID: displayID) else {
            return
        }
        if let scrollEvt = CGEvent(scrollWheelEvent2Source: nil, units: .pixel, wheelCount: 2, wheel1: deltaY, wheel2: deltaX, wheel3: 0) {
            scrollEvt.location = targetPoint
            scrollEvt.post(tap: .cghidEventTap)
        }
    }
}

import Cocoa
import CoreGraphics

// CursorRouter handles cursor snap-to-virtual and release-to-host.
// No synthetic mouse events are posted. The physical cursor is warped
// directly into the virtual display coordinate space and left there.
// The user interacts naturally. Release warps back to the host screen.
public final class CursorRouter {
    public static let shared = CursorRouter()

    public private(set) var isLockedToVirtual = false
    private var virtualDisplayID: CGDirectDisplayID?
    private var lastHostPosition: CGPoint = .zero
    private var spaceObserver: Any?

    private init() {
        observeSpaceChanges()
    }

    // MARK: - Public API

    public func configure(displayID: CGDirectDisplayID) {
        virtualDisplayID = displayID
    }

    public func reset() {
        releaseToHost()
        virtualDisplayID = nil
    }

    /// Called when user clicks inside the PiP stream view.
    /// Maps the view-local point to the virtual display global coordinate
    /// and physically warps the cursor there. No synthetic events posted.
    public func snapToVirtual(localPoint: CGPoint, viewSize: CGSize) {
        guard let id = virtualDisplayID,
              let target = mapToVirtualGlobal(local: localPoint, viewSize: viewSize, displayID: id) else { return }

        // Save where we came from so the release hotkey can jump back
        lastHostPosition = currentHostCursorPosition()

        CGAssociateMouseAndMouseCursorPosition(1) // ensure association active
        CGWarpMouseCursorPosition(target)
        isLockedToVirtual = true
    }

    /// Release hotkey or Space-swipe: warp cursor back to host screen.
    public func releaseToHost() {
        CGAssociateMouseAndMouseCursorPosition(1)
        let target = (lastHostPosition.x == 0 && lastHostPosition.y == 0) ? mainScreenCenter() : lastHostPosition
        CGWarpMouseCursorPosition(target)
        isLockedToVirtual = false
    }

    // MARK: - Coordinate Mapping

    public func mapToVirtualGlobal(local: CGPoint, viewSize: CGSize, displayID: CGDirectDisplayID) -> CGPoint? {
        let disp = CGDisplayBounds(displayID)
        guard disp.width > 0, disp.height > 0, viewSize.width > 0, viewSize.height > 0 else { return nil }

        let viewAspect = viewSize.width / viewSize.height
        let dispAspect = disp.width / disp.height
        let fitRect: CGRect

        if viewAspect > dispAspect {
            let h = viewSize.height
            let w = h * dispAspect
            fitRect = CGRect(x: (viewSize.width - w) / 2, y: 0, width: w, height: h)
        } else {
            let w = viewSize.width
            let h = w / dispAspect
            fitRect = CGRect(x: 0, y: (viewSize.height - h) / 2, width: w, height: h)
        }

        guard fitRect.contains(local), fitRect.width > 0, fitRect.height > 0 else { return nil }

        let nx = (local.x - fitRect.origin.x) / fitRect.width
        let ny = (local.y - fitRect.origin.y) / fitRect.height

        // CGDisplayBounds uses flipped-Y (top-left origin) for multi-display layout.
        // CGWarpMouseCursorPosition also expects top-left origin coordinates globally.
        return CGPoint(x: disp.origin.x + nx * disp.width,
                       y: disp.origin.y + ny * disp.height)
    }

    // MARK: - Space change observer (auto-release on 3-finger swipe away)

    private func observeSpaceChanges() {
        spaceObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.activeSpaceDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            // When the user swipes to a different Space, release the cursor
            // so trackpad gestures and host keyboard shortcuts work normally.
            self?.releaseToHost()
        }
    }

    // MARK: - Helpers

    private func currentHostCursorPosition() -> CGPoint {
        // NSEvent.mouseLocation is flipped (bottom-left origin).
        // Convert to CGWarp's top-left origin system.
        let p = NSEvent.mouseLocation
        let screenH = NSScreen.main?.frame.height ?? 768
        return CGPoint(x: p.x, y: screenH - p.y)
    }

    private func mainScreenCenter() -> CGPoint {
        let b = CGDisplayBounds(CGMainDisplayID())
        return CGPoint(x: b.midX, y: b.midY)
    }
}

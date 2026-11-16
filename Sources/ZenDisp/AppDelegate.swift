import Cocoa
import Carbon

public final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private let statusMenu = NSMenu()
    private var eventMonitor: Any?
    private var localMonitor: Any?
    
    public func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupPanicHotkey()
    }

    public func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        SettingsWindowController.shared.showWindow()
        return true
    }
    
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.title = "ZenDisp"
            button.image = NSImage(systemSymbolName: "display.2", accessibilityDescription: "ZenDisp")
            button.imagePosition = .imageLeading
            MenuPopoverController.shared.registerButton(button)
        }
    }
    
    private func setupPanicHotkey() {
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
            let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            if flags == [.option, .command, .control] && event.keyCode == 15 {
                DispatchQueue.main.async { MenuBarController.shared.panicReset() }
            } else if flags.contains(.control) && event.keyCode == 53 {
                DispatchQueue.main.async { CursorRouter.shared.releaseToHost() }
            }
        }
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            if flags.contains(.control) && event.keyCode == 53 {
                DispatchQueue.main.async { CursorRouter.shared.releaseToHost() }
                return nil
            }
            return event
        }
    }
    
    public func applicationWillTerminate(_ notification: Notification) {
        MenuBarController.shared.panicReset()
    }
}

import Cocoa

public final class WindowStateManager {
    public static let shared = WindowStateManager()
    private let storageKey = "ZenDisp_SavedWindowFrames"
    
    private init() {}
    
    public func saveFrame(_ frame: NSRect, for key: String) {
        var dict = loadDict()
        dict[key] = NSStringFromRect(frame)
        UserDefaults.standard.set(dict, forKey: storageKey)
    }
    
    public func savedFrame(for key: String) -> NSRect? {
        let dict = loadDict()
        guard let str = dict[key] else { return nil }
        let rect = NSRectFromString(str)
        guard rect.width > 100 && rect.height > 100 else { return nil }
        
        let isVisibleOnAnyScreen = NSScreen.screens.contains { screen in
            screen.visibleFrame.intersects(rect)
        }
        guard isVisibleOnAnyScreen else { return nil }
        return rect
    }
    
    public func clearSavedFrames() {
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
    
    private func loadDict() -> [String: String] {
        return UserDefaults.standard.dictionary(forKey: storageKey) as? [String: String] ?? [:]
    }
}

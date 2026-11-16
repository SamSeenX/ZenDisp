import Foundation

private func gcd(_ a: UInt, _ b: UInt) -> UInt {
    var x = a, y = b
    while y != 0 {
        let t = y
        y = x % y
        x = t
    }
    return x
}

public struct DisplayPreset: Codable, Equatable {
    public let id: String
    public let width: UInt
    public let height: UInt
    public let refreshRate: Double
    public let name: String
    public let isCustom: Bool
    public let isHiDPI: Bool
    
    public init(width: UInt, height: UInt, refreshRate: Double = 60.0, name: String, isCustom: Bool = false, isHiDPI: Bool = true) {
        self.id = "\(width)x\(height)@\(Int(refreshRate))"
        self.width = width
        self.height = height
        self.refreshRate = refreshRate
        self.name = name
        self.isCustom = isCustom
        self.isHiDPI = isHiDPI
    }
    
    public func withHiDPI(_ enabled: Bool) -> DisplayPreset {
        return DisplayPreset(width: width, height: height, refreshRate: refreshRate, name: name, isCustom: isCustom, isHiDPI: enabled)
    }
    
    public var aspectLabel: String {
        let g = gcd(width, height)
        let rw = width / g
        let rh = height / g
        let mode = isHiDPI ? "HiDPI" : "1x"
        if rw == 8 && rh == 5 { return "16:10 • \(mode)" }
        if height > width { return "\(rw):\(rh) Portrait • \(mode)" }
        return "\(rw):\(rh) • \(mode)"
    }
    
    public static let default1080p = DisplayPreset(width: 1920, height: 1080, name: "1920x1080 (1080p 16:9)")
    public static let defaultCoding = DisplayPreset(width: 1920, height: 1280, name: "1920x1280 (Coding 3:2)")
    public static let defaultPortrait = DisplayPreset(width: 1080, height: 1920, name: "1080x1920 (Tall Portrait 9:16)")
    public static let default1440p = DisplayPreset(width: 2560, height: 1440, name: "2560x1440 (2K 16:9)")
    public static let default900p = DisplayPreset(width: 1600, height: 900, name: "1600x900 (16:9)")
    
    public static let defaults: [DisplayPreset] = [.default1080p, .defaultCoding, .defaultPortrait, .default1440p, .default900p]
}

public struct LayoutGroup: Codable, Equatable {
    public let id: String
    public let name: String
    public let presets: [DisplayPreset]
    
    public init(name: String, presets: [DisplayPreset]) {
        self.id = UUID().uuidString
        self.name = name
        self.presets = presets
    }
}

public final class PresetManager {
    public static let shared = PresetManager()
    public static let didChangeNotification = Notification.Name("ZenDisp_PresetsDidChange")
    private let customPresetsKey = "ZenDisp_CustomPresets"
    private let layoutGroupsKey = "ZenDisp_LayoutGroups_v2"
    private let hiDPIOverridesKey = "ZenDisp_HiDPIOverrides"
    
    public private(set) var customPresets: [DisplayPreset] = []
    public private(set) var layoutGroups: [LayoutGroup] = []
    private var hiDPIOverrides: [String: Bool] = [:]
    
    private init() {
        loadData()
    }
    
    public var allPresets: [DisplayPreset] {
        let list = DisplayPreset.defaults + customPresets
        return list.map { p in
            let enabled = hiDPIOverrides[p.id] ?? p.isHiDPI
            return p.withHiDPI(enabled)
        }
    }
    
    public func toggleHiDPI(for presetID: String) {
        let current = isHiDPI(for: presetID)
        setHiDPI(!current, for: presetID)
    }
    
    public func setHiDPI(_ enabled: Bool, for presetID: String) {
        hiDPIOverrides[presetID] = enabled
        UserDefaults.standard.set(hiDPIOverrides, forKey: hiDPIOverridesKey)
        NotificationCenter.default.post(name: PresetManager.didChangeNotification, object: nil)
    }
    
    public func isHiDPI(for presetID: String) -> Bool {
        return hiDPIOverrides[presetID] ?? true
    }
    
    public func addCustomPreset(width: UInt, height: UInt, name: String, isHiDPI: Bool = true) -> DisplayPreset {
        let preset = DisplayPreset(width: width, height: height, name: name, isCustom: true, isHiDPI: isHiDPI)
        customPresets.removeAll { $0.width == width && $0.height == height }
        customPresets.append(preset)
        hiDPIOverrides[preset.id] = isHiDPI
        saveCustomPresets()
        NotificationCenter.default.post(name: PresetManager.didChangeNotification, object: nil)
        return preset
    }
    
    public func removeCustomPreset(id: String) {
        customPresets.removeAll { $0.id == id }
        hiDPIOverrides.removeValue(forKey: id)
        saveCustomPresets()
        NotificationCenter.default.post(name: PresetManager.didChangeNotification, object: nil)
    }
    
    public func addLayoutGroup(name: String, presets: [DisplayPreset]) {
        layoutGroups.append(LayoutGroup(name: name, presets: presets))
        saveLayoutGroups()
    }
    
    public func removeLayoutGroup(id: String) {
        layoutGroups.removeAll { $0.id == id }
        saveLayoutGroups()
        NotificationCenter.default.post(name: PresetManager.didChangeNotification, object: nil)
    }
    
    @discardableResult
    public func saveCurrentLayout(name: String) -> LayoutGroup? {
        let list = VirtualDisplayManager.shared.activeDisplaysList()
        guard !list.isEmpty else { return nil }
        let presets = list.map { $0.preset }
        let group = LayoutGroup(name: name, presets: presets)
        layoutGroups.append(group)
        saveLayoutGroups()
        for (index, item) in list.enumerated() {
            if let frame = StreamWindowManager.shared.window(for: item.id)?.frame {
                WindowStateManager.shared.saveFrame(frame, for: "Group_\(group.id)_Slot_\(index)")
            }
        }
        NotificationCenter.default.post(name: PresetManager.didChangeNotification, object: nil)
        return group
    }
    
    private func loadData() {
        hiDPIOverrides = UserDefaults.standard.dictionary(forKey: hiDPIOverridesKey) as? [String: Bool] ?? [:]
        if let data = UserDefaults.standard.data(forKey: customPresetsKey),
           let decoded = try? JSONDecoder().decode([DisplayPreset].self, from: data) {
            customPresets = decoded
        }
        if let data = UserDefaults.standard.data(forKey: layoutGroupsKey),
           let decoded = try? JSONDecoder().decode([LayoutGroup].self, from: data),
           !decoded.isEmpty {
            layoutGroups = decoded
        } else {
            layoutGroups = [
                LayoutGroup(name: "Side-by-Side Dual Workstation (1:1)", presets: [.default1080p, .default1080p]),
                LayoutGroup(name: "Developer Coding Suite (3:2 + Tall 9:16)", presets: [.defaultCoding, .defaultPortrait])
            ]
            saveLayoutGroups()
        }
    }
    
    private func saveCustomPresets() {
        if let encoded = try? JSONEncoder().encode(customPresets) {
            UserDefaults.standard.set(encoded, forKey: customPresetsKey)
        }
    }
    
    private func saveLayoutGroups() {
        if let encoded = try? JSONEncoder().encode(layoutGroups) {
            UserDefaults.standard.set(encoded, forKey: layoutGroupsKey)
        }
    }
}

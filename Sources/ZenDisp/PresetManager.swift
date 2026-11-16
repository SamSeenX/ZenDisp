import Foundation

public struct DisplayPreset: Codable, Equatable {
    public let id: String
    public let width: UInt
    public let height: UInt
    public let refreshRate: Double
    public let name: String
    public let isCustom: Bool
    
    public init(width: UInt, height: UInt, refreshRate: Double = 60.0, name: String, isCustom: Bool = false) {
        self.id = "\(width)x\(height)@\(Int(refreshRate))"
        self.width = width
        self.height = height
        self.refreshRate = refreshRate
        self.name = name
        self.isCustom = isCustom
    }
    
    public static let default900p = DisplayPreset(width: 1600, height: 900, name: "1600x900 (16:9)")
    public static let default1080p = DisplayPreset(width: 1920, height: 1080, name: "1920x1080 (1080p)")
    public static let default1440p = DisplayPreset(width: 2560, height: 1440, name: "2560x1440 (2K)")
    
    public static let defaults: [DisplayPreset] = [.default900p, .default1080p, .default1440p]
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
    private let customPresetsKey = "ZenDisp_CustomPresets"
    private let layoutGroupsKey = "ZenDisp_LayoutGroups"
    
    public private(set) var customPresets: [DisplayPreset] = []
    public private(set) var layoutGroups: [LayoutGroup] = []
    
    private init() {
        loadData()
    }
    
    public var allPresets: [DisplayPreset] {
        return DisplayPreset.defaults + customPresets
    }
    
    public func addCustomPreset(width: UInt, height: UInt, name: String) -> DisplayPreset {
        let preset = DisplayPreset(width: width, height: height, name: name, isCustom: true)
        customPresets.removeAll { $0.width == width && $0.height == height }
        customPresets.append(preset)
        saveCustomPresets()
        return preset
    }
    
    public func removeCustomPreset(id: String) {
        customPresets.removeAll { $0.id == id }
        saveCustomPresets()
    }
    
    public func addLayoutGroup(name: String, presets: [DisplayPreset]) {
        let group = LayoutGroup(name: name, presets: presets)
        layoutGroups.append(group)
        saveLayoutGroups()
    }
    
    public func removeLayoutGroup(id: String) {
        layoutGroups.removeAll { $0.id == id }
        saveLayoutGroups()
    }
    
    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: customPresetsKey),
           let decoded = try? JSONDecoder().decode([DisplayPreset].self, from: data) {
            customPresets = decoded
        }
        if let data = UserDefaults.standard.data(forKey: layoutGroupsKey),
           let decoded = try? JSONDecoder().decode([LayoutGroup].self, from: data) {
            layoutGroups = decoded
        } else {
            layoutGroups = [
                LayoutGroup(name: "Dual 1080p Workstation", presets: [.default1080p, .default1080p]),
                LayoutGroup(name: "Coding + Reference Layout", presets: [.default1440p, .default900p])
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

import Cocoa
import CoreGraphics

public final class VirtualDisplayManager {
    public static let shared = VirtualDisplayManager()
    
    private var activeDisplays: [CGDirectDisplayID: (display: AnyObject, preset: DisplayPreset)] = [:]
    private var serialCounter: UInt32 = 1000
    
    private init() {}
    
    public var activeCount: Int { activeDisplays.count }
    public var activeDisplayIDs: [CGDirectDisplayID] { Array(activeDisplays.keys) }
    
    public func preset(for id: CGDirectDisplayID) -> DisplayPreset? {
        return activeDisplays[id]?.preset
    }
    
    public func createDisplay(preset: DisplayPreset, storageKey: String? = nil) -> CGDirectDisplayID? {
        guard let descClass = NSClassFromString("CGVirtualDisplayDescriptor") as? NSObject.Type,
              let modeClass = NSClassFromString("CGVirtualDisplayMode") as? NSObject.Type,
              let settingsClass = NSClassFromString("CGVirtualDisplaySettings") as? NSObject.Type,
              let displayClass = NSClassFromString("CGVirtualDisplay") as? NSObject.Type else {
            return nil
        }
        
        let scale = max(1, min(preset.scaleFactor, 3))
        let pixelWidth = preset.width * scale
        let pixelHeight = preset.height * scale
        let dpi: Double = 110.0 * Double(scale)
        
        serialCounter += 1
        let descriptor = descClass.init()
        descriptor.setValue("ZenDisp \(preset.name) #\(activeDisplays.count + 1)", forKey: "name")
        descriptor.setValue(UInt32(pixelWidth), forKey: "maxPixelsWide")
        descriptor.setValue(UInt32(pixelHeight), forKey: "maxPixelsHigh")
        descriptor.setValue(
            NSValue(size: NSSize(width: Double(pixelWidth) * 25.4 / dpi, height: Double(pixelHeight) * 25.4 / dpi)),
            forKey: "sizeInMillimeters"
        )
        descriptor.setValue(serialCounter, forKey: "serialNum")
        descriptor.setValue(UInt32(0x5a44), forKey: "productID")
        descriptor.setValue(UInt32(0x5353), forKey: "vendorID")
        descriptor.setValue(DispatchQueue.main, forKey: "queue")
        
        guard let modeAlloc = modeClass.perform(NSSelectorFromString("alloc"))?.takeRetainedValue() as AnyObject?,
              let modeMethod = modeClass.instanceMethod(for: NSSelectorFromString("initWithWidth:height:refreshRate:")) else {
            return nil
        }
        let modeInitFn = unsafeBitCast(
            modeMethod,
            to: (@convention(c) (AnyObject, Selector, UInt, UInt, Double) -> AnyObject).self
        )
        let mode = modeInitFn(modeAlloc, NSSelectorFromString("initWithWidth:height:refreshRate:"), pixelWidth, pixelHeight, preset.refreshRate)
        
        let settings = settingsClass.init()
        settings.setValue([mode], forKey: "modes")
        let hiDPIValue: UInt32 = preset.isHiDPI ? 1 : 0
        settings.setValue(hiDPIValue, forKey: "hiDPI")
        
        guard let displayAlloc = displayClass.perform(NSSelectorFromString("alloc"))?.takeRetainedValue() as AnyObject?,
              let displayMethod = displayClass.instanceMethod(for: NSSelectorFromString("initWithDescriptor:")) else {
            return nil
        }
        let displayInitFn = unsafeBitCast(
            displayMethod,
            to: (@convention(c) (AnyObject, Selector, AnyObject) -> AnyObject).self
        )
        let displayInstance = displayInitFn(displayAlloc, NSSelectorFromString("initWithDescriptor:"), descriptor)
        
        guard let applyMethod = displayClass.instanceMethod(for: NSSelectorFromString("applySettings:")) else { return nil }
        let applyFn = unsafeBitCast(applyMethod, to: (@convention(c) (AnyObject, Selector, AnyObject) -> Bool).self)
        guard applyFn(displayInstance, NSSelectorFromString("applySettings:"), settings) else { return nil }
        
        guard let displayIDMethod = displayClass.instanceMethod(for: NSSelectorFromString("displayID")) else { return nil }
        let displayIDFn = unsafeBitCast(displayIDMethod, to: (@convention(c) (AnyObject, Selector) -> CGDirectDisplayID).self)
        let id = displayIDFn(displayInstance, NSSelectorFromString("displayID"))
        guard id != 0 else { return nil }
        
        activeDisplays[id] = (displayInstance, preset)
        let key = storageKey ?? "Preset_\(preset.id)"
        StreamWindowManager.shared.openWindow(for: id, title: preset.name, width: preset.width, height: preset.height, storageKey: key)
        NotificationCenter.default.post(name: PresetManager.didChangeNotification, object: nil)
        return id
    }
    
    public func launchGroup(_ group: LayoutGroup) {
        for (index, preset) in group.presets.enumerated() {
            let key = "Group_\(group.id)_Slot_\(index)"
            _ = createDisplay(preset: preset, storageKey: key)
        }
    }
    
    public func activeDisplaysList() -> [(id: CGDirectDisplayID, preset: DisplayPreset)] {
        return activeDisplays.map { ($0.key, $0.value.preset) }
    }
    
    public func setScale(_ scale: UInt, for id: CGDirectDisplayID) {
        guard let info = activeDisplays[id] else { return }
        let preset = info.preset
        let validScale = max(1, min(scale, 3))
        let newPreset = preset.withScale(validScale)
        PresetManager.shared.setScale(validScale, for: preset.id)
        let savedKey = "Active_\(id)"
        if let win = StreamWindowManager.shared.window(for: id) {
            WindowStateManager.shared.saveFrame(win.frame, for: savedKey)
        }
        teardownDisplay(id: id)
        _ = createDisplay(preset: newPreset, storageKey: savedKey)
    }
    
    public func toggleHiDPI(for id: CGDirectDisplayID) {
        guard let info = activeDisplays[id] else { return }
        let current = info.preset.scaleFactor
        let next: UInt = current == 1 ? 2 : (current == 2 ? 3 : 1)
        setScale(next, for: id)
    }
    
    public func teardownDisplay(id: CGDirectDisplayID) {
        StreamWindowManager.shared.closeWindow(for: id)
        activeDisplays.removeValue(forKey: id)
        NotificationCenter.default.post(name: PresetManager.didChangeNotification, object: nil)
    }
    
    public func teardownAllDisplays() {
        StreamWindowManager.shared.closeAllWindows()
        activeDisplays.removeAll()
        NotificationCenter.default.post(name: PresetManager.didChangeNotification, object: nil)
    }
}

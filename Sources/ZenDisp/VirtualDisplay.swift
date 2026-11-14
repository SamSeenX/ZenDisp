import Cocoa
import CoreGraphics

public struct DisplayPreset {
    public let width: UInt
    public let height: UInt
    public let refreshRate: Double
    public let name: String
    
    public static let preset900p = DisplayPreset(width: 1600, height: 900, refreshRate: 60.0, name: "1600x900 (16:9)")
    public static let preset1080p = DisplayPreset(width: 1920, height: 1080, refreshRate: 60.0, name: "1920x1080 (1080p)")
    public static let preset1440p = DisplayPreset(width: 2560, height: 1440, refreshRate: 60.0, name: "2560x1440 (2K)")
}

public final class VirtualDisplayManager {
    public static let shared = VirtualDisplayManager()
    
    private var activeDisplay: AnyObject?
    public private(set) var activeDisplayID: CGDirectDisplayID?
    public private(set) var activePreset: DisplayPreset?
    private var serialCounter: UInt32 = 1000
    
    private init() {}
    
    public var isDisplayActive: Bool {
        return activeDisplay != nil && activeDisplayID != nil
    }
    
    public func createDisplay(preset: DisplayPreset) -> Bool {
        teardownDisplay()
        
        guard let descClass = NSClassFromString("CGVirtualDisplayDescriptor") as? NSObject.Type,
              let modeClass = NSClassFromString("CGVirtualDisplayMode") as? NSObject.Type,
              let settingsClass = NSClassFromString("CGVirtualDisplaySettings") as? NSObject.Type,
              let displayClass = NSClassFromString("CGVirtualDisplay") as? NSObject.Type else {
            return false
        }
        
        serialCounter += 1
        let descriptor = descClass.init()
        descriptor.setValue("ZenDisp \(preset.name)", forKey: "name")
        descriptor.setValue(UInt32(preset.width), forKey: "maxPixelsWide")
        descriptor.setValue(UInt32(preset.height), forKey: "maxPixelsHigh")
        descriptor.setValue(
            NSValue(size: NSSize(width: Double(preset.width) * 25.4 / 110.0, height: Double(preset.height) * 25.4 / 110.0)),
            forKey: "sizeInMillimeters"
        )
        descriptor.setValue(serialCounter, forKey: "serialNum")
        descriptor.setValue(UInt32(0x5a44), forKey: "productID")
        descriptor.setValue(UInt32(0x5353), forKey: "vendorID")
        descriptor.setValue(DispatchQueue.main, forKey: "queue")
        
        guard let modeAlloc = modeClass.perform(NSSelectorFromString("alloc"))?.takeUnretainedValue() as AnyObject? else {
            return false
        }
        let modeInitSel = NSSelectorFromString("initWithWidth:height:refreshRate:")
        guard let modeMethod = modeClass.instanceMethod(for: modeInitSel) else {
            return false
        }
        let modeInitFn = unsafeBitCast(
            modeMethod,
            to: (@convention(c) (AnyObject, Selector, UInt, UInt, Double) -> AnyObject).self
        )
        let mode = modeInitFn(modeAlloc, modeInitSel, preset.width, preset.height, preset.refreshRate)
        
        let settings = settingsClass.init()
        settings.setValue([mode], forKey: "modes")
        settings.setValue(UInt32(1), forKey: "hiDPI")
        
        guard let displayAlloc = displayClass.perform(NSSelectorFromString("alloc"))?.takeUnretainedValue() as AnyObject? else {
            return false
        }
        let displayInitSel = NSSelectorFromString("initWithDescriptor:")
        guard let displayMethod = displayClass.instanceMethod(for: displayInitSel) else {
            return false
        }
        let displayInitFn = unsafeBitCast(
            displayMethod,
            to: (@convention(c) (AnyObject, Selector, AnyObject) -> AnyObject).self
        )
        let displayInstance = displayInitFn(displayAlloc, displayInitSel, descriptor)
        
        let applySel = NSSelectorFromString("applySettings:")
        guard let applyMethod = displayClass.instanceMethod(for: applySel) else {
            return false
        }
        let applyFn = unsafeBitCast(
            applyMethod,
            to: (@convention(c) (AnyObject, Selector, AnyObject) -> Bool).self
        )
        let applied = applyFn(displayInstance, applySel, settings)
        guard applied else {
            return false
        }
        
        let displayIDSel = NSSelectorFromString("displayID")
        guard let displayIDMethod = displayClass.instanceMethod(for: displayIDSel) else {
            return false
        }
        let displayIDFn = unsafeBitCast(
            displayIDMethod,
            to: (@convention(c) (AnyObject, Selector) -> CGDirectDisplayID).self
        )
        let id = displayIDFn(displayInstance, displayIDSel)
        guard id != 0 else {
            teardownDisplay()
            return false
        }
        
        self.activeDisplay = displayInstance
        self.activeDisplayID = id
        self.activePreset = preset
        return true
    }
    
    public func teardownDisplay() {
        activeDisplay = nil
        activeDisplayID = nil
        activePreset = nil
    }
}

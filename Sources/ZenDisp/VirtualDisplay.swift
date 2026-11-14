import Cocoa
import CoreGraphics

@objc protocol VirtualDisplayModeProtocol: NSObjectProtocol {
    init(width: UInt, height: UInt, refreshRate: Double)
}

@objc protocol VirtualDisplaySettingsProtocol: NSObjectProtocol {
    init()
    var modes: [Any] { get set }
    var hiDPI: UInt32 { get set }
}

@objc protocol VirtualDisplayDescriptorProtocol: NSObjectProtocol {
    init()
    var name: String { get set }
    var maxPixelsWide: UInt32 { get set }
    var maxPixelsHigh: UInt32 { get set }
    var sizeInMillimeters: CGSize { get set }
    var serialNum: UInt32 { get set }
    var productID: UInt32 { get set }
    var vendorID: UInt32 { get set }
    var queue: DispatchQueue { get set }
}

@objc protocol VirtualDisplayProtocol: NSObjectProtocol {
    init(descriptor: AnyObject)
    func applySettings(_ settings: AnyObject) -> Bool
    var displayID: CGDirectDisplayID { get }
}

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
        let descriptor = (descClass.init() as AnyObject) as! VirtualDisplayDescriptorProtocol
        descriptor.name = "ZenDisp \(preset.name)"
        descriptor.maxPixelsWide = UInt32(preset.width)
        descriptor.maxPixelsHigh = UInt32(preset.height)
        descriptor.sizeInMillimeters = CGSize(
            width: Double(preset.width) * 25.4 / 110.0,
            height: Double(preset.height) * 25.4 / 110.0
        )
        descriptor.serialNum = serialCounter
        descriptor.productID = 0x5a44
        descriptor.vendorID = 0x5353
        descriptor.queue = DispatchQueue.main
        
        let modeAlloc = modeClass.perform(NSSelectorFromString("alloc"))?.takeUnretainedValue() as AnyObject
        _ = modeClass.instanceMethod(for: NSSelectorFromString("initWithWidth:height:refreshRate:"))
        
        let invocation = unsafeBitCast(
            modeClass.instanceMethod(for: NSSelectorFromString("initWithWidth:height:refreshRate:")),
            to: (@convention(c) (AnyObject, Selector, UInt, UInt, Double) -> AnyObject).self
        )
        let initializedMode = invocation(modeAlloc, NSSelectorFromString("initWithWidth:height:refreshRate:"), preset.width, preset.height, preset.refreshRate)
        
        let settings = (settingsClass.init() as AnyObject) as! VirtualDisplaySettingsProtocol
        settings.modes = [initializedMode]
        settings.hiDPI = 1
        
        let displayAlloc = displayClass.perform(NSSelectorFromString("alloc"))?.takeUnretainedValue() as AnyObject
        let displayInit = unsafeBitCast(
            displayClass.instanceMethod(for: NSSelectorFromString("initWithDescriptor:")),
            to: (@convention(c) (AnyObject, Selector, AnyObject) -> AnyObject).self
        )
        let displayInstance = displayInit(displayAlloc, NSSelectorFromString("initWithDescriptor:"), descriptor as AnyObject)
        
        let displayObj = displayInstance as! VirtualDisplayProtocol
        _ = displayObj.applySettings(settings as AnyObject)
        
        let id = displayObj.displayID
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

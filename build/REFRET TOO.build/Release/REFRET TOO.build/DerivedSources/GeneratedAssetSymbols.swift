import Foundation
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ColorResource {

}

// MARK: - Image Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ImageResource {

    /// The "ChromeSet" asset catalog image resource.
    static let chromeSet = DeveloperToolsSupport.ImageResource(name: "ChromeSet", bundle: resourceBundle)

    /// The "ControlPanelSET" asset catalog image resource.
    static let controlPanelSET = DeveloperToolsSupport.ImageResource(name: "ControlPanelSET", bundle: resourceBundle)

    /// The "DisplayExamplesTwoA" asset catalog image resource.
    static let displayExamplesTwoA = DeveloperToolsSupport.ImageResource(name: "DisplayExamplesTwoA", bundle: resourceBundle)

    /// The "DisplayExamplesTwoB" asset catalog image resource.
    static let displayExamplesTwoB = DeveloperToolsSupport.ImageResource(name: "DisplayExamplesTwoB", bundle: resourceBundle)

    /// The "DisplayExamplesTwoC" asset catalog image resource.
    static let displayExamplesTwoC = DeveloperToolsSupport.ImageResource(name: "DisplayExamplesTwoC", bundle: resourceBundle)

    /// The "FRETBOARDSSET" asset catalog image resource.
    static let FRETBOARDSSET = DeveloperToolsSupport.ImageResource(name: "FRETBOARDSSET", bundle: resourceBundle)

    /// The "FretWOODSET !" asset catalog image resource.
    static let fretWOODSET = DeveloperToolsSupport.ImageResource(name: "FretWOODSET !", bundle: resourceBundle)

    /// The "FretWoodSET 2" asset catalog image resource.
    static let fretWoodSET2 = DeveloperToolsSupport.ImageResource(name: "FretWoodSET 2", bundle: resourceBundle)

    /// The "KNOBSET !" asset catalog image resource.
    static let KNOBSET = DeveloperToolsSupport.ImageResource(name: "KNOBSET !", bundle: resourceBundle)

    /// The "PointyKnob" asset catalog image resource.
    static let pointyKnob = DeveloperToolsSupport.ImageResource(name: "PointyKnob", bundle: resourceBundle)

    /// The "RosewoodOne" asset catalog image resource.
    static let rosewoodOne = DeveloperToolsSupport.ImageResource(name: "RosewoodOne", bundle: resourceBundle)

    /// The "TESTPATTERN SET" asset catalog image resource.
    static let TESTPATTERN_SET = DeveloperToolsSupport.ImageResource(name: "TESTPATTERN SET", bundle: resourceBundle)

    /// The "TUBE SET 3" asset catalog image resource.
    static let TUBE_SET_3 = DeveloperToolsSupport.ImageResource(name: "TUBE SET 3", bundle: resourceBundle)

    /// The "TVSET" asset catalog image resource.
    static let TVSET = DeveloperToolsSupport.ImageResource(name: "TVSET", bundle: resourceBundle)

    /// The "TubeSET 4" asset catalog image resource.
    static let tubeSET4 = DeveloperToolsSupport.ImageResource(name: "TubeSET 4", bundle: resourceBundle)

    /// The "TubeSet !" asset catalog image resource.
    static let tubeSet = DeveloperToolsSupport.ImageResource(name: "TubeSet !", bundle: resourceBundle)

    /// The "TubeSet 2" asset catalog image resource.
    static let tubeSet2 = DeveloperToolsSupport.ImageResource(name: "TubeSet 2", bundle: resourceBundle)

    /// The "TweedSample" asset catalog image resource.
    static let tweedSample = DeveloperToolsSupport.ImageResource(name: "TweedSample", bundle: resourceBundle)

    /// The "TweedSampleTwo" asset catalog image resource.
    static let tweedSampleTwo = DeveloperToolsSupport.ImageResource(name: "TweedSampleTwo", bundle: resourceBundle)

    /// The "TweedSampleTwo 1" asset catalog image resource.
    static let tweedSampleTwo1 = DeveloperToolsSupport.ImageResource(name: "TweedSampleTwo 1", bundle: resourceBundle)

    /// The "VU METERSET !" asset catalog image resource.
    static let VU_METERSET = DeveloperToolsSupport.ImageResource(name: "VU METERSET !", bundle: resourceBundle)

    /// The "chicken" asset catalog image resource.
    static let chicken = DeveloperToolsSupport.ImageResource(name: "chicken", bundle: resourceBundle)

    /// The "knob Reference" asset catalog image resource.
    static let knobReference = DeveloperToolsSupport.ImageResource(name: "knob Reference", bundle: resourceBundle)

}

// MARK: - Color Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

}
#endif

// MARK: - Image Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    /// The "ChromeSet" asset catalog image.
    static var chromeSet: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .chromeSet)
#else
        .init()
#endif
    }

    /// The "ControlPanelSET" asset catalog image.
    static var controlPanelSET: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .controlPanelSET)
#else
        .init()
#endif
    }

    /// The "DisplayExamplesTwoA" asset catalog image.
    static var displayExamplesTwoA: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .displayExamplesTwoA)
#else
        .init()
#endif
    }

    /// The "DisplayExamplesTwoB" asset catalog image.
    static var displayExamplesTwoB: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .displayExamplesTwoB)
#else
        .init()
#endif
    }

    /// The "DisplayExamplesTwoC" asset catalog image.
    static var displayExamplesTwoC: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .displayExamplesTwoC)
#else
        .init()
#endif
    }

    /// The "FRETBOARDSSET" asset catalog image.
    static var FRETBOARDSSET: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .FRETBOARDSSET)
#else
        .init()
#endif
    }

    /// The "FretWOODSET !" asset catalog image.
    static var fretWOODSET: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .fretWOODSET)
#else
        .init()
#endif
    }

    /// The "FretWoodSET 2" asset catalog image.
    static var fretWoodSET2: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .fretWoodSET2)
#else
        .init()
#endif
    }

    /// The "KNOBSET !" asset catalog image.
    static var KNOBSET: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .KNOBSET)
#else
        .init()
#endif
    }

    /// The "PointyKnob" asset catalog image.
    static var pointyKnob: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .pointyKnob)
#else
        .init()
#endif
    }

    /// The "RosewoodOne" asset catalog image.
    static var rosewoodOne: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .rosewoodOne)
#else
        .init()
#endif
    }

    /// The "TESTPATTERN SET" asset catalog image.
    static var TESTPATTERN_SET: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .TESTPATTERN_SET)
#else
        .init()
#endif
    }

    /// The "TUBE SET 3" asset catalog image.
    static var TUBE_SET_3: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .TUBE_SET_3)
#else
        .init()
#endif
    }

    /// The "TVSET" asset catalog image.
    static var TVSET: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .TVSET)
#else
        .init()
#endif
    }

    /// The "TubeSET 4" asset catalog image.
    static var tubeSET4: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tubeSET4)
#else
        .init()
#endif
    }

    /// The "TubeSet !" asset catalog image.
    static var tubeSet: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tubeSet)
#else
        .init()
#endif
    }

    /// The "TubeSet 2" asset catalog image.
    static var tubeSet2: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tubeSet2)
#else
        .init()
#endif
    }

    /// The "TweedSample" asset catalog image.
    static var tweedSample: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tweedSample)
#else
        .init()
#endif
    }

    /// The "TweedSampleTwo" asset catalog image.
    static var tweedSampleTwo: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tweedSampleTwo)
#else
        .init()
#endif
    }

    /// The "TweedSampleTwo 1" asset catalog image.
    static var tweedSampleTwo1: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tweedSampleTwo1)
#else
        .init()
#endif
    }

    /// The "VU METERSET !" asset catalog image.
    static var VU_METERSET: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .VU_METERSET)
#else
        .init()
#endif
    }

    /// The "chicken" asset catalog image.
    static var chicken: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .chicken)
#else
        .init()
#endif
    }

    /// The "knob Reference" asset catalog image.
    static var knobReference: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .knobReference)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    /// The "ChromeSet" asset catalog image.
    static var chromeSet: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .chromeSet)
#else
        .init()
#endif
    }

    /// The "ControlPanelSET" asset catalog image.
    static var controlPanelSET: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .controlPanelSET)
#else
        .init()
#endif
    }

    /// The "DisplayExamplesTwoA" asset catalog image.
    static var displayExamplesTwoA: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .displayExamplesTwoA)
#else
        .init()
#endif
    }

    /// The "DisplayExamplesTwoB" asset catalog image.
    static var displayExamplesTwoB: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .displayExamplesTwoB)
#else
        .init()
#endif
    }

    /// The "DisplayExamplesTwoC" asset catalog image.
    static var displayExamplesTwoC: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .displayExamplesTwoC)
#else
        .init()
#endif
    }

    /// The "FRETBOARDSSET" asset catalog image.
    static var FRETBOARDSSET: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .FRETBOARDSSET)
#else
        .init()
#endif
    }

    /// The "FretWOODSET !" asset catalog image.
    static var fretWOODSET: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .fretWOODSET)
#else
        .init()
#endif
    }

    /// The "FretWoodSET 2" asset catalog image.
    static var fretWoodSET2: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .fretWoodSET2)
#else
        .init()
#endif
    }

    /// The "KNOBSET !" asset catalog image.
    static var KNOBSET: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .KNOBSET)
#else
        .init()
#endif
    }

    /// The "PointyKnob" asset catalog image.
    static var pointyKnob: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .pointyKnob)
#else
        .init()
#endif
    }

    /// The "RosewoodOne" asset catalog image.
    static var rosewoodOne: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .rosewoodOne)
#else
        .init()
#endif
    }

    /// The "TESTPATTERN SET" asset catalog image.
    static var TESTPATTERN_SET: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .TESTPATTERN_SET)
#else
        .init()
#endif
    }

    /// The "TUBE SET 3" asset catalog image.
    static var TUBE_SET_3: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .TUBE_SET_3)
#else
        .init()
#endif
    }

    /// The "TVSET" asset catalog image.
    static var TVSET: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .TVSET)
#else
        .init()
#endif
    }

    /// The "TubeSET 4" asset catalog image.
    static var tubeSET4: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tubeSET4)
#else
        .init()
#endif
    }

    /// The "TubeSet !" asset catalog image.
    static var tubeSet: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tubeSet)
#else
        .init()
#endif
    }

    /// The "TubeSet 2" asset catalog image.
    static var tubeSet2: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tubeSet2)
#else
        .init()
#endif
    }

    /// The "TweedSample" asset catalog image.
    static var tweedSample: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tweedSample)
#else
        .init()
#endif
    }

    /// The "TweedSampleTwo" asset catalog image.
    static var tweedSampleTwo: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tweedSampleTwo)
#else
        .init()
#endif
    }

    /// The "TweedSampleTwo 1" asset catalog image.
    static var tweedSampleTwo1: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tweedSampleTwo1)
#else
        .init()
#endif
    }

    /// The "VU METERSET !" asset catalog image.
    static var VU_METERSET: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .VU_METERSET)
#else
        .init()
#endif
    }

    /// The "chicken" asset catalog image.
    static var chicken: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .chicken)
#else
        .init()
#endif
    }

    /// The "knob Reference" asset catalog image.
    static var knobReference: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .knobReference)
#else
        .init()
#endif
    }

}
#endif

// MARK: - Thinnable Asset Support -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ColorResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if AppKit.NSColor(named: NSColor.Name(thinnableName), bundle: bundle) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIColor(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}
#endif

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ImageResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if bundle.image(forResource: NSImage.Name(thinnableName)) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIImage(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif


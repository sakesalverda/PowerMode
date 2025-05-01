//
//  Preferences.swift
//  PowerMode
//
//  Created by Sake Salverda on 27/11/2023.
//

import Foundation
import Combine
import SwiftUI
//import ObservableUserDefault

// Contents mainly inspired by: https://fatbobman.medium.com/mastering-appstorage-in-swiftui-682be3258cf2
// @todo > above article mentions that any change cannot be identified to a specific property and hence results in all properties firing an "update"
// and slightly adjusted following https://www.avanderlee.com/swift/appstorage-explained/

extension Preferences {
    public static let instance = Preferences()
}

enum MenuBarIconVariant: Int {
    case `default`
    case percentage
    case status
}

enum MenuBarEnergyModeIndicatorVariant: Int {
    case none
    case icon
    case bar
    case color
}

enum MenuBarBatteryRemainingDisplayOptions: Int {
    case never
    case low
    case always
}

@Observable
public final class Preferences: Sendable {
    init() {}
    // MARK: Visual/UI preferences
    
    /// Preference to hide the high power mode on battery
//    @ObservableUserDefault(.init(key: Defaults.hideHighPowerModeOnBattery.key, defaultValue: Defaults.hideHighPowerModeOnBattery.defaultValue, store: .group))
//    @ObservationIgnored
//    public var hideHighPowerModeOnBattery: Bool
    @ObservationIgnored
    @MainActor public var hideHighPowerModeOnBattery: Bool {
        get {
            access(keyPath: \.hideHighPowerModeOnBattery)
            return Defaults.hideHighPowerModeOnBattery.wrappedValue
        }
        
        set {
            withMutation(keyPath: \.hideHighPowerModeOnBattery) {
                Defaults.hideHighPowerModeOnBattery.wrappedValue = newValue
            }
        }
    }
    
    @ObservationIgnored
    @MainActor var isAppleBatteryReplacement: Bool {
        get {
            access(keyPath: \.isAppleBatteryReplacement)
            
            return Defaults.isBatteryReplacement.wrappedValue
        }
        
        set {
            withMutation(keyPath: \.isAppleBatteryReplacement) {
                Defaults.isBatteryReplacement.wrappedValue = newValue
            }
        }
//        menuIconVariant != .default || displayBatteryPercentageInMenu
    }
    
    @ObservationIgnored
    @MainActor var displayBatteryRemainingInMenu: MenuBarBatteryRemainingDisplayOptions {
        get {
            access(keyPath: \.displayBatteryRemainingInMenu)
            
            return Defaults.menuBarDisplayBatteryRemaining.wrappedValue
        }
        
        set {
            withMutation(keyPath: \.displayBatteryPercentageInMenu) {
                Defaults.menuBarDisplayBatteryRemaining.wrappedValue = newValue
            }
        }
    }
    
    @ObservationIgnored
    @MainActor var enableSettingChargeLimit: Bool {
        get {
            access(keyPath: \.enableSettingChargeLimit)
            
            return Defaults.enableSettingChargeLimit.wrappedValue
        }
        
        set {
            withMutation(keyPath: \.enableSettingChargeLimit) {
                Defaults.enableSettingChargeLimit.wrappedValue = newValue
            }
        }
    }
    
    
    @ObservationIgnored
    @MainActor var menuIconVariant: MenuBarIconVariant {
        get {
            access(keyPath: \.menuIconVariant)
            
            return Defaults.menuBarMainIconVariant.wrappedValue
        }
        
        set {
            withMutation(keyPath: \.menuIconVariant) {
                Defaults.menuBarMainIconVariant.wrappedValue = newValue
            }
        }
    }
    
    @MainActor public var displayBatteryPercentageCompact: Bool = false
    
    @ObservationIgnored
    @MainActor public var displayBatteryPercentageInMenu: Bool {
        get {
            access(keyPath: \.displayBatteryPercentageInMenu)
            
            return Defaults.menuBarDisplayPercentage.wrappedValue
        }
        
        set {
            withMutation(keyPath: \.displayBatteryPercentageInMenu) {
                Defaults.menuBarDisplayPercentage.wrappedValue = newValue
            }
        }
    }
    
    @ObservationIgnored
    @MainActor public var useActivePowerSourceOnlyInMenu: Bool {
        get {
            access(keyPath: \.useActivePowerSourceOnlyInMenu)
            return Defaults.useActivePowerSourceOnlyInMenu.wrappedValue
        }
        
        set {
            withMutation(keyPath: \.useActivePowerSourceOnlyInMenu) {
                Defaults.useActivePowerSourceOnlyInMenu.wrappedValue = newValue
            }
        }
    }
    
    @ObservationIgnored
    @MainActor public var useCollapsablePowerSourcesInMenu: Bool {
        get {
            access(keyPath: \.useCollapsablePowerSourcesInMenu)
            return Defaults.useCollapsablePowerSourcesInMenu.wrappedValue
        }
        
        set {
            withMutation(keyPath: \.useCollapsablePowerSourcesInMenu) {
                Defaults.useCollapsablePowerSourcesInMenu.wrappedValue = newValue
            }
        }
    }
    
    /// Preference to show the current power source indicator
//    @ObservableUserDefault(.init(key: Defaults.usePowerSourceIndicatorInMenu.key, defaultValue: Defaults.usePowerSourceIndicatorInMenu.defaultValue, store: .group))
    @ObservationIgnored
    @MainActor public var usePowerSourceIndicator: Bool {
        get {
            access(keyPath: \.usePowerSourceIndicator)
            return Defaults.usePowerSourceIndicatorInMenu.wrappedValue
        }
        
        set {
            withMutation(keyPath: \.usePowerSourceIndicator) {
                Defaults.usePowerSourceIndicatorInMenu.wrappedValue = newValue
            }
        }
    }
    
    @ObservationIgnored
    @MainActor var currentEnergyModeStatusIcon: MenuBarEnergyModeIndicatorVariant {
        get {
            access(keyPath: \.currentEnergyModeStatusIcon)
            
            let preferredVariant = Defaults.menuBarIconEnergyModeVariant.wrappedValue
            if preferredVariant == .color && menuIconVariant != .status {
                self.currentEnergyModeStatusIcon = Defaults.menuBarIconEnergyModeVariant.defaultValue
            }
            
            return preferredVariant
        }
        
        set {
            withMutation(keyPath: \.currentEnergyModeStatusIcon) {
                Defaults.menuBarIconEnergyModeVariant.wrappedValue = newValue
            }
        }
    }
    
    
//    @ObservableUserDefault(.init(key: Defaults.useExpirementalFeed.key, store: .standard))
    @ObservationIgnored
    @MainActor public var updateFeedString: Bool? {
        get {
            access(keyPath: \.updateFeedString)
            return Defaults.useExpirementalFeed.wrappedValue
        }
        
        set {
            withMutation(keyPath: \.updateFeedString) {
                Defaults.useExpirementalFeed.wrappedValue = newValue
            }
        }
    }
    
    
//    static let useStaticHighlightColor: Bool = true
    /// Preference to use a singular color for highlighting the selected energy mode
    // @todo, do we want this in the widgets as well?
//    @ObservableUserDefault(.init(key: DefaultsName.conf.menu.useSystemHighlightColor", defaultValue: Self.useStaticHighlightColor, store: .group))
//    @ObservationIgnored
    @MainActor public var useStaticHighlightColor: Bool = true
    
//    static let widgetUseStaticHighlightColor: Bool = false
    /// Not yet active
//    @ObservableUserDefault(.init(key: DEfaultsName.conf.widget.useSystemHighlightColor", defaultValue: Self.widgetUseStaticHighlightColor, store: .group))
//    @ObservationIgnored
    @MainActor public var widgetUseStaticHighlightColor: Bool = false

    
    /// Preference to alternate between displaying "Low Power Mode" and "Low Power"
//    @ObservableUserDefault(.init(key: DefaultsName.useModeInMenuLabels, defaultValue: Defaults.useModeInMenuLabels.defaultValue, store: .standard))
    @ObservationIgnored
    @MainActor public var useModeInLabel: Bool {
        get {
            access(keyPath: \.useModeInLabel)
            return Defaults.useModeInMenuLabels.wrappedValue
        }
        
        set {
            withMutation(keyPath: \.useModeInLabel) {
                Defaults.useModeInMenuLabels.wrappedValue = newValue
            }
        }
    }
    
    // @note it was decided to NOT bridge the useModeInLabel setting to the widgets
    // it could be confusing for users to see "Battery" and then "Low Power" instead of "Low Power Mode" in the widgets,
    // it looks, in combination with the icon, as if the battery is low instead of a setting in energy mode
    @MainActor public var widgetUseModeInLabel: Bool = true
    
    
    @MainActor public var usePowerInAutomaticLabel: Bool = false
    @MainActor public var widgetUsePowerInAutomaticLabel: Bool = false
    
    // MARK: Functional preferences
    
//    @ObservableUserDefault(.init(key: DefaultsName.lowBatteryDischargeThreshold, defaultValue: Defaults.lowBatteryDischargeThreshold.defaultValue, store: .standard))
    @ObservationIgnored
    public var autoLowPowerModeDischargeThreshold: Int {
        get {
            access(keyPath: \.autoLowPowerModeDischargeThreshold)
            return Defaults.lowBatteryDischargeThreshold.wrappedValue
        }
        
        set {
            withMutation(keyPath: \.autoLowPowerModeDischargeThreshold) {
                Defaults.lowBatteryDischargeThreshold.wrappedValue = newValue
            }
        }
    }
    
//    static let enableLowPowerModeOnLowBattery: Bool = false
//    @ObservableUserDefault(.init(key: DefaultsName.enableLowPowerOnLowBattery, defaultValue: Defaults.enableLowPowerOnLowBattery.defaultValue, store: .standard))
    @ObservationIgnored
    public var enableLowPowerModeOnLowBattery: Bool {
        get {
            access(keyPath: \.enableLowPowerModeOnLowBattery)
            return Defaults.enableLowPowerOnLowBattery.wrappedValue
        }
        
        set {
            withMutation(keyPath: \.enableLowPowerModeOnLowBattery) {
                Defaults.enableLowPowerOnLowBattery.wrappedValue = newValue
            }
        }
    }
}

@propertyWrapper
public struct Preference<T>: DynamicProperty {
    private let defaults: Preferences
    
    private let keyPath: ReferenceWritableKeyPath<Preferences, T>
    
    public init(_ keyPath: ReferenceWritableKeyPath<Preferences, T>, defaults: Preferences = .instance) {
        self.keyPath = keyPath
        self.defaults = defaults
    }

    public var wrappedValue: T {
        get { defaults[keyPath: keyPath] }
        nonmutating set { defaults[keyPath: keyPath] = newValue }
    }

    public var projectedValue: Binding<T> {
        Binding(
            get: { defaults[keyPath: keyPath] }, // defaults[keyPath: keyPath]
            set: { defaults[keyPath: keyPath] = $0} // newValue in defaults[keyPath: keyPath] = newValue
        )
    }
}

@propertyWrapper
public struct ReadPreference<T>: DynamicProperty {
    private let defaults: Preferences
    
    private let keyPath: KeyPath<Preferences, T>
    
    public init(_ keyPath: KeyPath<Preferences, T>, defaults: Preferences = .instance) {
        self.keyPath = keyPath
        self.defaults = defaults
    }

    public var wrappedValue: T {
        get { defaults[keyPath: keyPath] }
    }
}

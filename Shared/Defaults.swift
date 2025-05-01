//
//  Defaults.swift
//  PowerMode
//
//  Created by Sake Salverda on 16/03/2024.
//

import SwiftUI
import Walberg

public enum Defaults {
    // MARK: Updates
    @MainActor static let updateAvailable = D(DefaultsKey.updateAvailable, value: false)
    @MainActor static let updateAvailableNotification = D(DefaultsKey.updateAvailableNotification, value: false)
    
    @MainActor static let chargeLimitEnabled = D(DefaultsKey.chargeLimitEnabled, value: false)
    
//    @MainActor static let useBatteryIcon = D(DefaultsKey.useBatteryIcon, value: false)
//    @MainActor static let batteryPercentageInIcon = D(DefaultsKey.batteryPercentageInIcon, value: false)
//
//    @MainActor static let hideMainIcon = D(DefaultsKey.hideMainIcon, value: false)
    
    typealias D = TypedUserDefaults
    
    // MARK: Auto Low Battery
    // - caches
    @MainActor static let lowBatteryPreviousEnergyMode = D<EnergyMode?>(DefaultsKey.lowBatteryPreviousEnergyMode)
    @MainActor static let didCancelAutoLowPowerMode = D(DefaultsKey.didCancelAutoLowPowerMode, value: false)
    @MainActor static let didTriggerAutoLowPowerMode = D(DefaultsKey.didTriggerAutoLowPowerMode, value: false)
    // - preferences
    @MainActor static let lowBatteryDischargeThreshold = D(DefaultsKey.lowBatteryDischargeThreshold, value: Int(20))
    @MainActor static let enableLowPowerOnLowBattery = D(DefaultsKey.enableLowPowerOnLowBattery, value: false)
    
    // MARK: Donations
    @MainActor static let dismissConsideringSupporting = D(DefaultsKey.dismissConsideringSupporting, value: false)
    @MainActor static let didSupport = D(DefaultsKey.didSupport, value: false)
    
    // MARK: Functional Preferences
    @MainActor static let hideHighPowerModeOnBattery = D(DefaultsKey.hideHighPowerModeOnBattery, value: false, store: .group)
    
    @MainActor static let useActivePowerSourceOnlyInMenu = D(DefaultsKey.useActivePowerSourceOnlyInMenu, value: false)
    @MainActor static let usePowerSourceIndicatorInMenu = D(DefaultsKey.usePowerSourceIndicatorInMenu, value: true, store: .group)
    @MainActor static let useCollapsablePowerSourcesInMenu = D(DefaultsKey.allowCollapsingPowerSourceInMenu, value: false)
    
    
    @MainActor static let isBatteryReplacement = D(DefaultsKey.isBatteryReplacement, value: false)
    
    @MainActor static let menuBarMainIconVariant = D(DefaultsKey.menuBarMainIconVariant, value: MenuBarIconVariant.default)
    @MainActor static let menuBarIconEnergyModeVariant = D(DefaultsKey.menuBarIconEnergyModeVariant, value: MenuBarEnergyModeIndicatorVariant.icon)
    @MainActor static let menuBarDisplayPercentage = D(DefaultsKey.menuBarDisplayPercentage, value: false)
    @MainActor static let menuBarDisplayBatteryRemaining = D(DefaultsKey.menuBarDisplayBatteryRemaining, value: MenuBarBatteryRemainingDisplayOptions.low)
    
    @MainActor static let useModeInMenuLabels = D(DefaultsKey.useModeInMenuLabels, value: false)
    
    @MainActor static let enableSettingChargeLimit = D(DefaultsKey.enableSettingChargeLimit, value: false)
    
    // MARK: Miscellaneous
    @MainActor static let useExpirementalFeed = D<Bool?>(DefaultsKey.useExpirementalFeed)
}

public enum DefaultsKey: CaseIterable {
    static let updateAvailable = "cache_updateAvailable"
    static let updateAvailableNotification = "cache_updateNotificationAvailable"
    
    static let chargeLimitEnabled = "pref_chargeLimitEnabled"
    
    static let isBatteryReplacement = "pref_replacedBatteryItem"
    
//    static let hideMainIcon = "pref_menu_hideMainIcon"
//
//    static let useBatteryIcon = "pref_menu_useBatteryIcon"
    
    static let lowBatteryPreviousEnergyMode = "cache_lowBatteryPreviousEnergyMode"
    static let didCancelAutoLowPowerMode = "cache_didCancelAutoLowPowerMode"
    static let didTriggerAutoLowPowerMode = "cache_didTriggerAutoLowPowerMode"
    static let lowBatteryDischargeThreshold = "pref_lowPowerModeDischargeThreshold"
    static let enableLowPowerOnLowBattery = "pref_enableLowPowerModeOnLowBattery"
    
    static let dismissConsideringSupporting = "cache_dismissedConsiderSupporting"
    static let didSupport = "cache_didSupport"
    
    /// **GROUP**
    static let hideHighPowerModeOnBattery = "pref_hidePowerModeOnBattery"
    /// **GROUP**
    static let usePowerSourceIndicatorInMenu = "pref_menu_showPowerSourceIndicator"
    
    static let useActivePowerSourceOnlyInMenu = "pref_menu_showActivePowerSourceOnly"
    static let allowCollapsingPowerSourceInMenu = "pref_menu_allowCollapsingPowerSource"
    
    static let menuBarIconEnergyModeVariant = "pref_menu_iconVariant"
    static let menuBarMainIconVariant = "pref_menu_mainIconVariant"
    static let menuBarDisplayPercentage = "pref_menu_displayPercentage"
    static let menuBarDisplayBatteryRemaining = "pref_menu_displayBatteryRemainingToEmpty"
    
    static let useModeInMenuLabels = "pref_menu_showModeInLabel"
    
    static let enableSettingChargeLimit = "pref_menu_allowSettingChargeLimit"
    
    static let useExpirementalFeed = "pref_experimentalFeedString"
}

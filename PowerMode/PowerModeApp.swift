//
//  ControlCenterApp.swift
//  PowerMode
//
//  Created by Sake Salverda on 16/01/2024.
//

import SwiftUI
import Sparkle

import ControlCenterExtra
import Walberg

extension Notification.Name {
    static let openInstallUpdate = Notification.Name("openUpdateInstallInterface")
    
    static let updateStatusImage = Notification.Name("updateStatusImage")
}

fileprivate protocol T {
    associatedtype Value
    
    func restore(_: Any?) -> Void
}

extension TypedUserDefaults: T {}

@MainActor
func ManageDefaults() -> Void {
    if UserDefaults.standard.object(forKey: "conf.menu.currentEnergyModeIndicator") != nil {
        if UserDefaults.standard.bool(forKey: "conf.menu.currentEnergyModeIndicator") {
            if(UserDefaults.standard.bool(forKey: "conf.menu.currentEnergyModeStatusIndicatorLine")) {
                Defaults.menuBarIconEnergyModeVariant.wrappedValue = MenuBarEnergyModeIndicatorVariant.bar
            } else {
                Defaults.menuBarIconEnergyModeVariant.wrappedValue = MenuBarEnergyModeIndicatorVariant.icon
            }
        }
        
        UserDefaults.standard.removeObject(forKey: "conf.menu.currentEnergyModeIndicator")
        UserDefaults.standard.removeObject(forKey: "conf.menu.currentEnergyModeIndicatorHighlight")
        UserDefaults.standard.removeObject(forKey: "conf.menu.currentEnergyModeStatusIndicatorLine")
    }
    
    if UserDefaults.group.object(forKey: "conf.menu.useSystemHighlightColor") != nil {
        UserDefaults.group.removeObject(forKey: "conf.menu.useSystemHighlightColor")
    }
    
    if UserDefaults.group.bool(forKey: "conf.menu.showModeInLabel") {
        UserDefaults.group.removeObject(forKey: "conf.menu.showModeInLabel")
        Defaults.useModeInMenuLabels.wrappedValue = true
    }
    
    if UserDefaults.standard.object(forKey: "conf.widget.useSystemHighlightColor") != nil {
        UserDefaults.standard.removeObject(forKey: "conf.widget.useSystemHighlightColor")
    }
    
    let replacementKeys: [(String, any T)] = [
        ("cache.updateAvailable", Defaults.updateAvailable),
        ("cache.updateNotificationAvailable", Defaults.updateAvailableNotification),
        ("cache.lowBatteryPreviousEnergyMode", Defaults.lowBatteryPreviousEnergyMode),
        ("cache.didCancelAutoLowPowerMode", Defaults.didCancelAutoLowPowerMode),
        ("cache.didPerformAutoLowPowerMode", Defaults.didTriggerAutoLowPowerMode),
        ("pref.lowPowerModeDischargeThreshold", Defaults.lowBatteryDischargeThreshold),
        ("pref.enableLowPowerModeOnLowBattery", Defaults.enableLowPowerOnLowBattery),
        ("cache.dismissedConsiderSupporting", Defaults.dismissConsideringSupporting),
        ("cache.didSupport", Defaults.didSupport),
        ("conf.menu.iconVariant", Defaults.menuBarIconEnergyModeVariant),
        ("conf.menu.showModeInLabel", Defaults.useModeInMenuLabels),
        ("conf.experimentalFeedString", Defaults.useExpirementalFeed)
    ]
    
    let replacementKeysGroup: [(String, any T)] = [
        ("pref.hidePowerModeOnBattery", Defaults.hideHighPowerModeOnBattery),
        ("conf.menu.showPowerSourceIndicator", Defaults.usePowerSourceIndicatorInMenu)
    ]
    
    for item in replacementKeys {
        let oldkey = item.0
        let defaults = item.1
        
        let oldObj = UserDefaults.standard.object(forKey: oldkey)
        guard oldObj != nil else {
            continue;
        }
        
        defaults.restore(oldObj)
        UserDefaults.standard.removeObject(forKey: oldkey)
    }
    
    for item in replacementKeysGroup {
        let oldkey = item.0
        let defaults = item.1
        
        let oldObj = UserDefaults.group.object(forKey: oldkey)
        guard oldObj != nil else {
            continue;
        }
        
        defaults.restore(oldObj)
        UserDefaults.group.removeObject(forKey: oldkey)
    }
    
    UserDefaults.standard.synchronize()
}

@main
@MainActor
struct PowerModeApp: App {
    var restore: Void = ManageDefaults()
    
    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    private var updaterController: SPUStandardUpdaterController? = nil
    
    init() {
        self.updaterController = .init(startingUpdater: true, updaterDelegate: appDelegate, userDriverDelegate: appDelegate)
        
        NotificationCenter.default.addObserver(forName: .openInstallUpdate, object: nil, queue: .main) { [self] notification in
//            updaterController?.updater.checkForUpdatesInBackground()
            Task { @MainActor in
                updaterController?.updater.checkForUpdates()
            }
        }
    }
    
    var body: some Scene {
        ControlCenterExtraWrapper(isInserted: .constant(true)) {
            ContentView()
                .environment(appDelegate.appState)
        } label: {
//            HStack(spacing: 3) {
//                BatteryIcon()
                
                MenuBarImage()
                    .environment(appDelegate.appState)
//            }
        }
        
        Settings {
            SettingsView(updater: updaterController?.updater)
                .environment(appDelegate.appState)
        }
//        .onChange(of: scenePhase) {
//            switch scenePhase {
//            case .active:
//                print("ACTIVE")
//            case .inactive:
//                print("INACTIVE")
//            case .background:
//                print("BACKGROUND")
//            @unknown default:
//                print("ohoh")
//            }
//        }
    }
}

//
//  ContentView.swift
//  PowerMode
//
//  Created by Sake Salverda on 20/01/2024.
//

import SwiftUI
import ControlCenterExtra
import OSLog

struct HeaderSmallButtonStyle: ButtonStyle {
//    @State private var isHovering: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .multilineTextAlignment(.center)
            .padding(.vertical, 3)
            .padding(.horizontal, 7)
            .background {
                Capsule()
                    .foregroundStyle(.quaternary)
            }
            .opacity(configuration.isPressed ? 0.75 : 1)
//            .onReliableHover { isHovering in
//                self.isHovering = isHovering
//            }
    }
}

extension Int {
    var timeRemaining: String {
        var out = ""
        
        let hours = self / 60
        let minutes = self % 60
        
        if hours > 0 {
            out += "\(hours)h "
        }
        
        out += "\(minutes)m"
        
        return out
    }
}

struct ContentView: View {
    @Environment(AppState.self) private var appState
    
    @Environment(\.isAltKeyPressed) private var isAltKeyPressed
    
    // Visual Settings
    @Preference(\.hideHighPowerModeOnBattery) private var hidePowerModeOnBattery
    
    @ReadPreference(\.isAppleBatteryReplacement) private var isAppleBatteryReplacement
    
    @Preference(\.displayBatteryPercentageInMenu) private var displayBatteryPercentage
    
    @Preference(\.displayBatteryRemainingInMenu) private var displayBatteryRemainingInMenu
    
    @Preference(\.enableSettingChargeLimit) private var settingChargeLimitEnabled
    
    @Preference(\.useActivePowerSourceOnlyInMenu) private var useActivePowerSourceOnlyInMenu
    @Preference(\.useCollapsablePowerSourcesInMenu) private var useCollapsablePowerSourcesInMenu
    
    @MainActor private var currentBatteryEnergyMode: EnergyMode? {
        if appState._didSetAutoLowEnergyMode {
            // @todo, why check the alt key here? With the visual indicator that is implemented now, is this still nessecary?
            if isAltKeyPressed {
                appState._lowBatteryPreviousEnergyMode
            } else {
                // this should be .low
                appState.batteryEnergyMode
            }
        } else {
            appState.batteryEnergyMode
        }
    }
    
    var helperInstalled: Bool {
        appState.helper.isRunningWithHelper
    }
    
//    enum DisclosableSections {
//        case battery
//        case adapter
//    }
//
//    @State private var expanded: Set<DisclosableSections> = [.battery, .adapter]
    @State private var expandedBattery: Bool = true
    @State private var expandedAdapter: Bool = true
    
    var menuTitle: String {
        isAppleBatteryReplacement ? "Battery" : "Energy Mode"
    }
    
//    init() {
//        let plistPath = "/Library/Preferences/nl.sakesalverda.PowerMode.shared.plist"
//
//        let initialDefaults: [String: Any] = [:]
//
//        if let data = try? PropertyListSerialization.data(fromPropertyList: initialDefaults, format: .xml, options: 0) {
//            print("DATA. HAS DATA")
//            do {
//                try data.write(to: URL(fileURLWithPath: plistPath))
//                print("UserDefaults saved successfully.")
//            } catch {
//                print("Error writing UserDefaults to plist: \(error)")
//            }
//        } else {
//            print("DATA. NO DATA")
//        }
//    }
    
    // for debugging only
    @State var batteryChargeThreshold: Double = 80
    
    func timeRemaining(_ timeString: Int) -> String {
        var out = ""
        
        let hours = timeString / 60
        let minutes = timeString % 60
        
        if hours > 0 {
            out += "\(hours)h "
        }
        
        out += "\(minutes)m"
        
        return out
    }
    
    @ViewBuilder var batteryEnergyModeSelector: some View {
        VStack(spacing: 0) {
            if appState.device.isHighPowerModeCapableDevice {
                if !hidePowerModeOnBattery ||
                    appState.batteryEnergyMode == .high ||
                    isAltKeyPressed {
                    Toggle(target: .automatic, for: .battery)
                    
                    Toggle(target: .low, for: .battery)
                    
                    Toggle(target: .high, for: .battery)
                        .disabled(appState.batteryEnergyMode == .high && hidePowerModeOnBattery && isAltKeyPressed == false)
                } else {
                    Toggle(target: .low, for: .battery, singleMode: true)
                }
            } else {
                Toggle(target: .low, for: .battery, singleMode: true)
            }
        }
    }
    
    @ViewBuilder var adapterEnergyModeSelector: some View {
        if appState.device.isHighPowerModeCapableDevice {
            Toggle(target: .automatic, for: .adapter)
            
            Toggle(target: .low, for: .adapter)
        
            Toggle(target: .high, for: .adapter)
        } else {
            Toggle(target: .low, for: .adapter, singleMode: true)
        }
    }
    
    var body: some View {
        @Bindable var appState = appState
        
        MenuHeader(menuTitle, trailingContent: {
            if isAppleBatteryReplacement && !displayBatteryPercentage {
                if let percentage = appState.batteryCurrentPercentage {
                    Text("\(percentage)%")
                } else {
                    Text("none")
                }
            }
        }, bottomContent: {
            ContentNotificationsView()
//                .controlSize(.large)
            
            if isAppleBatteryReplacement {
                VStack(alignment: .leading) {
                    if appState.isUsingBattery {
                        Text("Power Source: Battery")
                    } else if appState.isUsingPowerAdapter {
                        Text("Power Source: Power Adapter")
                    }
                    
//                    if appState.currentEnergyMode == .low {
//                        Text("Low Power Mode: On")
//                    } else if appState.currentEnergyMode == .high {
//                        Text("High Power Mode: On")
//                    }
                    
                    if appState.isUsingPowerAdapter {
                        if appState.isCharging {
                            // charging, show time till full
                            if appState.timeToFullyCharge == -1 {
//                                Text("Still Calculating the Time")
                            } else if let timeToFullyCharge = appState.timeToFullyCharge,
                                      timeToFullyCharge > 0 {
                                Text("\(timeToFullyCharge.timeRemaining) until fully charged")
                            }
                        } else {
                            // not charging, show why
                            if appState.isFullyCharged || appState.batteryCurrentPercentage == 100 {
                                Text("Fully Charged")
                            } else {
                                Text("Battery Is Not Charging")
                            }
                        }
                    } else {
                        if displayBatteryRemainingInMenu == .always || (displayBatteryRemainingInMenu == .low && (appState.batteryCurrentPercentage ?? 100) <= 20) {
                            // running on battery, show time remaining
                            if let timeUntilEmpty = appState.timeToEmpty, timeUntilEmpty > 0 {
                                Text("\(timeUntilEmpty.timeRemaining) until empty")
                            }
                        }
                    }
                }
//                .padding(.top, 4)
                .font(.callout)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        })
        
//        MenuSection("AlDente") {
////            DenteControl(value: $batteryChargeThreshold, range: 20...100, visibleRange: 0...100) {
////                Text(String(format: "%.0f", $0) + "%")
////                    .foregroundStyle(.black.tertiary)
////                    .font(.subheadline)
////                    .padding(.horizontal, 5)
////            }
//
//            SwiftUI.Toggle("Top Up to 100%", systemImage: "arrow.up.to.line", isOn: .constant(false))
//                .padding(.top, 4)
//        }
        
        MenuContent(settingChargeLimitEnabled ? .default : .default) {
            if useActivePowerSourceOnlyInMenu && !isAltKeyPressed {
                MenuSection(isAppleBatteryReplacement ? "Energy Mode" : nil) {
                    if appState.isUsingPowerAdapter {
                        adapterEnergyModeSelector
                    } else {
                        batteryEnergyModeSelector
                    }
                }
            } else {
                if useActivePowerSourceOnlyInMenu || useCollapsablePowerSourcesInMenu == false {
                    MenuSection {
                        BatteryAutoLowPowerStatus()
                        
                        batteryEnergyModeSelector
                    } label: {
                        Text("Battery")
                            .activePowerSourceIndicator(for: .battery)
                    }
                    
                    MenuSection {
                        adapterEnergyModeSelector
                    } label: {
                        Text("Power Adapter")
                            .activePowerSourceIndicator(for: .adapter)
                    }
                } else {
                    DisclosureGroup(isExpanded: $expandedBattery) {
    #if false
                        Picker("", selection: .constant(EnergyMode.low)) {
                            Label("Low Power", systemImage: "battery.50percent")
                                .tag(EnergyMode.low)
                            
                            Label("Automatic Power Mode", systemImage: "wand.and.stars")
                                .tag(EnergyMode.automatic)
                            
                            if appState.device.isHighPowerModeCapableDevice {
                                if !hidePowerModeOnBattery ||
                                    appState.batteryEnergyMode == .high ||
                                    isAltKeyPressed {
                                    Label("High Power", systemImage: "bolt.fill")
                                        .tag(EnergyMode.high)
                                        .disabled(appState.batteryEnergyMode == .high && hidePowerModeOnBattery && isAltKeyPressed == false)
                                }
                            }
                        }
    #endif
                        BatteryAutoLowPowerStatus()
                        
                        batteryEnergyModeSelector
                    } label: {
                        Text("Battery")
                            .activePowerSourceIndicator(for: .battery)
                    }
                    .menuCollapseToGroup()
                    
                    DisclosureGroup(isExpanded: $expandedAdapter) {
                        adapterEnergyModeSelector
                    } label: {
                        Text("Power Adapter")
                            .activePowerSourceIndicator(for: .adapter)
                    }
                }
            }
        }
//        .setLevel(to: .highlighted)
        .disabled(!helperInstalled)
//        .allowsHitTesting(helperInstalled)
//        .opacity(helperInstalled ? 1.0 : 0.33)
        
//        -- The CHWA key has been removed by Apple --
//        #if arch(arm64)
//        if settingChargeLimitEnabled || isAltKeyPressed || true {
//            MenuSection {
//                //            SwiftUI.Toggle("Charge Limit", systemImage: "rectangle.trailinghalf.inset.filled.arrow.trailing", isOn: .constant(true))
//                SwiftUI.Toggle("Limit Charging to 80%", systemImage: "arrow.up.to.line.compact", isOn: .init {
//                    appState.chargeLimitEnabled
//                } set: { newValue in
//                    Task {
//                        try? await appState.setChargeLimitEnabled(newValue)
//
//                        try await appState.readChargeLimitEnabled()
//                    }
//                })
//            }
//        }
//        #endif
        
        Section {
            VStack(spacing: 0) {
                if isAppleBatteryReplacement {
                    OpenBatterySettingsButton()
                }
                
                MenuSettingsLink("PowerMode Settings…")
            }
        }
    }
}

fileprivate struct OpenBatterySettingsButton: View {
    @Environment(\.dismissMenu) private var dismissMenu
    
    var body: some View {
        VStack {
            Button("Battery Settings…") {
                dismissMenu()
                
                openPrivacySecuritySettings()
            }
        }
    }

    private func openPrivacySecuritySettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.battery") {
            NSWorkspace.shared.open(url)
        }
    }
}

fileprivate struct Toggle: View {
    @Environment(AppState.self) private var appState
    
    // Visual Preferences
    @Preference(\.usePowerInAutomaticLabel) private var usePowerInAutomaticLabel
    
    @Preference(\.useModeInLabel) private var useModeInLabel
    
    @Preference(\.useStaticHighlightColor) private var useStaticHighlightColor
            
    // Arguments
    var target: EnergyMode
    var powerSource: PowerSource
    var singleMode: Bool
    
    init(target: EnergyMode, for powerSource: PowerSource, singleMode: Bool = false) {
        self.target = target
        self.powerSource = powerSource
        self.singleMode = singleMode
    }
    
    // Variables
//    @MainActor private var current: EnergyMode? {
//        appState.currentEnergyMode
//        if powerSource == .battery {
//            appState.batteryEnergyMode
//        } else {
//            appState.adapterEnergyMode
//        }
//    }
    
    private var displayLabel: String {
        var label: [String] = [target.systemString]
        
        if target == .automatic && (usePowerInAutomaticLabel && useModeInLabel) {
            label.append("Power")
        }
        
        if useModeInLabel {
            label.append("Mode")
        }
        
        return label.joined(separator: " ")
    }
    
    private var _isAutoLowPowerModeSetAndBattery: Bool {
        target == .low && powerSource == .battery && appState._didSetAutoLowEnergyMode
    }
    
    private var tintColor: Color? {
        if _isAutoLowPowerModeSetAndBattery {
            return .orange
        }
        
        if useStaticHighlightColor {
            return nil
        }
        
        return target.systemColor
    }
    
    /// Boolean indicating whether this is the energy mode for battery that will be returned to when the device gets plugged in
    @MainActor var displaysIndicator: Bool {
        if powerSource == .battery &&
            appState._lowBatteryPreviousEnergyMode == target {
            return true
        }
        
        // if low power mode is enabled, but no previous energy mode has been set, and didSet is true it will reset to low energy mode
        
        // this happens when cancelling auto low power mode, and then switching to low power mode for battery in system settings
        
        // this is under the assertion that _didSet will then be true
        if powerSource == .battery &&
            appState._lowBatteryPreviousEnergyMode == nil &&
            appState._didSetAutoLowEnergyMode == true &&
            appState.currentEnergyMode == .low &&
            target == .low {
            return true
        }
        
        return false
    }
    
    var body: some View {
        SwiftUI.Toggle(isOn: .init {
            (powerSource == .adapter ? appState.adapterEnergyMode : appState.batteryEnergyMode) == target
        } set: { newValue in
            let computedTarget: EnergyMode
            
            if singleMode {
                computedTarget = newValue ? .low : .automatic
            } else {
                computedTarget = target
            }
            
            if powerSource == .battery {
                Task {
                    await appState.setBatteryEnergyMode(computedTarget, fromUserInteraction: true)
                }
            } else {
                appState.adapterEnergyMode = computedTarget
            }
        }, label: {
            Label {
                HStack {
                    Text(displayLabel)
                    
                    Spacer()
                    
                    if displaysIndicator {
                        Image(systemName: "arrow.turn.down.left")
                            .foregroundStyle(.tertiary)
                            .font(.subheadline)
                    }
                }
            } icon: {
                Image(systemName: target.systemImage)
            }
        })
        .environment(\.menuLightIcon, tintColor == .white)
        .tint(tintColor)
    }
}

#Preview {
    MenuPreview {
        ContentView()
            .environment(AppState())
            .toggleStyle(.controlCenter)
    }
}

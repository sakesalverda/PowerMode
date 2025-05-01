//
//  SettingsAppearanceView.swift
//  PowerMode
//
//  Created by Sake Salverda on 09/03/2024.
//

import SwiftUI

struct SettingsAppearanceView: View {
    @Environment(AppState.self) private var appState
    
    @Preference(\.useStaticHighlightColor) private var useStaticHighlightColor
    
    @Preference(\.useActivePowerSourceOnlyInMenu) private var useActivePowerSourceOnlyInMenu
    @Preference(\.usePowerSourceIndicator) private var usePowerSourceIndicator
    @Preference(\.useCollapsablePowerSourcesInMenu) private var useCollapsablePowerSourcesInMenu
    
    @Preference(\.useModeInLabel) private var useModeInLabel
    
    @Preference(\.menuIconVariant) private var menuIconVariant
    
    @Preference(\.displayBatteryPercentageInMenu) private var displayBatteryPercentage
    @Preference(\.displayBatteryRemainingInMenu) private var displayBatteryRemainingInMenu
    
    @Preference(\.hideHighPowerModeOnBattery) private var hideHighPowerOnBattery
    
    @Preference(\.enableSettingChargeLimit) private var enableChargeLimit
    
    @Preference(\.isAppleBatteryReplacement) private var isAppleBatteryReplacement
    
    var body: some View {
        Form {
            Section("General") {
                VStack(alignment: .leading) {
                    SettingsStandardItem(label: "Show energy mode for active power source only", binding: $useActivePowerSourceOnlyInMenu)
                    
                    if useActivePowerSourceOnlyInMenu == true {
                        Text("Use the option (⌥) key while the menu is open to show the energy mode for both power sources.")
                            .settingsSubheadline()
                    }
                }
                
                SettingsStandardItem(label: "Allow collapsing of a power source in the menu", binding: $useCollapsablePowerSourcesInMenu)
                    .disabled(useActivePowerSourceOnlyInMenu == true)
                
                SettingsStandardItem(label: "Show indicator for current power source in menu", binding: $usePowerSourceIndicator)
                
//                SettingsStandardItem(label: "Show \"Mode\" in energy mode labels", binding: $useModeInLabel)
            }
            
            Section("Menu Bar Icon") {
                SettingsItem("Icon variant") {
                    SettingsPicker {
                        SettingsPickerOption {
                            .init {
                                menuIconVariant == .percentage
                            } set: { newValue in
                                menuIconVariant = .percentage
                            }
                        } content: {
                            Text("90%")
                        } label: {
                            Text("Percentage")
                                .fixedSize()
                        }
                        
                        SettingsPickerOption {
                            .init {
                                menuIconVariant == .status
                            } set: { newValue in
                                menuIconVariant = .status
                            }
                        } content: {
                            ZStack {
                                Group {
                                    RoundedRectangle(cornerRadius: 3)
                                        .strokeBorder(.primary, lineWidth: 1)
                                        .opacity(0.6)
                                    
                                    GeometryReader { proxy in
                                        RoundedRectangle(cornerRadius: 1.5, style: .continuous)
                                            .frame(minWidth: 3, maxWidth: proxy.size.width * 0.9)
                                    }
                                    .padding(2)
                                }
                                .frame(width: 23, height: 12)
                                
                                ZStack{
                                    Image("battery-bolt-mask")
                                        .blendMode(.destinationOut)
                                    
                                    Image("battery-bolt")
                                        .renderingMode(.template)
                                }
                            }
                            .compositingGroup()
                        } label: {
                            Text("Status")
                                .fixedSize()
                        }
                        
                        SettingsPickerOption {
                            .init {
                                menuIconVariant == .default
                            } set: { newValue in
                                menuIconVariant = .default
                            }
                        } content: {
                            MenuBarImage.Base()
                        } label: {
                            Text("App Icon")
                                .fixedSize()
                        }
                    }
                    .controlSize(.small)
                }
                
                Toggle("Show battery percentage", isOn: $displayBatteryPercentage)
                                    .disabled(menuIconVariant == .percentage)
                
                SettingsItem("Energy mode indicator in menu bar") {
                    MenuBarIconPicker()
                        .environment(\.verticalSizeClass, .compact)
                }
                
                
            }
            
            Section("Advanced") {
                VStack(alignment: .leading) {
                    Toggle("Replace Apple's battery Menu Bar item", isOn: $isAppleBatteryReplacement)
                    
                    Text("This setting adds some additional information about battery/charging state that is also shown by the Mac OS default battery menu to the Menu Bar menu.")
                        .settingsSubheadline()
                }
                .highlightedSection(when: menuIconVariant != .default || displayBatteryPercentage)
//                .conditional(!isAppleBatteryReplacement) {
//                    $0
//                        .animation(.interpolatingSpring(duration: 0.3, bounce: 0.8), value: menuIconVariant)
//                        .animation(.interpolatingSpring, value: displayBatteryPercentage)
//                }
                
                VStack(alignment: .leading) {
                    Picker("Display time remaining on battery", selection: $displayBatteryRemainingInMenu) {
                        Text("Never").tag(MenuBarBatteryRemainingDisplayOptions.never)
                        Text("Below 20%").tag(MenuBarBatteryRemainingDisplayOptions.low)
                        Text("Always").tag(MenuBarBatteryRemainingDisplayOptions.always)
                    }
                    
                    if displayBatteryRemainingInMenu != .never {
                        if let timeToEmpty = appState.timeToEmpty {
                            if timeToEmpty == -1 {
                                Text("Calculating time until empty…")
                                    .settingsSubheadline()
                            } else if timeToEmpty > 0 {
                                Text("\(timeToEmpty.timeRemaining) until empty")
                                    .settingsSubheadline()
                            }
                        }
                    }
                }
                .disabled(!isAppleBatteryReplacement)
                
                if appState.device.isHighPowerModeCapableDevice {
                    HighPowerModeView()
                }
                
//                Toggle("Allow setting charge limit", isOn: $enableChargeLimit)
            }
            
//            Section("Menu Appearance") {
//                SettingsItem("Use system or app accent color for highlighting energy modes") {
//                    SettingsThemePicker()
//                }
//            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

extension View {
    func highlightedSection(when condition: Bool = true) -> some View {
        background {
            if condition {
                Rectangle()
                    .foregroundStyle(.quaternary)
                    .padding(.horizontal, -10)
                    .padding(.vertical, -10)
                    .transition(.asymmetric(insertion: .opacity, removal: .identity))
            }
        }
    }
}

private extension SettingsAppearanceView {
    struct HighPowerModeView: View {
        @Preference(\.hideHighPowerModeOnBattery) private var hidePowerModeOnBattery
        
        var body: some View {
            VStack(alignment: .leading) {
                SettingsStandardItem(label: "Hide \"High Power\" option on battery", binding: $hidePowerModeOnBattery)
                
                if hidePowerModeOnBattery == true {
                    Text("Use the option (⌥) key while the menu is open to show the high power option.")
                        .settingsSubheadline()
                }
            }
        }
    }
}

#Preview {
    SettingsPreview {
        SettingsAppearanceView()
    }
    .environment(AppState.preview)
}

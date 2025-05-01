//
//  SettingsGeneralView.swift
//  PowerMode
//
//  Created by Sake Salverda on 23/01/2024.
//

import SwiftUI
import LaunchAtLogin
import Sparkle
import OSLog

extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier!
    
    static let misc = Logger(subsystem: subsystem, category: "misc")
}

struct SettingsGeneralView: View {
    @Environment(AppState.self) private var appStateNew
    
    @Preference(\.enableLowPowerModeOnLowBattery) private var enableLowPowerModeOnLowBattery
    
    var updater: SPUUpdater?
    
    var bindingEnableLowPowerMode: Binding<Bool> {
        .init {
            enableLowPowerModeOnLowBattery
        } set: { newValue in
            enableLowPowerModeOnLowBattery = newValue
            
            if newValue == true {
                Task {
                    await appStateNew.notifications.requestAuthorization()
                }
            }
        }
    }
    
    @State private var considerSupportSheetPresented: Bool = false
    
    @State private var threshold = 20.0
    
    var body: some View {
        VStack(spacing: SettingsGeometry.verticalSpacing) {
            Form {
                Section {
                    VStack {
                        SettingsItem {
                            Text("Automatically enable low power mode when battery is low")
                                .infoButton {
                                    SettingsAutoLowPowerInfoButton.Sheet()
                                }
                        } content: {
                            if appStateNew.didEnableConsiderSupportingFunctionalities {
                                Toggle(isOn: bindingEnableLowPowerMode) {}
                                    .labelsHidden()
                            } else {
                                Button(action: {
                                    considerSupportSheetPresented = true
                                }) {
                                    Text("support")
                                }
                                .buttonStyle(.accessoryBarAction)
                                .controlSize(.small)
                            }
                        }
                        .sheet(isPresented: $considerSupportSheetPresented, content: {
                            ConsiderSupportingSheet()
                        })
                        
                        
//                        SettingsItem("Auto enable at") {
//                            Toggle(isOn: .constant(true))
//                            Slider(value: $threshold, in: 10...25, step: 5)
//
//                            Text("\(threshold/100, format: .percent)")
//                                .frame(width: 30, alignment: .trailing)
//                        }
//                        .padding(.leading, 14)
                    }
                    
                    // only show hide high power mode for devices that support high power mode
//                    if appStateNew.device.isHighPowerModeCapableDevice {
//                        HighPowerModeView()
//                    }
                    
                    LaunchAtLogin.Toggle {
                        SettingsLabel("Launch at Login")
                    }
                    .toggleStyle(.switch)
                    .controlSize(.mini)
                }
                
                Section {
                    if let updater = updater {
                        SettingsUpdateView(updater: updater)
                    } else {
                        SettingsUpdateView(autoCheck: true, autoDownload: false)
//                        HStack {
//                            Image(systemName: "exclamationmark.triangle.fill")
//                                .foregroundStyle(.secondary)
//
//                            Text("Running without update manager")
//                                .onAppear {
//                                    Logger.misc.error("Running settings without any update manager set")
//                                }
//
//                            Spacer()
//                        }
                    }
                } header: {
                    HStack(spacing: 25) {
                        Text("Updates")
                        
                        if appStateNew.updateAvailable {
                            Button(action: {
                                NotificationCenter.default.post(name: .openInstallUpdate, object: nil)
                            }) {
                                Text("Install update")
                            }
                            .buttonStyle(.capsule(.tint))
                            .controlSize(.small)
                        }
                    }
                }
                
                Section("Helper") {
                    SettingsHelperStateView(status: appStateNew.helper.status)
                        .highlightedSection(when: appStateNew.helper.status != .enabled)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            
            Button(action: {
                NSApplication.shared.terminate(nil)
            }) {
                Text("Quit Appplication")
            }
        }
        .scenePadding(.bottom)
    }
}

#Preview {
    SettingsPreview {
        SettingsGeneralView(updater: nil)
            .environment(AppState())
    }
}

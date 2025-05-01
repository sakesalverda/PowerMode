//
//  DebugSheet.swift
//  PowerMode
//
//  Created by Sake Salverda on 20/02/2024.
//

import SwiftUI
import Sparkle
import OSLog

extension DebugData {
    struct Version: Encodable {
        var version: String?
        var build: String?
    }
    
    struct LowPowerModeData: Encodable {
        var enabled: Bool
        var triggered: Bool
        var resetTo: String?
        var cancelled: Bool
        var threshold: Int
    }
    
    struct DonationData: Codable {
        var state: DonationState
        var modalState: DonationModalState
    }
    
    struct CapabilitiesData: Encodable {
        var isBatteryCapableDevice: Bool
        var isAdapterCapableDevice: Bool
        var isAnyPowerModeCapableDevice: Bool
        var isHighPowerModeCapableDevice: Bool
    }
}

struct DebugData: Encodable {
    var app: Version
    var helper: Version
    
    var autoLowPowerMode: LowPowerModeData
    
    var energyModeKey: String?
    
    var capabilities: CapabilitiesData
    
    var rawTerminalResponse: String
    
    init(state: AppState) async {
        self.app = .init(
            version: Bundle.main.version,
            build: Bundle.main.build
        )
        
        do {
            let (v, b) = try await state.helper.withThrowingConnection {
                return try await $0.getBuild()
            }
            
            self.helper = .init(version: v, build: b)
        } catch {
            self.helper = .init()
        }
        
        autoLowPowerMode = await .init(
            enabled: Preferences.instance.enableLowPowerModeOnLowBattery,
            triggered: state._didSetAutoLowEnergyMode,
            resetTo: state._lowBatteryPreviousEnergyMode?.humanReadableValue,
            cancelled: state._didCancelAutoLowEnergyMode,
            threshold: Preferences.instance.autoLowPowerModeDischargeThreshold
        )
        
        energyModeKey = state.helper.energyModeKey?.humanReadableValue
        
        capabilities = .init(
            isBatteryCapableDevice: state.device.isBatteryCapableDevice,
            isAdapterCapableDevice: state.device.isAdapterCapableDevice,
            isAnyPowerModeCapableDevice: state.device.isAnyPowerModeCapableDevice,
            isHighPowerModeCapableDevice: state.device.isHighPowerModeCapableDevice
        )
        
        if let response =  try? await state.getRawConfiguration() {
            rawTerminalResponse = response
        } else {
            rawTerminalResponse = "terminal error"
        }
    }
}

struct DebugSheet: View {
    @Environment(AppState.self) private var appState
    
    var updater: SPUUpdater? = nil
    
    @Preference(\.updateFeedString) private var feedString
    
    @State private var helper: (version: String, build: String)? = nil
    
    @State private var showingSupportResetConfirmation: Bool = false
    @State private var showingDebugFeedConfirmation: Bool = false
    
    @Preference(\.autoLowPowerModeDischargeThreshold) private var dischargeThreshold
    
    func retrieveHelperVersion() async {
        do {
            try await appState.helper.withThrowingConnection {
                self.helper = try await $0.getBuild()
            }
        } catch {
            self.helper = nil
        }
    }
    
    var body: some View {
        VStack {
            Button {
                Task {
                    let log = await DebugData(state: appState)
                    
                    let encoder = JSONEncoder()
                    
                    do {
                        let encoded = try encoder.encode(log)
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyyMMdd.HH-mm-ss"
                        let dateString = dateFormatter.string(from: Date())
                        
                        let savePanel = NSSavePanel()
                        savePanel.nameFieldStringValue = "powermode-debug-\(dateString).json"
                        
                        savePanel.directoryURL = .downloadsDirectory
                        
                        savePanel.begin { (result) in
                            if result == .OK {
                                if let fileURL = savePanel.url {
                                    do {
                                        try encoded.write(to: fileURL, options: .atomic)
                                        print("Text file created successfully at: \(fileURL.path)")
                                    } catch {
                                        print("Error creating text file: \(error)")
                                    }
                                }
                            }
                        }
                    } catch {
                        Logger.batteryMonitor.warning("\(error.localizedDescription)")
                    }
                }
            } label: {
                Text("Create Debug File")
            }
            .buttonStyle(.capsule)
            .padding(.top)
            
            Form {
                Section("App") {
                    HStack {
                        Text("Version")
                        
                        Spacer()
                        
                        Text(Bundle.main.version ?? "")
                    }
                    
                    HStack {
                        Text("Build")
                        
                        Spacer()
                        
                        Text(Bundle.main.build ?? "-")
                    }
                    
                    HStack {
                        Text("Update Feed")
                        
                        Spacer()
                        
                        Text(feedString == nil ? "release" : "debug")
                        .onTapGesture(count: 4, perform: {
                            showingDebugFeedConfirmation = true
                        })
                        .font(.callout)
                        .foregroundStyle(feedString == nil ? AnyShapeStyle(.secondary) : AnyShapeStyle(.orange))
                        .confirmationDialog("Are you sure you want to enable the debug feed?", isPresented: $showingDebugFeedConfirmation) {
                            Button("Continue", role: .destructive) {
                                if feedString != true {
                                    feedString = true
                                } else {
                                    feedString = nil
                                }
                            }
                        } message: {
                            Text("The debug feed is used for debugging purposes and will *not* contain release updates. Please do not enable the debug feed!")
                        }
                    }
                }
                
                Section {
                    HStack {
                        Text("Version")
                        
                        Spacer()
                        
                        Text(helper?.version ?? "-")
                    }
                    .task {
                        await retrieveHelperVersion()
                    }
                    
                    HStack {
                        Text("Build")
                        
                        Spacer()
                        
                        Text(helper?.build ?? "-")
                    }
                } header: {
                    HStack {
                        Text("Helper")
                        
                        Spacer()
                        
                        Button {
                            Task {
                                await retrieveHelperVersion()
                            }
                        } label: {
                            Image(systemName: "arrow.clockwise")
                                .fontWeight(.semibold)
                                .padding(5)
                            //                            .background(Color(nsColor: .controlColor))
                                .background(Color(nsColor: .controlColor), in: Circle())
                                .foregroundStyle(Color(nsColor: .controlTextColor))
                        }
                        .contentShape(Circle())
                        .frame(height: 0)
                        .buttonStyle(.plain)
                    }
                }
                
                Section("Low Power Mode due to Low Battery") {
                    HStack {
                        Text("Enabled")
                        
                        Spacer()
                        
                        Text(Preferences.instance.enableLowPowerModeOnLowBattery ? "yes" : "no")
                    }
                    
                    HStack {
                        Text("Triggered")
                        
                        Spacer()
                        
                        Text(appState._didSetAutoLowEnergyMode ? "yes" : "no")
                    }
                    
                    HStack {
                        Text("Reset to ")
                        
                        Spacer()
                        
                        if let previous = appState._lowBatteryPreviousEnergyMode {
                            switch previous {
                            case .automatic:
                                Text("automatic")
                            case .low:
                                Text("low")
                            case .high:
                                Text("high")
                            }
                        } else {
                            Text("-")
                        }
                    }
                    
                    HStack {
                        Text("Cancelled")
                        
                        Spacer()
                        
                        Text(appState._didCancelAutoLowEnergyMode ? "yes" : "no")
                    }
                    
                    HStack {
                        Text("Threshold")
                        
                        Spacer()
                        
                        EasySlider(binding: $dischargeThreshold)
                        
                        //                                .frame(width: 30, alignment: .trailing)
//                        TextField("Threshold", value: $dischargeThreshold, format: .percent)
//                            .textFieldStyle(.plain)
//                            .onChange(of: dischargeThreshold) {
//                                dischargeThreshold = max(10, min(90, dischargeThreshold))
//                            }
                        
//                        Text("\(dischargeThreshold, format: .percent)")
                    }
                    
                    HStack {
                        Spacer()
                        
                        Button {
                            appState._didSetAutoLowEnergyMode = Defaults.didTriggerAutoLowPowerMode.defaultValue
                            appState._didCancelAutoLowEnergyMode = Defaults.didCancelAutoLowPowerMode.defaultValue
                            appState._lowBatteryPreviousEnergyMode = Defaults.lowBatteryPreviousEnergyMode.defaultValue
                            dischargeThreshold = Defaults.lowBatteryDischargeThreshold.defaultValue
                        } label: {
                            Text("Reset")
                        }
                        .buttonStyle(.bordered)
                        .fontWeight(.regular)
                    }
                }
                
                Section("Contribution Tip") {
                    HStack {
                        Text("State")
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            switch appState.supportState {
                            case .initial:
                                Text("initial")
                            case .awaiting(let id):
                                Text("awaiting")
                                Text(id).font(.footnote).foregroundStyle(.secondary)
                            case .error(let id):
                                Text("error")
                                Text(id).font(.footnote).foregroundStyle(.secondary)
                            case .success(let id):
                                Text("success")
                                Text(id).font(.footnote).foregroundStyle(.secondary)
                            }
                        }
                    }
                    
                    HStack {
                        Text("Dismissed modal")
                        
                        Spacer()
                        
                        switch appState.supportModalState {
                        case .initial:
                            Text("initial")
                        case .dismissed:
                            Text("dismissed")
                        case .linkOpened:
                            Text("linkOpened")
                        }
                    }
                    
                    HStack {
                        Spacer()
                        
                        Button {
                            showingSupportResetConfirmation = true
                        } label: {
                            Text("Reset")
                        }
                        .buttonStyle(.bordered)
                        .fontWeight(.regular)
                    }
                    .confirmationDialog("Are you sure you want to reset the contributed state?", isPresented: $showingSupportResetConfirmation) {
                        Button("Reset") {
                            appState.supportState = .initial
                            appState.supportModalState = .initial
                        }
                        Button("Cancel", role: .cancel) { }
                    } message: {
                        Text("Future updates might contain some functionality that is restricted to users that contributed only. Are you sure you want to delete your contribution information from the app?")
                    }
                }
                
                Section("Device") {
                    HStack {
                        Text("Energy mode key")
                        
                        Spacer()
                        
                        if let key = appState.helper.energyModeKey {
                            Text(key.humanReadableValue)
                        } else {
                            Text("-")
                        }
                    }
                    
                    HStack {
                        Text("Supports low power mode")
                        
                        Spacer()
                        
                        Text(appState.device.isAnyPowerModeCapableDevice ? "yes" : "no")
                    }
                    
                    HStack {
                        Text("Supports high power mode")
                        
                        Spacer()
                        
                        Text(appState.device.isHighPowerModeCapableDevice ? "yes" : "no")
                    }
                    
                    HStack {
                        Text("Supports configuration for battery")
                        
                        Spacer()
                        
                        Text(appState.device.isBatteryCapableDevice ? "yes" : "no")
                    }
                    
                    HStack {
                        Text("Supports configuration for ac adapter")
                        
                        Spacer()
                        
                        Text(appState.device.isAdapterCapableDevice ? "yes" : "no")
                    }
                }
                
                Section("Time") {
                    HStack {
                        Text("Last read")
                        
                        Spacer()
                        
                        Text(appState.lastRead, format: .dateTime.day().month().year().hour().minute().second())
                    }
                    
                    HStack {
                        Text("Last set")
                        
                        Spacer()
                        
                        if let date = appState.lastSet {
                            Text(date, format: .dateTime.day().month().year().hour().minute().second())
                        } else {
                            Text("-")
                        }
                    }
                }
            }
            .frame(maxHeight: 600)
        }
    }
    
    @MainActor
    struct EasySlider: View {
        @Binding var binding: Int
        
        init(binding: Binding<Int>) {
            self._binding = binding
        }
        
        @State private var slideDischargeThreshold: Double = Double(Preferences.instance.autoLowPowerModeDischargeThreshold)
        
        var body: some View {
            Slider(value: $slideDischargeThreshold, in: 10...90, step: 5) { editing in
                if !editing {
                    self.binding = Int(slideDischargeThreshold)
//                    print(Int(slideDischargeThreshold))
//                    closure(Int(slideDischargeThreshold))
                }
            }
            .onChange(of: binding) {
                self.slideDischargeThreshold = Double(binding)
            }
            
            Text("\(slideDischargeThreshold/100, format: .percent)")
        }
    }
}

#Preview {
    SettingsPreview {
        DebugSheet()
            .environment(AppState.preview)
    }
}

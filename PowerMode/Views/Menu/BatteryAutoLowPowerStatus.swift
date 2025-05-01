//
//  BatteryLowPowerStatus.swift
//  PowerMode
//
//  Created by Sake Salverda on 13/03/2024.
//

import SwiftUI
import ControlCenterExtra

fileprivate extension View {
    func statusWrapper() -> some View {
//        padding(.vertical, 4)
//        padding(.horizontal, 7)
//                .menuInset(.horizontal, to: .content)
        
        defaultMenuInteractions(hover: true)
//        .background(.quinary, in: RoundedRectangle(cornerRadius: 3))
//        .padding(true ? .vertical : .bottom, 3)
//                .menuInset(.horizontal, to: .highlight)
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }
    
    func statusButton() -> some View {
        self
            .font(.caption)
            .fontWeight(.medium)
            .padding(.vertical, 1.5)
            .padding(.horizontal, 4)
            .foregroundStyle(.black.secondary)
            .background(.white, in: RoundedRectangle(cornerRadius: 40))
    }
}

struct BatteryAutoLowPowerStatus: View {
    @Environment(AppState.self) private var appState
    
    var forceDidSet: Bool = false
    var forceDidCancel: Bool = false
    
    var body: some View {
        if appState._didCancelAutoLowEnergyMode || forceDidCancel {
            HStack(alignment: .center) {
                Text("Automatic low power mode cancelled")
                
                Spacer(minLength: 0)
                
                Button {
                    appState._didSetAutoLowEnergyMode = false
                    appState._lowBatteryPreviousEnergyMode = nil
                    appState._didCancelAutoLowEnergyMode = false
                } label: {
                    Text("Re-enable")
                        .statusButton()
                }
            }
            .statusWrapper()
            .buttonStyle(.plain)
        }
        
//        if appState._didSetAutoLowEnergyMode || forceDidSet {
//            HStack {
//                Text("Low power mode enabled due to low battery")
//
//                Spacer()
//
//                Button {
//                    appState.restorePreviousBatteryMode(withCancel: true)
//                } label: {
//                    Text("Cancel")
//                        .statusButton()
//                }
//                .buttonStyle(.plain)
//            }
//            .statusWrapper()
//        }
    }
}

#Preview {
    MenuPreview {
        VStack(spacing: 30) {
            DisclosureGroup("Battery", isExpanded: .constant(true)) {
                BatteryAutoLowPowerStatus(forceDidSet: true, forceDidCancel: false)
                
                Toggle("Low Power", systemImage: EnergyMode.low.systemImage, isOn: .constant(true))
                    .tint(Color.orange)
//                    .environment(\.menuLightIcon, true)
                
                Toggle("Automatic", systemImage: EnergyMode.automatic.systemImage, isOn: .constant(false))
            }
            
            DisclosureGroup("Battery", isExpanded: .constant(true)) {
                BatteryAutoLowPowerStatus(forceDidSet: false, forceDidCancel: true)
                
                Toggle("Low Power", systemImage: EnergyMode.low.systemImage, isOn: .constant(false))
                
                Toggle("Automatic", systemImage: EnergyMode.automatic.systemImage, isOn: .constant(true))
            }
        }
    }
    .environment(AppState.preview)
}

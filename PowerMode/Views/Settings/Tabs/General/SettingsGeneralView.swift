//
//  SettingsAutoLowPowerInfoButton.swift
//  PowerMode
//
//  Created by Sake Salverda on 23/01/2024.
//

import SwiftUI
import Walberg

struct SettingsAutoLowPowerInfoButton {}

extension SettingsAutoLowPowerInfoButton {
    struct Sheet: View {
        @Preference(\.autoLowPowerModeDischargeThreshold) private var autoLowPowerModeDischargeThreshold
        
        @Environment(\.dismiss) private var dismiss
        
        var body: some View {
            SettingsSheet("Automatic Low Power Mode\n on Low Battery") {
                Text("The energy mode will be automatically set to Low Power Mode when the battery level falls below \(autoLowPowerModeDischargeThreshold)%.")
//                    .foregroundStyle(.secondary)
                
                Text(#""Low Power Mode due to low battery" will be cancelled when the device is plugged into an active charger or by manually selecting another energy mode for battery."#)
//                    .foregroundStyle(.tertiary)
            }
        }
    }
}

struct ConsiderSupportingSheet: View {
    @Environment(AppState.self) private var appState
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var didStartProcess: Bool = false
    
    @Environment(DonationOptionsViewModel.self) private var donationViewModel
    
    var minimumAmount: Double? {
        if case .loaded(let options) = donationViewModel.state {
            return options.suggestedAmount
        }
        
        return nil
    }
    
    var currencyCode: String {
        if case .loaded(let options) = donationViewModel.state {
            return options.locale
        } else {
            return "EUR"
        }
    }
    
    var body: some View {
        SettingsSheet("Please consider supporting the app") {
            Text("We'd like to bring your attention to consider a small contribution/tip to support the development of the app if you like the app.")
            
//            Text("Even a contribution/tip of \(minimumAmount ?? 1, format: .currency(code: currencyCode)) would go a long way in helping me to continue this app in the future.")
            
            DonationView()
                .environment(\.horizontalSizeClass, .compact)
                .environment(\.verticalSizeClass, .compact)
                .environment(\.openURL, OpenURLAction { url in
                    appState.supportModalState = .linkOpened
                    
                    dismiss()
                    
                    return .systemAction
                })
            
            VStack(alignment: .leading) {
                Text("I don't want to donate but would still like to use the automatic low power mode functionality")
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                
                Text(#"That's possible, if in the future you would like to support the app, please visit the "About" tab of the settings."#)
                
                Text(LocalizedStringKey("To use without donating, click [here](PowerMode://no-action)"))
                    .environment(\.openURL, OpenURLAction { url in
                        appState.supportModalState = .dismissed
                        
                        dismiss()
                        
                        return .handled
                    })
                .padding(.top, 3)
                .tint(.accentColor.opacity(0.75))
            }
            .font(.callout)
            .foregroundStyle(.tertiary)
        }
    }
}

#Preview {
    SettingsPreview {
        SettingsAutoLowPowerInfoButton.Sheet()
            .background(.white)
            .cornerRadius(15)
            .environment(AppState.preview)
    }
}

#Preview("ConsiderSupportingSheet") {
    SettingsPreview {
        ConsiderSupportingSheet()
            .background(.white)
            .cornerRadius(15)
            .environment(AppState.preview)
            .environment(DonationOptionsViewModel())
    }
}

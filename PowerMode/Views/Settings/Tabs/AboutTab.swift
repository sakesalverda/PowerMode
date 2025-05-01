//
//  SettingsAboutView.swift
//  PowerMode
//
//  Created by Sake Salverda on 14/12/2023.
//

import SwiftUI

fileprivate extension Bundle {
    var iconFileName: String? {
        guard let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
              let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
              let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
              let iconFileName = iconFiles.last
        else { return nil }
        return iconFileName
    }
}

struct SettingsAboutView: View {
    @Environment(AppState.self) private var appState
    
    @Binding var debugEnabled: Bool
    
    private let iconSize: CGFloat = 60
    
    var body: some View {
        VStack(spacing: 25) {
            HStack(spacing: 4) {
                Image(nsImage: NSApplication.shared.applicationIconImage)
                    .resizable()
                    .frame(width: iconSize, height: iconSize)
                    .shadow(color: .black.opacity(0.1), radius: 10)
                    .onLongPressGesture(minimumDuration: 3) {
                        debugEnabled.toggle()
                    }
                    .phaseAnimator([1, 0], trigger: debugEnabled) { content, phase in
                        content.scaleEffect(phase == 0 ? 0.7 : 1)
                    } animation: { phase in
                        if phase == 1 {
                            return .bouncy(duration: 0.35, extraBounce: 0.35)
                            //                    return .snappy(duration: 0.4, extraBounce: 0.3)
                        } else {
                            return .smooth(duration: 0.1)
                        }
                    }
                
                VStack(alignment: .leading, spacing: 0) {
                    Group {
                        var name = Bundle.main.displayName ?? "Unknown"
                        var version = Bundle.main.version ?? "?"
                        
                        Text("\(name) \(version)")
                    }
//                    Text("\(Bundle.main.displayName ?? "unknown") \(Bundle.main.version ?? "-")")
                        .font(.headline.weight(.semibold))
                    
                    if let url = URL(string: Links.main) {
                        Link(Links.mainText, destination: url)
                    }
                    
                    Text("by \(Constants.company) 2024")
                        .padding(.top, 1)
                }
                
                Spacer()
            }
            
            DonationView()
                .environment(\.skipDonationInitiate, true)
        }
    }
}

#Preview {
    SettingsPreview {
        SettingsAboutView(debugEnabled: .constant(true))
            .padding(.vertical, 50)
            .padding(.horizontal, 20)
            .environment(AppState.preview)
            .environment(DonationOptionsViewModel())
    }
}

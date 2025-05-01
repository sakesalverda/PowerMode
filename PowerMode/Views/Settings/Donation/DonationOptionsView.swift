//
//  DonationOptionsView.swift
//  PowerMode
//
//  Created by Sake Salverda on 06/03/2024.
//

import SwiftUI
import OSLog

extension DonationOptionsView {
    private func performDonationIntent() async {
        Logger.donateIntent.trace("Performing donation intent")
        
        guard let amount = getChosenAmount() else {
            Logger.donateIntent.warning("No intent amount given")
            return
        }
        
//        guard let localizedOptions = configuration.localized else {
//            Logger.donateIntent.warning("Localised data has not been loaded for intent")
//            return
//        }
        
        Logger.donateIntent.trace("Sending intent information to API")
        await intentViewModel.loadData(amount: amount, locale: configuration.locale)
        Logger.donateIntent.trace("Received intent feedback")
        
        guard case .loaded(let response) = intentViewModel.state else {
            Logger.donateIntent.warning("Intent has other state then loaded")
            
            return
        }

        guard let paymentRedirectURL = URL(string: response.paymentRedirect) else {
            Logger.donateIntent.warning("Could not obtain url from donation intent api")
            
            return
        }
        
        Logger.donateIntent.notice("Succesfully retrieved a tracking id for the donation process")
        appState.supportState = .awaiting(response.id)
        
        openURL(paymentRedirectURL)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct DonationOptionsView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.openURL) private var openURL
    
    var configuration: DonationOptions
    
    @State private var intentViewModel = DonationIntentViewModel()
    
    @State private var selectedAmount: Double? = 1 {
        didSet {
            if selectedAmount != nil {
                isCustomSelected = false
            }
        }
    }
    @State private var customAmount: Double? = nil
    
    @State private var isCustomSelected: Bool = false
    
    @FocusState private var isCustomFocused: Bool
    
    private var hasAmount: Bool {
        getChosenAmount() != nil
    }
    
    private func getChosenAmount() -> Double? {
        if let selectedAmount {
            return selectedAmount
        } else if
            isCustomSelected,
            let customAmount,
            let options = configuration.options,
            let minimumAmount = options.minimumAmount,
            customAmount >= minimumAmount {
            return customAmount
        }
        
        return nil
    }
    
    var body: some View {
        VStack {
            if let preset = configuration.options {
                HStack {
                    ForEach(preset.items, id: \.self) { amount in
                        Button {
                            if selectedAmount == amount {
                                selectedAmount = nil
                            } else {
                                selectedAmount = amount
                            }
                        } label: {
                            Text("\(amount, format: .currency(code: configuration.locale))")
                                .donateStyle(isPrimary: amount == selectedAmount)
                        }
                        .buttonStyle(.plain)
                        .focusable()
                        .focusEffectDisabled()
                    }
                    
                    TextField("custom", value: $customAmount, format: .currency(code: configuration.locale))
                        .textFieldStyle(.plain)
                        .donateStyle(isPrimary: isCustomSelected)
                        .focused($isCustomFocused)
                        .onChange(of: isCustomFocused) {
                            if isCustomFocused {
                                isCustomSelected = true
                                selectedAmount = nil
                            }
                        }
                        .onChange(of: isCustomSelected) { old, new in
                            if old == false && new == true {
                                customAmount = nil
                            }
                        }
                }
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 20)
                
                Button {
                    Task {
                        await performDonationIntent()
                    }
                } label: {
                    ZStack {
                        Text("Continue")
                            .hidden(intentViewModel.isShowingIndicator)
                        
                        if intentViewModel.isShowingIndicator {
                            ProgressView()
                                .controlSize(.small)
                                .colorScheme(.dark)
                                .frame(width: 0, height: 0)
                        }
                    }
                }
                .buttonStyle(.capsule(.tint))
                .disabled(!hasAmount)
                
                Text("You will be redirected to the payment website")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            
            if let links = configuration.links {
                if configuration.options != nil {
                    Text("Or donate via")
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .padding(.top)
                }
                
                HStack(alignment: .bottom, spacing: 14) {
                    ForEach(links, id: \.title) { link in
                        var color: Color? {
                            if let hex = link.color {
                                return Color(hex: hex)
                            }
                            
                            return nil
                        }
                        var background: Color {
                            Color(hex: link.background)
                        }
                        
                        VStack {
                            if let message = link.message {
                                HStack {
                                    Text(message)
                                        .font(.footnote)
                                        .multilineTextAlignment(.center)
                                        .foregroundStyle(.tertiary)
                                        .frame(maxWidth: 190)
                                        .padding(5)
                                        .fixedSize()
                                        .frame(width: 10)
                                }
                            }
                            
                            Link(destination: link.url) {
                                Text("\(link.title)")
                            }
                            .buttonStyle(DonationLinkButtonStyle(background: background, color: color))
                        }
                    }
                }
            }
        }
    }
}

struct DonationLinkButtonStyle: ButtonStyle {
    var background: Color
    var color: Color?
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fontWeight(.semibold)
            .padding(.vertical, 4)
            .padding(.horizontal, 11)
            .foregroundStyle( color ?? .white )
            .background {
                Color.white.opacity(configuration.isPressed ? 0.25 : 0)
            }
            .background { background }
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 0.5)
    }
}

#Preview {
    SettingsPreview {
        VStack(spacing: 50) {
            DonationOptionsView(configuration: .init(
                locale: "EUR",
                suggestedAmount: nil,
                options: .init(items: [1.5, 2.5, 5], customAllowed: true, minimumAmount: 1),
                links: [
                    .init(kind: "revolut", title: "Revolut", message: "Supports Creditcards, Apply Pay, Google Pay and Revolut Pay", url: URL(string: "https://sakesalverda.nl")!, background: "#000" ),
                    .init(kind: "revolut", title: "PayPal", url: URL(string: "https://sakesalverda.nl")!, background: "#0079C1", color: "#fff" )
                ]
            ))
            DonationOptionsView(configuration: .init(
                locale: "EUR",
                suggestedAmount: nil,
                options: .init(items: [1.5, 2.5, 5], customAllowed: true, minimumAmount: 1),
                links: nil
            ))
            DonationOptionsView(configuration: .init(
                locale: "EUR",
                suggestedAmount: nil,
                options: nil,
                links: [
                    .init(kind: "revolut", title: "Revolut", message: "Supports Creditcards, Apply Pay, Google Pay and Revolut Pay", url: URL(string: "https://sakesalverda.nl")!, background: "#000" ),
                    .init(kind: "revolut", title: "PayPal", url: URL(string: "https://sakesalverda.nl")!, background: "#0079C1", color: "#fff" )
                ]
            ))
        }
    }
    .environment(AppState.preview)
    .padding(.vertical)
}

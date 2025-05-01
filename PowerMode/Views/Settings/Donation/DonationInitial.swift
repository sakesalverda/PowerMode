//
//  DonationInitial.swift
//  PowerMode
//
//  Created by Sake Salverda on 12/02/2024.
//

import SwiftUI
import OSLog

extension Logger {
    static let donateLoadOptions = Self(.main, "donate.options.load")
    static let donateIntent = Self(.main, "donate.options.intent")
}

@Observable
class DonationIntentViewModel {
    /// Response for a donation intent
    struct Response: Codable, Equatable {
        /// Internal identifier for the payment
        let id: String
        
        /// URL to payment processor
        let paymentRedirect: String
    }
    
    enum State: Equatable {
        case idle
        case loading
        case failed(DonationError)
        case loaded(Response)
    }
    
    var state: State = .idle
    
    var isShowingIndicator: Bool = false
    
    func loadData(amount: Double, locale: String) async {
        state = .loading
        
        // create a task to await showing the loading indicator
        let indicatorTask = Task {
            try await Task.sleep(for: .milliseconds(100))
            
            isShowingIndicator = true
        }
        
        defer {
            indicatorTask.cancel()
            
            isShowingIndicator = false
        }
        
        do {
            let apiEndpoint = "https://api.sakesalverda.nl/powermode/donation/intent/\(locale)/\(amount)"
            
            guard let url = URL(string: apiEndpoint) else {
                Logger.donateLoadOptions.warning("API endpoint to load support options is invalid")
                
                throw DonationError.url
            }
            
            let data: Data
            let decodedResponse: Response
            
            do {
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                
                (data, _) = try await URLSession.shared.data(for: request)
            } catch {
                Logger.donateLoadOptions.warning("Could not load support options")
                
                throw DonationError.session
            }
            
            do {
                decodedResponse = try JSONDecoder().decode(Response.self, from: data)
            } catch {
                Logger.donateLoadOptions.warning("Could not decode response for support options")
                
                print(String(decoding: data, as: UTF8.self))
                
                let decodedError = try? JSONDecoder().decode(DonationErrorResponse.self, from: data)
                
                if let decodedError {
                    throw DonationError.response(decodedError.error)
                }
                
                throw DonationError.decoding
            }
            
            state = .loaded(decodedResponse)
        } catch let error as DonationError {
            state = .failed(error)
        } catch {}
    }
}

struct DonationInitial: View {
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @Environment(AppState.self) private var appState
    
    @Environment(DonationOptionsViewModel.self) private var viewModel
    
    @Environment(\.skipDonationInitiate) private var skipInitiate
    
    @State fileprivate var didInitiate: Bool = false
    
    private var shouldInitiate: Bool {
        if skipInitiate {
            return false
        } else {
            if didInitiate {
                return false
            }
        }
        
        return true
    }
    
    @State private var shouldAnimateFromLoad = false
    
    var transition: AnyTransition {
        switch viewModel.state {
        case .idle: .opacity
        case .loading: .opacity
        case .failed(_): .reveal
        case .loaded(_): .reveal
        }
    }
    
    var body: some View {
        VStack(alignment: .center) {
            if verticalSizeClass != .compact {
                Text("Please consider giving a small contribution to support the future continuation and development of the app")
                    .lineLimit(nil)
                    .fixedSize(horizontal: !true, vertical: !false)
                    .padding(.bottom, 20)
            } else {
                Spacer()
                    .frame(height: 5)
            }
            
            ZStack {
                if shouldInitiate {
                    Button {
                        didInitiate = true
                    } label: {
                        Text("Start")
                    }
                    .buttonStyle(.capsule(.tint))
                    .frame(maxWidth: .infinity)
                    .hidden(viewModel.state == .loading && didInitiate)
                    .accessibilityHidden(viewModel.state == .loading && didInitiate)
                } else {
                    Group {
                        switch viewModel.state {
                        case .loading, .idle:
                            ProgressView()
                                .progressViewStyle(.circular)
                                .controlSize(.small)
                                .transition(.opacity)
                        case .failed(let error):
                            VStack {
                                if case let DonationError.response(errorObject) = error, errorObject.code == 501 {
                                    Text("Donations are not yet supported.")
                                } else {
                                    Text("Could not load donation options.")
                                }
                                
                                Text("Please try again at a later time")
                                    .foregroundStyle(.secondary)
                                    .font(.callout)
                            }
                        case .loaded(let localizedOptions):
                            DonationOptionsView(configuration: localizedOptions)
                                .transition(.reveal) // this is for switch change transition
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
//                    Color.clear
//                        .frame(width: 0, height: 0)
//                        .hidden()
//                        .accessibilityHidden(true)
                }
            }
            .task {
                switch viewModel.state {
                case .loading, .loaded(_):
                    break
                case .idle, .failed(_):
                    await viewModel.loadData()
                }
            }
            .animation(DonationAnimation.animation, value: [didInitiate ? "true" : "false", viewModel.state.description])
        }
        .donationViewFrame(value: [didInitiate ? "true" : "false", viewModel.state.description])
    }
}

enum DonationAnimation {
    static let animation: Animation = .snappy
}


struct DonationSkipInitiateKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var skipDonationInitiate: Bool {
        get { self[DonationSkipInitiateKey.self] }
        set { self[DonationSkipInitiateKey.self] = newValue }
    }
}


#Preview {
    var donate = DonationOptionsViewModel()
    
    return SettingsPreview {
        VStack {
            DonationInitial()
                
            DonationInitial()
                .environment(\.skipDonationInitiate, true)
        }
        .environment(AppState.preview)
        .environment(donate)
        .donationViewFrame()
        .padding()
        
        Button {
            Task {
                await donate.loadData()
            }
        } label: {
            Text("Reload preview")
        }
    }
    .frame(height: 400)
}

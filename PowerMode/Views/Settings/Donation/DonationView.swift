//
//  DonationView.swift
//  PowerMode
//
//  Created by Sake Salverda on 05/02/2024.
//

import SwiftUI

@Observable
class DonationOptionsViewModel {
    typealias LoadedObject = DonationOptions
    
    enum State: Equatable {
        case idle
        case loading
        case failed(Error)
        case loaded(LoadedObject)
        
        var description: String {
            switch self {
            case .idle:
                "idle"
            case .loading:
                "loading"
            case .failed(let error):
                "failed"
            case .loaded(let loadedObject):
                "loaded"
            }
        }
        
        static func == (lhs: State, rhs: State) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle):
                true
            case (.loading, .loading):
                true
            case (.failed(_), .failed(_)):
                true
            case (.loaded(_), .loaded(_)):
                true
            default:
                false
            }
        }
    }
    
    var state: State = .idle
    
    func loadData() async {
        state = .loading
        
        do {
            let locale = Locale.current.currency?.identifier ?? ""
            
            let apiEndpoint = "https://api.sakesalverda.nl/powermode/v2/donation/localize/\(locale)"
            
            guard let url = URL(string: apiEndpoint) else {
                throw DonationError.url
            }
            
            let (data, _) = try await URLSession.shared.data(from: url)
            
//            try await Task.sleep(for: .seconds(1))
            
            do {
                let decodedResponse = try JSONDecoder().decode(DonationOptions.self, from: data)
                
                state = .loaded(decodedResponse)
            } catch {
                let decodedError = try? JSONDecoder().decode(DonationErrorResponse.self, from: data)
                
                print(error)
                
                if let decodedError {
                    throw DonationError.response(decodedError.error)
                }
                
                throw error
            }
        } catch {
            state = .failed(error)
        }
    }
}

class DonationStateModel {
    enum State: Int, Codable {
        case processing = 0
        case success = 200
        case error = 500
        case notFound = 404
    }
}

/// This view requires the .environment(\.openURL) to be modified to handle additional actions
struct DonationView: View {
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @Environment(\.openURL) private var openURL
    
    @Environment(\.dismiss) private var dismiss
    
    @Environment(AppState.self) private var appState
    
    @Environment(DonationOptionsViewModel.self) private var viewModel
    
    var body: some View {
        VStack {
            if verticalSizeClass != .compact {
                HStack {
                    Text("Support the app")
                        .font(.headline.weight(.semibold))
                    
                    Spacer()
                }
            }
            
            VStack {
                switch appState.supportState {
                case .initial:
                    DonationInitial()
                        .conditional(Constants.isPreview) {
                            $0.environment(\.skipDonationInitiate, true)
                        }
                case .awaiting(let id):
                    DonationAwaitingPayment(for: id)
                        .donationViewFrame(value: viewModel.state)
                case .error(_):
                    DonationErrorView()
                    .donationViewFrame(value: viewModel.state)
                case .success(_):
                    DonationThanksView()
                        .donationViewFrame(value: viewModel.state)
                }
            }
        }
    }
}

struct DonationErrorView: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        VStack {
            Text("An error occured during the proccess")
            
            Button {
                appState.supportState = .initial
            } label: {
                Text("start again")
            }
        }
    }
}

extension View {
    func donationViewFrame() -> some View {
        donationViewFrame(value: false)
    }
    
    func donationViewFrame<T>(value: T? = nil) -> some View where T: Equatable {
        self.frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .padding(.horizontal)
            .background(alignment: .top) {
                GeometryReader { geometry in
                    ScrollView {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color(nsColor: .quaternarySystemFill))
                            .stroke(Color(nsColor: .separatorColor), lineWidth: 0.5)
                            .animation(DonationAnimation.animation, value: value)
                            .frame(height: geometry.size.height)
                    }
                }
            }
    }
}

fileprivate struct DonationSizeClassPreview<Content: View>: View {
    var content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 30) {
            content
            
            content
                .environment(\.horizontalSizeClass, .compact)
            
            content
                .environment(\.verticalSizeClass, .compact)
            
            content
                .environment(\.horizontalSizeClass, .compact)
                .environment(\.verticalSizeClass, .compact)
        }
    }
}

#Preview {
    SettingsPreview {
        DonationSizeClassPreview {
            DonationView()
        }
        .padding()
    }
    .environment(AppState.preview)
    .environment(DonationOptionsViewModel())
}

#Preview("Awaiting") {
    SettingsPreview {
        DonationAwaitingPayment(for: "testing")
            .donationViewFrame()
            .padding()
    }
    .environment(AppState.preview)
    .environment(DonationOptionsViewModel())
}

#Preview("Error") {
    SettingsPreview {
        DonationErrorView()
            .donationViewFrame()
            .padding()
    }
    .environment(AppState.preview)
    .environment(DonationOptionsViewModel())
}

#Preview("Success") {
    SettingsPreview {
        DonationThanksView()
            .donationViewFrame()
            .padding()
    }
    .environment(AppState.preview)
    .environment(DonationOptionsViewModel())
}

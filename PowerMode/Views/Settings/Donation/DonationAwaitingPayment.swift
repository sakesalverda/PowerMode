//
//  DonationAwaitingPayment.swift
//  PowerMode
//
//  Created by Sake Salverda on 12/02/2024.
//

import SwiftUI
import Walberg
import OSLog

extension Logger {
    static let donationStatus = Self(.main, "donate.status.load")
}

@Observable
class DonationAwaitingStatusViewModel {
    struct Response: Codable, Equatable {
        /// Internal identifier for the payment
        let id: String
        
        /// Current status of the process
        let status: Status
        
        enum Status: Int, Codable {
            /// Status indicating the process has no determinate outcome yet
            case processing = 0
            
            /// Status indicating the payment has been succesfully finalised and processed
            case success = 200
            
            /// Status indicating an error occured during the payment process for the given id
            case error = 500
            
            /// Status indicating there is or was no process for the given id
            case notFound = 404
        }
    }
    
    enum State: Equatable {
        case idle
        case loading
        case failed(DonationError)
        case loaded(Response)
    }
    
    var state: State = .idle
    
    var errorCount: Int = 0
    var successCount: Int = 0
    
    func loadData(id: String, withTriggering: Bool = true) async {
        state = .loading
        
        let time = Date.now
        
        do {
            let apiEndpoint = "https://api.sakesalverda.nl/powermode/donation/status/\(id)"
            
            guard let url = URL(string: apiEndpoint) else {
                Logger.donationStatus.warning("URL endpoint to obtain status is invalid")
                throw DonationError.url
            }
            
            let data: Data
            let decodedResponse: Response
            
            do {
                (data, _) = try await URLSession.shared.data(from: url)
            } catch {
                Logger.donationStatus.warning("Invalid session to obtain status")
                throw DonationError.session
            }
            
            do {
                decodedResponse = try JSONDecoder().decode(Response.self, from: data)
            } catch {
                Logger.donationStatus.warning("Response from status endpoint is invalid")
                throw DonationError.decoding
            }
            
            Task {
                let interval = time.timeIntervalSinceNow
                let duration = interval.magnitude > 0.2 ? nil : (0.2 - interval.magnitude)
                
                if let duration {
                    try await Task.sleep(for: .seconds(duration))
                }
                
                if withTriggering {
                    successCount += 1
                }
                
                state = .loaded(decodedResponse)
            }
        } catch let error as DonationError {
            Logger.donationStatus.error("Could not load status of donation \(error.localizedDescription, privacy: .public)")
            state = .failed(error)
            
            if withTriggering {
                errorCount += 1
            }
        } catch {}
    }
}

struct DonationAwaitingPayment: View {
    @Environment(AppState.self) private var appState
    
    @State private var viewModel = DonationAwaitingStatusViewModel()
    
    var donationTrackingId: String
    
    init(for donationTrackingId: String) {
        self.donationTrackingId = donationTrackingId
    }
    
    var body: some View {
        VStack(spacing: 10) {
            Text("We are currently processing your payment")
                .font(.title3.weight(.semibold))
            //                .fontWeight(.semibold)
            
            Text("If you have finished the payment process click the refresh status button")
                .foregroundStyle(.secondary)
            
            Text("If an error occured during the payment, we're sorry. Please click to cancel button to restart")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
            
            HStack {
                Spacer()
                
                Button {
                    guard viewModel.state != .loading else { return }
                    
                    Task {
                        await viewModel.loadData(id: donationTrackingId)
                    }
                } label: {
                    HStack {
                        // refresh button
                        ZStack {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                    .fontWeight(.semibold)
                                
                                Text("refresh status")
                            }
                            .hidden(viewModel.state == .loading)
                            
                            if viewModel.state == .loading {
                                ProgressView()
                                    .controlSize(.small)
                            }
                        }
                        .padding(7)
                        .background(.quaternary, in: RoundedRectangle(cornerRadius: 5))
                        
                        DisappearingView(after: Duration.seconds(3), trigger: $viewModel.errorCount, animation: .default) {
                            Text("Error")
                                .font(.footnote)
                        }
                        
                        DisappearingView(after: Duration.seconds(3), trigger: $viewModel.successCount, animation: .default) {
                            Text("Updated")
                                .font(.footnote)
                        }
                    }
                }
                .buttonStyle(.plain)
                .disabled(viewModel.state == .loading)
                
                Spacer()
                
                Button {
                    appState.supportState = .initial
                } label: {
                    Text("cancel")
                }
                .fixedSize()
                .frame(width: 0, alignment: .trailing)
                .lineLimit(1)
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .multilineTextAlignment(.center)
        .task {
            if viewModel.state == .idle {
                await viewModel.loadData(id: donationTrackingId, withTriggering: false)
            }
        }
        .onChange(of: viewModel.state) {
            switch viewModel.state {
            case .idle, .loading:
                break
            case .failed(let error):
                break
            case .loaded(let response):
                switch response.status {
                case .error:
                    appState.supportState = .error(donationTrackingId)
                case .notFound:
                    appState.supportState = .initial
                case .processing:
                    break
                case .success:
                    appState.supportState = .success(donationTrackingId)
                }
            }
        }
    }
}

#Preview {
    SettingsPreview {
        VStack {
            Group {
                DonationAwaitingPayment(for: "4754754354")
            }
        }
        .donationViewFrame()
        .padding()
    }
    .environment(AppState.preview)
}

//
//  SettingsHelperBlockView.swift
//  PowerMode
//
//  Created by Sake Salverda on 03/12/2023.
//

import Foundation
import SwiftUI
import ServiceManagement
import OSLog

struct SettingsHelperStateView: View {
    @Environment(AppState.self) private var appState
    
    var status: SMAppService.Status
    
    @State private var helperVersion: String? = nil
    
    @State private var installationError: Bool = false
    
    let retrieveInternval: TimeInterval = 5
    
    @MainActor
    private func updateHelperVersion() async {
        do {
            Logger.helperConnection.trace("Attempting to obtain helper version")
            helperVersion = try await appState.helper.withThrowingConnection { try? await $0.getVersion() }
        } catch {
            Logger.helperConnection.warning("Could not obtain version of helper")
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            switch status {
            case .notRegistered, .notFound:
                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Text("The helper application is not installed yet.")
                    }
                    
                    Text("To be able to change the energy modes the helper needs to be installed.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Spacer()
                    
                    Button("Install helper") {
                        Task {
                            let installed = await appState.helper.installHelper()
                            
                            if !installed {
                                print("Could not install helper from settings")
                                installationError = true
                            }
                        }
                    }
                    .buttonStyle(.capsule)
                }
            case .enabled:
                Text("You're all set, the helper is installed and running.")
                
                HStack {
                    Spacer()
                    
                    Button("Reinstall helper") {
                        Task {
                            let reinstalled = await appState.helper.reinstallHelper()
                            
                            if !reinstalled {
                                print("Could not reinstall helper from settings")
                                
                                installationError = true
                            }
                        }
                    }
                    
                    Button("Uninstall helper") {
                        Task {
                            let uninstalled = await appState.helper.uninstallHelper()
                            
                            if !uninstalled {
                                print("Could not uninstall helper from settings")
                            }
                        }
                    }
                }
                .tint(Color(nsColor: .controlColor))
                .buttonStyle(.capsule)
            case .requiresApproval:
                VStack(alignment: .leading, spacing: 3) {
                    Text("You're almost there, the helper is installed but needs approval in System Settings.")
                        .infoButton {
                            WhyPrivilegesSheet()
                        }
                    
                    Text("After approval it can take up to \(Int(retrieveInternval)) seconds for the app to recognise this.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .task {
                    repeat {
                        do {
                            try await Task.sleep(for: .seconds(retrieveInternval))
                            
                            appState.helper.updateStatus()
                        } catch {}
                    } while (appState.helper.status == .requiresApproval)
                }
                
                Button("Open System Settings") {
                    SMAppService.openSystemSettingsLoginItems()
                }
            @unknown default:
                Text("An error occured while obtaining the helper application status. Please try restarting or updating the app.")
            }
        }
        
        .alert(isPresented: $installationError) {
            Alert(title: Text("Could not install the helper"), message: Text("An error occurred while trying to install the helper"))
        }
        
        // this sets the content
        .frame(width: 350, alignment: .leading)
        
        // this allows for proper text wrapping
        .fixedSize(horizontal: false, vertical: true)
        
        // this sets the background width
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

extension SettingsHelperStateView {
    struct WhyPrivilegesSheet: View {
        var body: some View {
            SettingsSheet("Why does installing the helper require user approval?") {
                Text("The helper application requires approval in System Settings because the app needs to communicate with the ") + Text("pmset").fontDesign(.monospaced).foregroundStyle(.secondary) + Text(" terminal interface to change the energy mode.")
                
                Text("Making changes with the ") + Text("pmset").fontDesign(.monospaced).foregroundStyle(.secondary) + Text(" interface, requires user approval and therefore the helper application needs to be approved by the user.")
                
                Text("The helper application has been designed with the highest emphasis on security. The helper utilises the latest security techniques such as code signature verification and sandboxing, such that it can only perform what it is intended to.")
                    .foregroundStyle(.tertiary)
                
//                Link(destination: URL(string: "https://atwalberg.com/powermode/security")!, label: {
//                    Text("Learn more")
//                })
            }
        }
    }
}

#Preview {
    SettingsPreview {
        Form {
            Section {
                SettingsHelperStateView(status: .enabled)
            }
            
            Section {
                SettingsHelperStateView(status: .notFound)
            }
            
            Section {
                SettingsHelperStateView(status: .notRegistered)
            }
            
            Section {
                SettingsHelperStateView(status: .requiresApproval)
            }
            
            Section {
                SettingsHelperStateView(status: .init(rawValue: 10)!)
            }
        }
        .fixedSize()
        .environment(AppState())
    }
}

#Preview("WhyPrivelegesSheet") {
    SettingsHelperStateView.WhyPrivilegesSheet()
}

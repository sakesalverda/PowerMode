//
//  SettingsUpdateBlock.swift
//  PowerMode
//
//  Created by Sake Salverda on 23/01/2024.
//

import SwiftUI
import Sparkle

struct SettingsUpdateView: View {
    @State private var automaticallyCheckForUpdates: Bool
    @State private var automaticallyDownloadsUpdates: Bool
    
    @Preference(\.updateFeedString) var feedString
    
    var debugRelease: Bool {
        feedString != nil
    }
    
    private var updater: SPUUpdater?
    
    init(updater: SPUUpdater?) {
        self.updater = updater

        self.automaticallyCheckForUpdates = updater?.automaticallyChecksForUpdates ?? false
        
        self.automaticallyDownloadsUpdates = updater?.automaticallyDownloadsUpdates ?? false
    }
    
    init(autoCheck: Bool, autoDownload: Bool) {
        self.automaticallyCheckForUpdates = autoCheck
        self.automaticallyDownloadsUpdates = autoDownload
    }
    
    // we do not know how the SPUUpdater works internally, likely it automatically disables automatically download updates when automatic checking is disabled
//    private var automaticallyDownloadsUpdatesBinding: Binding<Bool> {
//        Binding {
//            automaticallyDownloadsUpdates && automaticallyCheckForUpdates
//        } set: { newValue in
//            automaticallyDownloadsUpdates = newValue
//        }
//    }
    
    var body: some View {
        VStack {
            SettingsStandardItem(label: {
                VStack(alignment: .leading) {
                    Text("Automatically check for updates")
                    
                    if !automaticallyCheckForUpdates {
                        HStack(alignment: .center, spacing: 5) {
                            Image(systemName: "exclamationmark.shield.fill")
                            
                            Text("It is highly recommended to enable automatically checking for updates")
                        }
                        .settingsSubheadline()
                    }
                }
            }, binding: $automaticallyCheckForUpdates)
                .onChange(of: automaticallyCheckForUpdates) { _, newValue in
                    updater?.automaticallyChecksForUpdates = newValue
                }
            
            HStack {
                Spacer()
                
                if debugRelease {
                    Text("debug feed")
                        .font(.callout)
                        .foregroundStyle(.orange)
                }
                
                Button(action: {
                    updater?.checkForUpdates()
                }) {
                    Text("check for updates")
                }
            }
        }
        
        SettingsStandardItem(label: "Automatically download updates", binding: $automaticallyDownloadsUpdates)
            .disabled(!automaticallyCheckForUpdates)
            .onChange(of: automaticallyDownloadsUpdates) { _, newValue in
                updater?.automaticallyDownloadsUpdates = newValue
            }
    }
}

#Preview {
    SettingsPreview {
        Form {
            Section("Updates") {
                SettingsUpdateView(autoCheck: false, autoDownload: false)
            }
            
            Section("Updates") {
                SettingsUpdateView(autoCheck: true, autoDownload: false)
            }
            
            Section("Updates") {
                SettingsUpdateView(autoCheck: true, autoDownload: true)
            }
            
            Section("Updates") {
                SettingsUpdateView(autoCheck: false, autoDownload: true)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

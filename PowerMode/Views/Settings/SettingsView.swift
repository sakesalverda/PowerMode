//
//  SettingsView.swift
//  PowerMode
//
//  Created by Sake Salverda on 26/11/2023.
//

import SwiftUI
import LaunchAtLogin
import Sparkle

struct SettingsPreview<Content: View>: View {
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        VStack {
            ScrollView {
                content()
                    .formStyle(.grouped)
                    .frame(width: 440)
            }
            .frame(minHeight: 550)
        }
    }
}

enum SettingsGeometry {
    static let verticalSpacing: CGFloat = 28
}

struct SettingsPanel<Content: View>: View {
    var content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: SettingsGeometry.verticalSpacing) {
            content
        }
        .scenePadding()
    }
}

struct SettingsView: View {
    @Environment(\.scenePhase) private var scenePhase
    
    @Environment(AppState.self) private var appStateNew
    
    var updater: SPUUpdater?
    
    private enum Tabs: String, Hashable, CaseIterable {
        case general = "General", appearance = "Appearance", about = "About"
        case debug = "Debug"
    }
    
    @State private var tab: Tabs = .general
    
    @State private var viewModel = DonationOptionsViewModel()
    
    @State private var debugEnabled: Bool = false
    
    var body: some View {
        @Bindable var appState = appStateNew
        
        TabView(selection: $tab) {
            SettingsGeneralView(updater: updater)
                .tabItem {
                    Label(Tabs.general.rawValue, systemImage: "gearshape")
                }
                .tag(Tabs.general)
            
            SettingsAppearanceView()
                .tabItem {
                    Label(Tabs.appearance.rawValue, systemImage: "paintbrush.pointed.fill")
                }
                .tag(Tabs.appearance)
            
            
            SettingsPanel {
                SettingsAboutView(debugEnabled: $debugEnabled)
            }
            .tabItem {
                Label(Tabs.about.rawValue, systemImage: "info.circle")
            }
            .tag(Tabs.about)
            
            if debugEnabled {
                DebugSheet()
                    .fixedSize(horizontal: false, vertical: true)
                    .tabItem {
                        Label(Tabs.debug.rawValue, systemImage: "stethoscope")
//                        Label(Tabs.debug.rawValue, systemImage: "wrench.and.screwdriver")
                    }
                    .tag(Tabs.debug)
            }
        }
        .formStyle(.grouped)
        .environment(viewModel)
        
        #if DEBUG
        .onAppear {
            debugEnabled = true
        }
        #endif
        
        .frame(width: 440)
        .onChange(of: scenePhase) {
            // (1) @todo this is only called once in the actual application...
        }
        .onDisappear {
            // (1) @todo this is only called once in the actual application...
            // print("Appeared")
        }
        // (1) therefore we must use this instead
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.willCloseNotification)) { newValue in
            if let window = newValue.object as? NSWindow {
                let allCases = Tabs.allCases.map { t in t.rawValue }
                
                if allCases.contains(window.title) {
                    #if RELEASE
                    self.debugEnabled = false
                    #endif
                    
                    self.tab = .general
                    
                    // reset the loaded donation options
                    self.viewModel.state = .idle
                }
            }
        }
    }
}

#Preview {
    SettingsView(updater: nil)
        .environment(AppState())
}

//
//  WidgetBundle.swift
//  WidgetExtension
//
//  Created by Sake Salverda on 08/12/2023.
//

import WidgetKit
import SwiftUI

@main
struct PowerModeWidgetBundle: WidgetBundle {
    // read: Energy Mode
    // write: Energy Mode for a specific Power Source
    var body: some Widget {
        // display the current energy mode for a single power source
        ReadSingleSourceWidget()
        
        // display the current energy for multiple power sources
        ReadMultiSourceWidget()
        
        // toggle a single energy mode to a single power source
        // WriteSingleSourceWidget()
        
        // display and set the energy modes for a single power source
//        WriteSingleSourceWidget()
        
        // display and set the energy modes for multiple power sources
//        WriteMultiSourceWidget()
    }
}

protocol SharedEntry: TimelineEntry {
    var state: WidgetState { get }
}

private struct WidgetStateKey: EnvironmentKey {
    static let defaultValue: WidgetState = .placeholder
}

extension EnvironmentValues {
    var widgetState: WidgetState {
        get { self[WidgetStateKey.self] }
        set { self[WidgetStateKey.self] = newValue }
    }
    
    @MainActor var parentActive: Bool {
        get { self[WidgetStateKey.self].parentActive }
        set { self[WidgetStateKey.self].parentActive = newValue }
    }
}

//enum AppIconProvider {
//    static func appIcon(in bundle: Bundle = .main) -> String {
//        guard let icons = bundle.object(forInfoDictionaryKey: "CFBundleIcons") as? [String: Any],
//              let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
//              let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
//              let iconFileName = iconFiles.last else {
////            fatalError("Could not find icons in bundle")
//            return "mpty"
//        }
//
//        return iconFileName
//    }
//}

extension View {
    @ViewBuilder func managedWidget(entry: SharedEntry) -> some View {
        let isActive = entry.state.parentActive
        
        var transition: AnyTransition {
            .asymmetric(insertion:
                    .move(edge: .bottom).combined(with: .opacity).combined(with: .scale(scale: 0.9)),
                        removal:
                    .opacity.combined(with: .scale(scale: 0.6))
            )
        }
        
        self
            .redacted(reason: isActive ? [] : .placeholder)
            .environment(\.parentActive, isActive)
            .opacity(isActive ? 1 : 0.2)
            .overlay(alignment: .bottomLeading) {
                if !isActive {
                    VStack(alignment: .leading) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .foregroundStyle(.secondary)
                                .aspectRatio(1, contentMode: .fit)
                            
                            Image(systemName: "bolt.horizontal.fill")
                                .imageScale(.large)
                                .foregroundStyle(.white)
                        }
                        .frame(width: 40)
                        .id(isActive)
                        .transition(.asymmetric(insertion: .scale(scale: 0.6).combined(with: .opacity), removal: .opacity))
                    
                    Text("Please open the app to load energy mode data.")
                        .padding(.top)
                        .frame(maxWidth: 130, alignment: .leading)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                        .id(isActive)
                        .transition(transition)
                    }
                }
            }
    }
}

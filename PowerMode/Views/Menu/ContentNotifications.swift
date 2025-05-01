//
//  ContentNotificationsView.swift
//  PowerMode
//
//  Created by Sake Salverda on 23/01/2024.
//

import SwiftUI
import ServiceManagement
import ControlCenterExtra

struct ContentNotificationsView: View {
    @Environment(AppState.self) private var appState
    
    var helperState: SMAppService.Status {
        appState.helper.status
    }
    var helperRunning: Bool {
        appState.helper.isRunningWithHelper
    }
    
    var body: some View {
        _VariadicView.Tree(CustomVStackLayout()) {
            if appState.updateNotificationAvailable {
                Button(action: {
                    NotificationCenter.default.post(name: .openInstallUpdate, object: nil)
                }) {
                    Text("Update available")
                }
                .buttonStyle(.menuNotification(type: .info))
            }
            
            // only show warnings for the helper when the user's device supports energy modes
            if appState.device.isAnyPowerModeCapableDevice {
                if !helperRunning {
                    RunningWithoutHelperNotificationView(status: helperState)
                }
            }
        }
    }
    
    struct CustomVStackLayout: _VariadicView_MultiViewRoot {
        @ReadPreference(\.isAppleBatteryReplacement) private var isReplacement
        
        @Environment(\.controlSize) private var controlSize
        @ViewBuilder
        func body(children: _VariadicView.Children) -> some View {
            if children.count > 0 {
                VStack(spacing: 0) {
                    children
                }
                .padding(.top, MenuGeometry.menuItemSpacing)
                .padding(.bottom, isReplacement ? 4 : -4)
//                .padding(.top, children.count > 0 ? 4 : 0)
//                .padding(.bottom, children.count > 0 ? -4 : 0)
            }
        }
    }
}

#Preview {
    MenuPreview {
        MenuContent {
            MenuHeader("Demo Title", bottomContent: {
                Button(action: {
                    NotificationCenter.default.post(name: .openInstallUpdate, object: nil)
                }) {
                    Text("Update available")
                }
                .buttonStyle(.menuNotification(type: .info))
                
                Button(action: {
                    NotificationCenter.default.post(name: .openInstallUpdate, object: nil)
                }) {
                    Text("Issue with helper")
                }
                .buttonStyle(.menuNotification(type: .warning))
            })
            
            Text("Some item for here")
        }
    }
    .environment(AppState())
}

#Preview("Large") {
    MenuPreview {
        MenuContent {
            MenuHeader("Demo Title", bottomContent: {
                Button(action: {
                    NotificationCenter.default.post(name: .openInstallUpdate, object: nil)
                }) {
                    Text("Update available")
                }
                .buttonStyle(.menuNotification(type: .info))
                
                Button(action: {
                    NotificationCenter.default.post(name: .openInstallUpdate, object: nil)
                }) {
                    Text("Issue with helper")
                }
                .buttonStyle(.menuNotification(type: .warning))
            })
            .controlSize(.large)
            
            Text("Some item for here")
        }
    }
    .environment(AppState())
}

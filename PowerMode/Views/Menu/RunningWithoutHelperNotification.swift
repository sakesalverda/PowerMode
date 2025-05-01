//
//  RunningWithoutHelperNotification.swift
//  PowerMode
//
//  Created by Sake Salverda on 04/02/2024.
//

import SwiftUI
import ControlCenterExtra
import ServiceManagement

struct RunningWithoutHelperNotificationView: View {
    var status: SMAppService.Status
    
    private let issueString = "Issue with helper"
    
    var body: some View {
        Group {
            switch status {
            case .notRegistered:
                MenuSettingsLink {
                    Text("Helper not installed")
                }
            case .enabled:
                EmptyView()
            case .requiresApproval:
                MenuSettingsLink {
                    Text("Helper not installed")
                }
            case .notFound:
                MenuSettingsLink {
                    Text("Helper not installed")
                }
            @unknown default:
                EmptyView()
                    .onAppear {
                        // @todo Do some logging here
                    }
            }
        }
        .buttonStyle(.menuNotification(type: .warning))
        
//        if status == .notRegistered || status == .notFound {
//            CustomizedSettingsLink {
//                Text(issueString)
//            }
//            .buttonStyle(.menuNotification(type: .warning))
//        } else if status == .requiresApproval {
//            CustomizedSettingsLink {
//                Text(issueString)
//            }
//            .buttonStyle(.menuNotification(type: .warning))
//        }
    }
}

#Preview {
    VStack {
        RunningWithoutHelperNotificationView(status: .enabled)
        
        RunningWithoutHelperNotificationView(status: .notFound)
        
        RunningWithoutHelperNotificationView(status: .notRegistered)
        
        RunningWithoutHelperNotificationView(status: .requiresApproval)
    }
    .frame(width: Constants.menuWindowWidth)
}

//
//  trackingFix.swift
//  This fix ensures that the Menu Bar remains visible in full screen when the menu was opened
//  This relies on the appearManagedFix!
//
//  Created by Sake Salverda on 30/03/2024.
//

import SwiftUI

fileprivate struct TrackingFixModifier: ViewModifier {
//    var menuDelegate: ControlCenterMenuDelegate?
//    @Environment(\.isMenuPresented) private var isMenuPresented
//    @Environment(\.scenePhase) private var scenePhase
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                DistributedNotificationCenter.default().post(name: .beginMenuTracking, object: nil)
            }
            .onDisappear {
                DistributedNotificationCenter.default().post(name: .endMenuTracking, object: nil)
            }
    }
}

extension View {
    func trackingFix() -> some View {
        modifier(TrackingFixModifier())
    }
}

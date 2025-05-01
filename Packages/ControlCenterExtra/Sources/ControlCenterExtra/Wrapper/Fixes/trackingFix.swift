//
//  trackingFix.swift
//  This fix ensures that the Menu Bar remains visible in full screen when the menu was opened
//  This relies on the appearManagedFix!
//
//  Created by Sake Salverda on 30/03/2024.
//

import SwiftUI

fileprivate struct TrackingFixModifier: ViewModifier {
    var menuDelegate: ControlCenterMenuDelegate?
//    @Environment(\.isMenuPresented) private var isMenuPresented
//    @Environment(\.scenePhase) private var scenePhase
    
    func body(content: Content) -> some View {
        content
//            .onChange(of: scenePhase) { oldValue, newValue in
//                print("SCENE PHASE CHANGE")
//            }
            .onChange(of: menuDelegate?.isPresented) { oldValue, newValue in
            if oldValue == newValue { return }
            print(oldValue, newValue)
            if newValue == true {
                print("STARTING MENU TRACKING")
                DistributedNotificationCenter.default().post(name: .beginMenuTracking, object: nil)
            } else {
                print("ENDING MENU TRACKING")
                DistributedNotificationCenter.default().post(name: .endMenuTracking, object: nil)
            }
        }
    }
}

extension View {
    func trackingFix(menuDelegate: ControlCenterMenuDelegate) -> some View {
        modifier(TrackingFixModifier(menuDelegate: menuDelegate))
    }
}

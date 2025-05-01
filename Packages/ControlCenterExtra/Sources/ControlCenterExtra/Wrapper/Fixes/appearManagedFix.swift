//
//  appearManagedFix.swift
//  This fix manages the scene phase within the menu, the scene phase is `active` when opened
//  and `background` when hidden
//
//  Created by Sake Salverda on 30/03/2024.
//

import SwiftUI

extension View {
    func appearManagedFix() -> some View {
        modifier(AppearManagedModifier())
    }
}

/// Modifier to handle the scene phases in the window, and at some point the appear/dissapear
fileprivate struct AppearManagedModifier: ViewModifier {
    @Environment(\.isMenuPresented) private var isMenuPresented
    
    func body(content: Content) -> some View {
        Group {
            content
//            if isMenuPresented {
//                content
//            } else {
//                content.hidden()
//            }
        }
        .environment(\.scenePhase, isMenuPresented ? .active : .background)
    }
}

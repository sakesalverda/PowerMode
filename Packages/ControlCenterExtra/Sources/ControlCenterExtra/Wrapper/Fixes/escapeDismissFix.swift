//
//  escapeDismissFix.swift
//  This fix adds the ability to dismiss the menu by pressing the escape button
//  or with a `cancel` action
//
//
//  Created by Sake Salverda on 31/03/2024.
//

import SwiftUI
import Walberg

struct DismissOnEscapeFixModifier: ViewModifier {
    @Environment(\.dismissMenu) var dismissMenu
    
    func body(content: Content) -> some View {
        content
            .globalKeyboardShortcut(.cancelAction) { dismissMenu() }
    }
}

extension View {
    func dismissOnEscapeFix() -> some View {
        modifier(DismissOnEscapeFixModifier())
    }
}

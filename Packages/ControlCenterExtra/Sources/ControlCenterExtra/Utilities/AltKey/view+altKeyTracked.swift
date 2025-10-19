//
//  SwiftUIView.swift
//  
//
//  Created by Sake Salverda on 18/01/2024.
//

import SwiftUI

extension View {
    func altKeyTracked() -> some View {
        modifier(AltTrackedModifier())
    }
}

struct AltTrackedModifier: ViewModifier {
    @Environment(\.scenePhase) private var scenePhase
    
    @Environment(\.isMenuPresented) private var isMenuPresented
    
    @State private var altKeyManager: AltKeyManager = .init()
    
    func body(content: Content) -> some View {
        content
            .environment(\.isAltKeyPressed, altKeyManager.isAltKeyPressed)

            .onAppear {
                print("OBSERVING START")
                altKeyManager.startObserving()
            }
        
            .onDisappear {
                print("OBSERVING STOP")
                altKeyManager.stopObserving()
            }
//            .onChange(of: isMenuPresented, initial: true) { _, newValue in
//                if isMenuPresented == true {
//                    altKeyManager.startObserving()
//                } else {
//                    altKeyManager.stopObserving()
//                }
//            }
    }
}

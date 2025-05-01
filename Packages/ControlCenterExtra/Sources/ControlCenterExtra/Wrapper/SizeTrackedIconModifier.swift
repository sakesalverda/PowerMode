//
//  SizeTrackedIconModifier.swift
//  
//
//  Created by Sake Salverda on 25/03/2024.
//

import SwiftUI
import Combine

struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) { value = nextValue() }
}

//struct IconForegroundFixModifier: ViewModifier {
//    @Environment(\.isMenuPresented) var isMenuPresented
//    
//    func body(content: Content) -> some View {
//        content
//            .conditional(isMenuPresented) {
//                $0.foregroundStyle(.white)
//            }
//    }
//}

struct SizeTrackedIconModifier: ViewModifier {
    var menuDelegate: ImageDelegateIsPresentedDelegate
    
    var sizePassthrough: PassthroughSubject<(CGSize, Bool), Never>
    
    @State var sizeAnimation = WindowSizeAnimation()
    
    func body(content: Content) -> some View {
        // NOTE: there must not be any if statements in this code (or conditionals that use if statements)
        
        content
            .offset(y: -1) // don't know why this is necessary but the NSStatusItem subviews seem to be placed 1 pt down
        
            .fixedSize()
        
            .padding(.horizontal, MenuGeometry.iconHorizontalInset)
        
            .foregroundStyle(menuDelegate.isPresented ? .white : .primary)
        
            .environment(\.isMenuPresented, menuDelegate.isPresented)
        
            .overlay(
                GeometryReader { geometryProxy in
                    Color.clear
                        .windowSizeAnimationHandler(geometry: geometryProxy)
                        .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
                }
            )
            .onPreferenceChange(SizePreferenceKey.self, perform: { size in
                sizePassthrough.send((size, !sizeAnimation.isPrevented))
            })
            .environment(\._controlCenterWindowSizeAnimation, sizeAnimation)
    }
}

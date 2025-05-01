//
//  WindowSizeAnimation.swift
//  PowerMode
//
//  Created by Sake Salverda on 17/01/2024.
//

import SwiftUI
import MenuBarExtraAccess
import RegexBuilder

// provide an anchor somewhere with .windowSizeAnimationAnchor()
//
// then use either
// .windowSizeAnimation { newSize, useAnimation in ... }
//
// or
//
// .windowContentResizeAnimated()


fileprivate struct AnimatableWindowSizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize? = nil

    static func reduce(value: inout CGSize?, nextValue: () -> CGSize?) {
        let otherSize = nextValue()
        
        // some weird bug where an if statement causes the value to become nil, so we should check for it
        if otherSize == nil || otherSize == .zero {
            return
        }
        
        value = otherSize
    }
}

@Observable
class WindowSizeAnimation {
    var isPrevented: Bool = false
}

struct WindowSizeAnimationPreventedKey: EnvironmentKey {
    static let defaultValue: WindowSizeAnimation? = nil
}

extension EnvironmentValues {
    var _controlCenterWindowSizeAnimation: WindowSizeAnimation? {
        get { self[WindowSizeAnimationPreventedKey.self] }
        set { self[WindowSizeAnimationPreventedKey.self] = newValue }
    }
}

struct WindowSizeAnimationHandlerModifier: ViewModifier {
    @Environment(\._controlCenterWindowSizeAnimation) private var isAnimationPrevented
    
    var geometry: GeometryProxy
    
    func body(content: Content) -> some View {
        content.transaction(value: geometry.size) { transaction in
            let duration = Reference<Substring>()
            
            let reg = Regex {
                "duration:"
                
                CharacterClass(.whitespace)
                
                Capture(as: duration) {
                    OneOrMore(.digit)
                    "."
                    OneOrMore(.digit)
                }
            }

            var shouldPreventAnimation: Bool {
                if transaction.disablesAnimations {
                    return true
                } else if transaction.animation == nil {
                    return true
                } else if let str = transaction.animation?.description,
                         let matched = str.firstMatch(of: reg)?[duration],
                          let numeric = NumberFormatter().number(from: str) {
                    if numeric.floatValue <= 0.05 {
                        return true
                    }
                }
                
                return false
            }
            
//            print(shouldPreventAnimation)
            
            isAnimationPrevented?.isPrevented = shouldPreventAnimation
        }
    }
}

extension View {
    func windowSizeAnimationHandler(geometry: GeometryProxy) -> some View {
        modifier(WindowSizeAnimationHandlerModifier(geometry: geometry))
    }
}

fileprivate struct WindowSizeAnimationAnchorModifier: ViewModifier {
    @Environment(\._controlCenterWindowSizeAnimation) private var isAltKeyAnimationPrevented
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .windowSizeAnimationHandler(geometry: geometry)
                        .preference(key: AnimatableWindowSizePreferenceKey.self, value: geometry.size)
                }
            )
            // when not checking for == .zero in the reduce function, this does not work :) (Thank you SwiftUI)
            // only applies if there is an if statement somewhere in the view hierarchy, not per se only this view
//            .onPreferenceChange(AnimatableWindowSizePreferenceKey.self) { newSize in
//                print(newSize)
//            }
    }
}

extension View {
    /// Set the anchor that represents the height of the menu window
    func windowSizeAnimationAnchor() -> some View {
        modifier(WindowSizeAnimationAnchorModifier())
    }
}

fileprivate struct WindowHeightFixModifier: ViewModifier {
    @State private var controlCenterWindowSizeAnimation: WindowSizeAnimation = .init()
    
    var callback: (CGSize, Bool) -> Void
    
    func body(content: Content) -> some View {
        content
            .environment(\._controlCenterWindowSizeAnimation, controlCenterWindowSizeAnimation)
        
            .onPreferenceChange(AnimatableWindowSizePreferenceKey.self) { newSize in
                if let newSize = newSize {
                    callback(newSize, !controlCenterWindowSizeAnimation.isPrevented)
                }
            }
    }
}

extension View {
    func windowSizeAnimator(_ callback: @escaping (CGSize, Bool) -> Void) -> some View {
        modifier(WindowHeightFixModifier(callback: callback))
    }
}

extension View {
    func windowContentResizeAnimated() -> some View {
        modifier(WindowSizeAnimationModifier())
    }
}

struct WindowSizeAnimationModifier: ViewModifier {
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var controlCenterWindowSizeAnimation: WindowSizeAnimation = .init()
    
    @State private var heightAnimator: WindowHeightAnimator = .init()
    
    func body(content: Content) -> some View {
        content
            .environment(\._controlCenterWindowSizeAnimation, controlCenterWindowSizeAnimation)
        
            .introspectMenuBarExtraWindow { window in
                heightAnimator.contentWindowFrame = {
                    window.frame
                }
                heightAnimator.contentSizeUpdater = { newFrame in
//                    if controlCenterWindowSizeAnimation.isPrevented {
//                        window.animator().setFrame(newFrame, display: true, animate: false)
//                    } else {
                    window.animator().setFrame(newFrame, display: true, animate: true)
//                        window.animator().setFrame(newFrame, display: true, animate: true)
//                    }
                }
            }
        
            .onPreferenceChange(AnimatableWindowSizePreferenceKey.self, perform: { newSize in
                if let newSize = newSize {
                    let isAnimated = !controlCenterWindowSizeAnimation.isPrevented
                    
                    heightAnimator.updateContentSize(newSize, animated: isAnimated)
                }
            })
        
            // this is necessary due to an issue with Scrollview, when opening the window again the size is incorrect
            // in the MenuBarExtra view
            .onChange(of: scenePhase, initial: true) { _, newValue in
                if newValue == .active {
                    Task {
                        heightAnimator.restoreContentSize()
                    }
                }
            }
    }
}

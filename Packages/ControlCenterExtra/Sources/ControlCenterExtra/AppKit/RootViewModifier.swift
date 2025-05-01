//
//  RootViewModifier.swift
//  MemoryReleaseIssueDemo
//
//  Created by Sake Salverda on 18/01/2024.
//

import SwiftUI

struct RootViewSizeModifier: ViewModifier {
    @Environment(\.updateSize) private var updateSize
    
    @State private var controlCenterWindowSizeAnimation: WindowSizeAnimation = .init()
    
    func body(content: Content) -> some View {
        content
            .background {
                GeometryReader { geometry in
                    Color.clear
                        .windowSizeAnimationHandler(geometry: geometry)
                        .onAppear {
                            updateSize?(size: geometry.size)
                        }
                        .onChange(of: geometry.size) { _, newValue in
                            updateSize?(size: newValue, useAnimation: !controlCenterWindowSizeAnimation.isPrevented)
                        }
                }
            }
            .environment(\._controlCenterWindowSizeAnimation, controlCenterWindowSizeAnimation)
    }
}

extension View {
    func rootViewSizeTracker() -> some View {
        modifier(RootViewSizeModifier())
    }
}

struct RootView<Content: View>: View {
    @State private var scenePhase: ScenePhase = .background
    
    let windowTitle: String
    
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        ScrollView(.vertical) {
            MenuRoot {
                content()
            }
            
            .dismissOnEscapeFix()
            
            .rootViewSizeTracker()
            
            .altKeyTracked()
            
            .environment(\.scenePhase, scenePhase)
            .environment(\.isMenuPresented, scenePhase == .active)
        }
        .scrollIndicators(.never)
        .scrollBounceBehavior(.basedOnSize)
//        .background(.white.opacity(0.2))
//        .background(.thinMaterial)
//        .background(VisualEffectView(.windowBackground, blendingMode: .withinWindow).opacity(0.1))
        .edgesIgnoringSafeArea(.all)
        
        .frame(width: MenuGeometry.menuWindowWidth)
        .frame(minHeight: 0, maxHeight: .infinity, alignment: .top)
        
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.didBecomeKeyNotification)) { notification in
            guard let window = notification.object as? NSWindow, window.title == windowTitle, scenePhase != .active else {
                return
            }
            
            scenePhase = .active
        }
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.didResignKeyNotification)) { notification in
            guard let window = notification.object as? NSWindow, window.title == windowTitle, scenePhase != .background else {
                return
            }
            
            scenePhase = .background
        }
    }
}

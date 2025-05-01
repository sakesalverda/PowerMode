//
//  SwiftUIView.swift
//  
//
//  Created by Sake Salverda on 05/02/2024.
//

import SwiftUI

extension View {
    public func onReliablePress(_ isPressing: @escaping (Bool) -> Void, trigger: (() -> Void)? = nil) -> some View {
        modifier(MouseClickedInsideModifier(isPressing, trigger: trigger))
    }
    
    public func onReliablePress(binding: Binding<Bool>, trigger: (() -> Void)? = nil) -> some View {
        self.onReliablePress { isPressing in
            binding.wrappedValue = isPressing
        } trigger: { trigger?() }
    }
}

struct MouseClickedInsideModifier: ViewModifier {
    typealias Trigger = () -> Void
    
    @State private var isPressed: Bool = false
    
    @State private var rect: CGSize = .zero
    
    let mouseIsInside: (Bool) -> Void
    let trigger: Trigger?
    
    init(_ mouseIsInside: @escaping (Bool) -> Void, trigger: Trigger?) {
        self.mouseIsInside = mouseIsInside
        self.trigger = trigger
    }
    
    func body(content: Content) -> some View {
        content
            .background {
                GeometryReader { geometry in
                    Color.clear
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                        .onChange(of: geometry.size, initial: true) {
                            self.rect = geometry.size
                        }
                }
            }
            .gesture (
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { evt in
                        if evt.location.x < 0 ||
                            evt.location.y < 0 ||
                            evt.location.x > rect.width ||
                            evt.location.y > rect.height {
                            isPressed = false
                        } else {
                            isPressed = true
                        }
                    }
                    .onEnded { evt in
                        let loc = evt.location
                        
                        if loc.x >= 0 && loc.y >= 0 && loc.x <= rect.width && loc.y <= rect.height {
                            trigger?()
                        }
                        
                        isPressed = false
                    }
            )
            .onChange(of: isPressed) {
                mouseIsInside(isPressed)
            }
    }
}

#Preview {
    StatePreviewWrapper(false) { hovering in
        Text("Hoverable text")
            .padding(5)
            .background(.quaternary.opacity(hovering.wrappedValue ? 1 : 0))
            .onReliablePress(binding: hovering)
            .padding()
    }
}

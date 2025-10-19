//
//  SwiftUIView.swift
//  
//
//  Created by Sake Salverda on 05/02/2024.
//

import SwiftUI

// from https://stackoverflow.com/a/66430835/3711267
// as provided on: https://gist.github.com/importRyan/c668904b0c5442b80b6f38a980595031
extension View {
    public func onReliableHover(_ isHovering: @escaping (Bool) -> Void) -> some View {
        modifier(MouseInsideModifier(isHovering))
    }
    
    public func onReliableHover(binding: Binding<Bool>) -> some View {
        self.onReliableHover { isHovering in
            binding.wrappedValue = isHovering
        }
    }
}

struct MouseInsideModifier: ViewModifier {
    @Environment(\.isEnabled) private var isEnabled
    
    @State private var isHovered: Bool = false
    
    let mouseIsInside: (Bool) -> Void
    
    init(_ mouseIsInside: @escaping (Bool) -> Void) {
        self.mouseIsInside = mouseIsInside
    }
    
    func body(content: Content) -> some View {
        content
        // it appears the hovering glitches are fixed in macOS 26
//            .background(
//                GeometryReader { proxy in
//                    Representable(mouseIsInside: { hovering in
//                        self.isHovered = hovering
//                    },
//                  frame: proxy.frame(in: .global))
//                }
//            )
//            .onChange(of: isHovered, initial: true) {
//                mouseIsInside(isEnabled && isHovered)
//            }
            .onHover { isHovered in
                mouseIsInside(isEnabled && isHovered)
            }
            .onChange(of: isEnabled) {
                if isEnabled == false {
                    isHovered = false
                }
            }
    }
    
    private struct Representable: NSViewRepresentable {
        let mouseIsInside: (Bool) -> Void
        let frame: NSRect
        
        func makeCoordinator() -> Coordinator {
            let coordinator = Coordinator()
            coordinator.mouseIsInside = mouseIsInside
            return coordinator
        }
        
        class Coordinator: NSResponder {
            var mouseIsInside: ((Bool) -> Void)?
            
            override func mouseEntered(with event: NSEvent) {
                print("MOUSE entered")
                mouseIsInside?(true)
            }
            
            override func mouseExited(with event: NSEvent) {
                print("MOUSE leaved")
                mouseIsInside?(false)
            }
        }
        
        func makeNSView(context: Context) -> NSView {
            let frame_new = NSRect(origin: .init(x:1180, y: frame.origin.y), size: frame.size)
            
            let view = NSView(frame: frame_new)
            
            print("MOUSE makeNSView")
            
            let options: NSTrackingArea.Options = [
                .mouseEnteredAndExited,
//                .inVisibleRect,
                .activeAlways,
//                .activeInKeyWindow
            ]
            
            let trackingArea = NSTrackingArea(rect: frame_new,
                                              options: options,
                                              owner: context.coordinator,
                                              userInfo: nil)
            
            print("MOUSE makeNSView", frame)
            print("MOUSE makeNSView", frame_new)
            
            view.addTrackingArea(trackingArea)
            
            return view
        }
        
        func updateNSView(_ nsView: NSView, context: Context) {}
        
        static func dismantleNSView(_ nsView: NSView, coordinator: Coordinator) {
            nsView.trackingAreas.forEach { nsView.removeTrackingArea($0) }
        }
    }
}

#Preview {
    StatePreviewWrapper(false) { hovering in
        Text("Hoverable text")
            .padding(5)
            .background(.quaternary.opacity(hovering.wrappedValue ? 1 : 0))
            .onReliableHover(binding: hovering)
            .padding()
    }
}

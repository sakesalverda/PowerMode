//
//  Transition+reveal.swift
//
//
//  Created by Sake Salverda on 05/02/2024.
//

import SwiftUI

struct RevealTransitionModifier: ViewModifier {
    var isCollapsed: Bool
    
    var edge: Edge
    
    var edgeOffset: EdgeInsets
    
    private var horizontal: Bool {
        edge == .leading || edge == .trailing
    }
    
    private var vertical: Bool {
        edge == .top || edge == .bottom
    }
    
    private var alignment: Alignment {
        switch edge {
        case .top:
                .top
        case .leading:
                .leading
        case .bottom:
                .bottom
        case .trailing:
                .trailing
        }
    }
    
    private var reverseAlignment: Alignment {
        switch edge {
        case .top:
                .bottom
        case .leading:
                .trailing
        case .bottom:
                .top
        case .trailing:
                .leading
        }
    }
    
    func body(content: Content) -> some View {
//            content.overlay {
//                GeometryReader { geometry in
//                    ZStack(alignment: reverseAlignment) {
//                        Rectangle()
//                            .foregroundStyle(.black)
//                            .conditional(horizontal) {
//                                $0.frame(width: isCollapsed ? nil : 0)
//                            }
//                            .conditional(vertical) {
//                                $0.frame(height: isCollapsed ? nil : 0)
//                            }
//                            .clipped()
//                            .frame(width: geometry.size.width, height: geometry.size.height, alignment: reverseAlignment)
//                    }
//                }
//                .blendMode(.destinationOut)
//            }
//            .compositingGroup()
            
            content
                .mask(alignment: alignment) {
                    ZStack {
                        Rectangle()
                            .frame(
                                width: horizontal && isCollapsed ? 0 : nil,
                                height: vertical && isCollapsed ? 0 : nil,
                                alignment: alignment
                            )
                            .padding(edgeOffset)
                    }
                }
//        }
//        .compositingGroup()
    }
}

extension AnyTransition {
    /// A transition that reveals the view as if removing a table cloth from the top edge
    public static var reveal: AnyTransition {
        .reveal(from: .top)
    }
    
    /// A transition that reveals the view as if removing a table cloth from the given edge
    public static func reveal(from edge: Edge, with offset: CGFloat = 0) -> AnyTransition {
        .mask(from: edge, with: offset)
        .combined(with: .opacity)
    }
    
    /// A transition that reveals the view as if removing a table cloth from the given edge
    public static func reveal(from edge: Edge, with offset: EdgeInsets) -> AnyTransition {
        .mask(from: edge, with: offset)
        .combined(with: .opacity)
    }
    
    /// A transition that reveals the view as if removing a table cloth from the top edge
    public static var mask: AnyTransition {
        .mask(from: .top)
    }
    
    public static func mask(from edge: Edge, with offset: CGFloat = 0) -> AnyTransition {
        .mask(from: edge, with: .init(top: offset, leading: offset, bottom: offset, trailing: offset))
    }
    
    /// A transition that reveals the view as if removing a table cloth from the given edge
    public static func mask(from edge: Edge, with insets: EdgeInsets) -> AnyTransition {
        .modifier(
            active: RevealTransitionModifier(isCollapsed: true, edge: edge, edgeOffset: insets),
            identity: RevealTransitionModifier(isCollapsed: false, edge: edge, edgeOffset: insets)
        )
    }
}

public extension EdgeInsets {
    init(vertical: CGFloat = 0, horizontal: CGFloat = 0) {
        self.init(top: vertical, leading: horizontal, bottom: vertical, trailing: horizontal)
    }
}

#Preview("from: .top") {
    StatePreviewWrapper(true) { expanded in
        VStack {
            Button(action: {
                withAnimation(.easeInOut(duration: 2)) {
                    expanded.wrappedValue.toggle()
                }
            }) {
                Text("Toggle")
            }
            
            if expanded.wrappedValue {
                VStack {
                    Text("Lorem ipsum dolar")
                    Text("consectetur adipiscing elit, sed")
                    Color.red.frame(height: 40)
                    Text("do eiusmod tempor incididunt")
                }
                .transition(.reveal)
            }
            
            Divider()
            
            Text("ut labore et dolore magna aliqua")
            
            Spacer()
        }
    }
    .frame(width: 200)
    .padding()
}

#Preview("from: .leading") {
    StatePreviewWrapper(true) { expanded in
        VStack {
            Button(action: {
                withAnimation(.easeInOut(duration: 2)) {
                    expanded.wrappedValue.toggle()
                }
            }) {
                Text("Toggle")
            }
            
            HStack {
                if expanded.wrappedValue {
                    VStack {
                        Text("Lorem ipsum")
                        Text("dolar elit, sed")
                        Color.red.frame(height: 40)
                        Text("do eiusmod tempor incididunt")
                    }
                    .transition(.reveal(from: .leading))
                }
                
                Divider()
                
                Color.blue
            }
            
            Spacer()
        }
    }
    .frame(width: 200)
    .padding()
}

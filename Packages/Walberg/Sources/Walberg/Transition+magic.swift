//
//  Transition+insertion.swift
//  
//
//  Created by Sake Salverda on 12/02/2024.
//

import SwiftUI

struct ContentTransitionModifier: ViewModifier {
    var isInserted: Bool
    
    var edge: Edge
    
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
    
    func body(content: Content) -> some View {
        content
            .visualEffect { content, geometryProxy in
                content.offset(x: horizontal && !isInserted ? (geometryProxy.size.width / 2 * (edge == .leading ? -1 : 1)) : 0,
                               y: vertical && !isInserted ? (geometryProxy.size.height / 2 * (edge == .top ? 1 : -1)) : 0)
            }
    }
}

public extension AnyTransition {
    /// A transition that appears to insert the view the trailing edge
    public static var magic: AnyTransition {
        .magic(insertion: .trailing)
    }
    
    /// A transition that appears to insert the view at the given edge
    public static func magic(insertion edge: Edge) -> AnyTransition {
        .modifier(
            active: ContentTransitionModifier(isInserted: false, edge: edge),
            identity: ContentTransitionModifier(isInserted: true, edge: edge)
        )
        .combined(with: .opacity)
    }
}


#Preview {
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
                    .transition(.magic(insertion: .leading))
                }
                
                Divider()
                
                Color.blue
            }
            .contentTransition(.identity)
            
            Spacer()
        }
    }
    .frame(width: 200)
    .padding()
}

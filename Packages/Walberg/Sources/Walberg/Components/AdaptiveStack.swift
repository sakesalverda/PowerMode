//
//  SwiftUIView.swift
//  
//
//  Created by Sake Salverda on 05/02/2024.
//

import SwiftUI

struct AdaptiveStackKey: EnvironmentKey {
    static let defaultValue: AdaptiveDirection = .vertical
}

extension EnvironmentValues {
    public var adaptiveStackDirection: AdaptiveDirection {
        get { self[AdaptiveStackKey.self] }
        set { self[AdaptiveStackKey.self] = newValue }
    }
}

public enum AdaptiveDirection {
    case vertical
    case horizontal
}

public struct AdaptiveStack<Content: View>: View {
    @Environment(\.adaptiveStackDirection) private var adaptiveStackDirection
    
    let direction: AdaptiveDirection?
    let horizontalAlignment: HorizontalAlignment
    let verticalAlignment: VerticalAlignment
    let horizontalSpacing: CGFloat?
    let verticalSpacing: CGFloat?
    let content: Content
    
    public init(direction: AdaptiveDirection? = nil, horizontalAlignment: HorizontalAlignment = .center, verticalAlignment: VerticalAlignment = .center, horizontalSpacing: CGFloat? = nil, verticalSpacing: CGFloat? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.direction = direction
        self.horizontalAlignment = horizontalAlignment
        self.verticalAlignment = verticalAlignment
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
        self.content = content()
    }
    
    public var body: some View {
        if direction == .horizontal || (direction == nil && adaptiveStackDirection == .horizontal) {
            HStack(alignment: verticalAlignment, spacing: horizontalSpacing) {
                content
            }
        } else {
            VStack(alignment: horizontalAlignment, spacing: verticalSpacing) {
                content
            }
        }
    }
}

extension AdaptiveStack {
    // singular spacing
    public init(horizontalAlignment: HorizontalAlignment = .center, verticalAlignment: VerticalAlignment = .center, spacing: CGFloat? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.init(horizontalAlignment: horizontalAlignment, verticalAlignment: verticalAlignment, horizontalSpacing: spacing, verticalSpacing: spacing, content: content)
    }
    
    // singular alignment
    public init(alignment: Alignment, spacing: CGFloat? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.init(horizontalAlignment: alignment.horizontal, verticalAlignment: alignment.vertical, horizontalSpacing: spacing, verticalSpacing: spacing, content: content)
    }
    
    // singular alignment and spacing
    public init(alignment: Alignment, horizontalSpacing: CGFloat? = nil, verticalSpacing: CGFloat? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.init(horizontalAlignment: alignment.horizontal, verticalAlignment: alignment.vertical, horizontalSpacing: horizontalSpacing, verticalSpacing: verticalSpacing, content: content)
    }
}

#Preview {
    VStack {
        Group {
            AdaptiveStack {
                Text("Item 1")
                
                Text("Item 2")
            }
            
            // forced direction overwrites the environment direction
            AdaptiveStack(direction: .vertical, horizontalAlignment: .leading) {
                Text("Item 1 some")
                
                Text("Item 2")
            }
            .environment(\.adaptiveStackDirection, .horizontal)
            
            AdaptiveStack {
                Text("Item 1")
                
                Text("Item 2")
            }
            .environment(\.adaptiveStackDirection, .horizontal)
        }
        .padding()
    }
}

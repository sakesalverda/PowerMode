//
//  MenuDivider.swift
//  PowerMode
//
//  Created by Sake Salverda on 16/01/2024.
//

import SwiftUI

/// The factor to which the inset the view is to be placed
public enum ReduceFactor: CGFloat {
    /// The inset value for the content of a menu item
    case content
    
    /// The inset value for a highlight effect of a menu item
    case highlight
    
    /// The inset value for the edge of the window
    case edge
}

/// Edge to apply the new inset to
public enum ReduceEdge {
    /// Edge that modifies the leading and trailing inset
    case horizontal
    case top
    case bottom
}

/// Collection of edges and their insets
struct ReducedInset {
    var horizontal: ReduceFactor = .edge
    var top: ReduceFactor = .edge
    var bottom: ReduceFactor = .edge
}

struct ReducedInsetKey: EnvironmentKey {
    static let defaultValue: ReducedInset = .init()
}

// this is an initial implementation for supporting ticked menu items which shift all the insets
// TODO: if there are tickable items, how do we want to deal with the insets, for large buttons?
struct IncreasedContentInsetKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var reducedInset: ReducedInset {
        get { self[ReducedInsetKey.self] }
        set { self[ReducedInsetKey.self] = newValue }
    }
    
    var menubarIncreasedContentInset: Bool {
        get { self[IncreasedContentInsetKey.self] }
        set { self[IncreasedContentInsetKey.self] = newValue }
    }
}

struct InsetModifier: ViewModifier {
    @Environment(\.menubarIncreasedContentInset) private var increasedContentInset
    @Environment(\.reducedInset) private var reducedInset
    
    var edges: ReduceEdge
    var to: ReduceFactor
    
    private let horizontalInset = MenuGeometry.menuHorizontalContentInset
    
    private var updateValue: CGFloat {
        let menuHighlightInset = MenuGeometry.menuHorizontalHighlightInset
        let menuContentInset: CGFloat
        
        if edges == .horizontal {
            menuContentInset = MenuGeometry.menuHorizontalContentInset
        } else {
            // TODO: correct padding
            menuContentInset = MenuGeometry.menuHorizontalContentInset
//            menuContentInset = ControlCenterGeometry.menuItemPadding
        }
        
        let currentFactor: ReduceFactor
        let desiredFactor = to
        
        let currentInset: CGFloat
        let desiredInset: CGFloat
        
        // get applicable edge
        switch edges {
        case .horizontal:
            currentFactor = reducedInset.horizontal
        case .top:
            currentFactor = reducedInset.top
        case .bottom:
            currentFactor = reducedInset.bottom
        }
        
        // get current inset as CGFloat
        switch currentFactor {
//        case .toggle:
//            currentInset = menuContentInset
        case .content:
//            if increasedContentInset {
//                currentInset = menuContentInset + 12
//            } else {
                currentInset = menuContentInset
//            }
        case .highlight:
            currentInset = menuHighlightInset
        case .edge:
            currentInset = 0
        }
        
        // get desired as CGFloat
        switch desiredFactor {
//        case .toggle:
//            desiredInset = menuContentInset
        case .content:
//            if increasedContentInset {
//                desiredInset = menuContentInset + 12
//            } else {
                desiredInset = menuContentInset
//            }
        case .highlight:
            desiredInset = menuHighlightInset
        case .edge:
            desiredInset = 0
        }
        
        return desiredInset - currentInset
    }
    
    private var updateEdges: Edge.Set {
        switch edges {
        case .horizontal:
            .horizontal
        case .top:
            .top
        case .bottom:
            .bottom
        }
    }
    
    private var updatedInsets: ReducedInset {
        var newInsets = reducedInset
        
        switch edges {
        case .horizontal:
            newInsets.horizontal = to
        case .top:
            newInsets.top = to
        case .bottom:
            newInsets.bottom = to
        }
        
        return newInsets
    }
    
    func body(content: Content) -> some View {
        content
            .environment(\.reducedInset, updatedInsets)
            .padding(updateEdges, updateValue)
    }
}

public extension View {
    func menuInset(_ dictionary: [ReduceEdge: ReduceFactor]) -> some View {
        self // TODO!
    }
    
    func menuInset(_ edges: ReduceEdge, to reduceTo: ReduceFactor) -> some View {
        return modifier(InsetModifier(edges: edges, to: reduceTo))
    }
}

#Preview {
    MenuPreview {
        VStack {
            Divider()
                .menuInset(.horizontal, to: .content)
            
            Divider()
                .menuInset(.horizontal, to: .highlight)
            
            Divider()
                .menuInset(.horizontal, to: .edge)
        }
        
        VStack(alignment: .leading, spacing: 0) {
            Text("Item 1")
                .menuInset(.horizontal, to: .content)
            
            Text("Item 2")
                .menuInset(.horizontal, to: .highlight)
            
            Text("Item 3")
                .menuInset(.horizontal, to: .edge)
            
            Button("Button 1") {}
            
            Button("Button 2") {}
            
            Button("Button 3") {}
            
            Toggle("Toggle 1", isOn: .constant(true))
            
            Toggle("Toggle 1", isOn: .constant(false))
            
            HStack {
                Spacer()
            }
        }
        .toggleStyle(.controlCenterTick)
        .buttonStyle(.controlCenter)
        
        VStack {
            Toggle("Toggle 1", systemImage: "bolt.fill", isOn: .constant(true))
            
            Toggle("Toggle 1", systemImage: "bolt.fill", isOn: .constant(false))
        }
        .toggleStyle(.controlCenterTick)
        .controlSize(.large)
    }
}

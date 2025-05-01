//
//  ControlCenterContent.swift
//  PowerMode
//
//  Created by Sake Salverda on 17/01/2024.
//

import SwiftUI

// MARK: Collapse

fileprivate struct CollapsableGroupTag: _ViewTraitKey {
    static var defaultValue: Bool = false
}

fileprivate enum CollapseState {
    case collapsed
    case expanded
    
    static let `default`: Self = .expanded
}

fileprivate struct CollapsableStateTag: _ViewTraitKey {
    static var defaultValue: CollapseState = .default
}

extension View {
    public func menuCollapseToGroup() -> some View {
        _trait(CollapsableGroupTag.self, true)
    }
    
    public func menuDisclosureState(isExpanded: Bool) -> some View {
        _trait(CollapsableStateTag.self, isExpanded ? .expanded : .collapsed)
    }
    
//    public func menuCollapsed(_ newValue: Bool = true) -> some View {
//        _trait(CollapsableStateTag.self, newValue ? .collapsed : .expanded)
//    }
}

fileprivate struct ContentLevelTag: _ViewTraitKey {
    static var defaultValue: MenuContentElevation = .default
}

public struct MenuRoot<Content: View>: View {
    private var content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        VStack(spacing: MenuGeometry.menuItemSpacing) {
            _VariadicView.Tree(DividedLayout()) {
                content
            }
        }
        .buttonStyle(.controlCenter)
        .toggleStyle(.controlCenter)
        .disclosureGroupStyle(.controlCenter)
        
        .menuInset(.horizontal, to: .content)
        .menuInset(.top, to: .content)
        .menuInset(.bottom, to: .highlight)
        
        .frame(width: MenuGeometry.menuWindowWidth, alignment: .top)
    }
}

public enum MenuContentElevation {
    case highlighted
    case `default`
}

public struct MenuContent<Content: View>: View {
    private let content: Content
    
    private var level: MenuContentElevation = .default
    
    public init(_ level: MenuContentElevation, @ViewBuilder content: () -> Content) {
        self.level = level
        self.content = content()
    }
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public func setLevel(to newLevel: MenuContentElevation) -> Self {
        var v = self
        v.level = .highlighted
        
        return v
    }

    public var body: some View {
        VStack(spacing: MenuGeometry.menuItemSpacing) {
            _VariadicView.Tree(DividedLayout()) {
                content
            }
        }
        ._trait(ContentLevelTag.self, level)
        .conditional(level == .highlighted) {
            $0.background {
                Color.primary
                    .opacity(0.1)
                    .padding(.vertical, -4)
                    .menuInset(.horizontal, to: .edge)
            }
        }
    }
}

#Preview {
    MenuContent {
        Section("Test") {
            Text("Content")
        }
    }
}

fileprivate  struct DividedLayout: _VariadicView_MultiViewRoot {
    @ViewBuilder func body(children: _VariadicView.Children) -> some View {
        let first = children.first?.id
        let last = children.last?.id
        
        let count = children.count

        ForEach(0..<count, id: \.self) { index in
            let child = children[index]

            let isForGroup = child[CollapsableGroupTag.self]
            let isCollapsed = child[CollapsableStateTag.self] == .collapsed
            
            let isFirst = (child.id == first)
            let isLast = (child.id == last)
            
//            let _ = print(child)
            
            var isElevatedContainer: Bool {
                if child[ContentLevelTag.self] == .highlighted {
                    return true
                }
                
                if !isLast,
                   children[index+1][ContentLevelTag.self] == .highlighted {
                    return true
                }
                
                return false
            }
            
            Group {
                child
                    .padding(.bottom, isForGroup && isCollapsed && !isLast ? -(2 * MenuGeometry.menuItemSpacing + 1) : 0)
                    .zIndex(5)
                
                if !isLast {
                    Divider()
                        .opacity(isForGroup && isCollapsed ? 0 : 1)
                        .zIndex(0)
                        // since we place the divider after each element, we check here whether this item, or the next item
                        // is elevated, such that we properly adjust the inset of the divider
                        .menuInset(.horizontal, to: isElevatedContainer ? .edge : .content)
                }
            }
        }
    }
}

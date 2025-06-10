//
//  ControlCenterSection.swift
//  PowerMode
//
//  Created by Sake Salverda on 17/01/2024.
//

import SwiftUI
//
//extension MenuCollapsableSection {
//    public func hideDividerOnCollapse(_ hideOnCollapse: Bool = true) -> Self {
//        var t = self
//        
//        t.hideDividerOnCollapse = hideOnCollapse
//        
//        return t
//    }
//}
//
public struct MenuSection<Content: View, Label: View>: View {
    private var label: Label? = nil
    
    private var content: () -> Content
    
    public init(@ViewBuilder content: @escaping() -> Content) where Label == EmptyView {
        self.label = nil
        self.content = content
    }
    
    public init(_ title: String? = nil, @ViewBuilder content: @escaping() -> Content) where Label == Text {
        if let title {
            self.label = Text(title)
        } else {
            self.label = nil
        }
        
        self.content = content
    }
    
    public init(@ViewBuilder content: @escaping() -> Content, @ViewBuilder label: () -> Label) {
        self.label = label()
        self.content = content
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            if let label = label {
                HStack {
                    if #unavailable(macOS 26) {
                        label
                            .font(.callout.weight(.semibold))
                            .foregroundStyle(.secondary)
                    } else {
                        label
                            .font(.callout.weight(.semibold))
                            .foregroundStyle(.primary) // @todo: not the correct tinting
                    }
//                        .blendMode(.sourceAtop)
                    
                    Spacer()
                }
                .padding(.vertical, 3)
//                .padding(.horizontal, MenuGeometry.menuHorizontalContentInset)
            }
            
            VStack(spacing: 0, content: content)
        }
    }
}
//
//public struct MenuCollapsableSection<Title: View, Content: View>: View {
//    private var title: Title
//    private var content: () -> Content
//    
//    public init(_ title: String, @ViewBuilder content: @escaping () -> Content) where Title == Text {
//        self.title = Text(title)
//        self.content = content
//    }
//    
//    public init(_ title: () -> Title, @ViewBuilder content: @escaping () -> Content) {
//        self.title = title()
//        self.content = content
//    }
//    
//    
//    private var hideDividerOnCollapse: Bool = false
//    
//    @State private var expanded: Bool = true
//    
//    public var body: some View {
//        VStack(spacing: 0) {
//            // MARK: header
//            Button(action: {
//                withAnimation(.spring(Spring(settlingDuration: 0.5, dampingRatio: 0.8))) {
//                    expanded.toggle()
//                }
//            }) {
//                HStack {
//                    title
//                        .font(.callout.weight(.semibold))
//                        .foregroundStyle(.secondary)
//                    
//                    Spacer()
//                    
//                    // chevron icon
//                    // use a zstack to ensure no frame size changes when switching between the icons
//                    // alternatively we could just set a fixed frame size
//                    ZStack {
//                        Image(systemName: "chevron.down")
//                            .hidden(!expanded)
//                        
//                        Image(systemName: "chevron.right")
//                            .hidden(expanded)
//                    }
//                    .font(.callout)
//                }
//            }
//            .zIndex(10)
//            
//            // MARK: Content
//            if expanded {
//                VStack(spacing: 0, content: content)
//                    .transition(.appearFromUnder)
////                    .allowsHitTesting(expanded)
////                    .opacity(expanded ? 1 : 0)
////                    .frame(height: expanded ? nil : 0, alignment: .top)
////                    .mask {
////                        Rectangle()
////                            .frame(width: 300)
////                    }
//                    .zIndex(5)
//            }
//            
////            if expanded {
////                Divider()
////            }
//        }
//        .menuDisclosureState(isExpanded: expanded)
////        .menuCollapsed(!expanded)
//    }
//}
//
//
struct FrameTransitionModifier: ViewModifier {
    var isCollapsed: Bool = false
    
    func body(content: Content) -> some View {
        content
            .mask(alignment: .top) {
                Rectangle()
                    .frame(width: 300)
                    .frame(height: isCollapsed ? 0 : nil, alignment: .top)
            }
    }
}

extension AnyTransition {
    static var appearFromUnder: AnyTransition {
        .modifier(
            active: FrameTransitionModifier(isCollapsed: true),
            identity: FrameTransitionModifier()
        )
        .combined(with: .opacity)
    }
}

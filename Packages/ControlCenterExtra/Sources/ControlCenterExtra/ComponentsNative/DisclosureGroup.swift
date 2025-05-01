//
//  File.swift
//  
//
//  Created by Sake Salverda on 18/03/2024.
//

import SwiftUI

extension DisclosureGroupStyle where Self == MenuDisclosureStyle {
    public static var controlCenter: MenuDisclosureStyle {
        MenuDisclosureStyle()
    }
}

extension Animation {
    /// The default animation to use for expanding/height changes
    public static let controlCenterDefault: Animation = .spring(Spring(settlingDuration: 0.5, dampingRatio: 0.8))
}

public struct MenuDisclosureStyle: DisclosureGroupStyle {
//    let animation: Animation = .spring(Spring(settlingDuration: 0.5, dampingRatio: 0.8))
    internal init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.controlCenterDefault) {
                    configuration.isExpanded.toggle()
                }
            } label: {
                HStack {
                    configuration.label
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    ZStack {
                        Image(systemName: "chevron.down")
                            .hidden(!configuration.isExpanded)
                        
                        Image(systemName: "chevron.right")
                            .hidden(configuration.isExpanded)
                    }
                    .font(.callout)
                }
            }
            
            if configuration.isExpanded {
                VStack(spacing: 0) {
                    configuration.content
                }
                .transition(.reveal(from: .top, with: .init(horizontal: MenuGeometry.menuHorizontalHighlightInset - MenuGeometry.menuHorizontalContentInset)))
//                .transition(.reveal(from: .top))
//                .transition(.appearFromUnder)
            }
        }
        .menuDisclosureState(isExpanded: configuration.isExpanded)
//        .menuCollapsed(!configuration.isExpanded)
    }
}

#Preview {
        MenuPreview {
            DisclosureGroup("Battery") {
                Text("test")
                
                Text("test")
            }
//            .discloseToGroup()
            .menuCollapseToGroup()
            
            DisclosureGroup("Adapter") {
                Text("test")
                
                Text("test")
            }
            
            Spacer()
        }
}

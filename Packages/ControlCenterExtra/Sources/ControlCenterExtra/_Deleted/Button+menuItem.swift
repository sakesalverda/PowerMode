//
//  Button+menuItem.swift
//  PowerMode
//
//  Created by Sake Salverda on 17/01/2024.
//

import SwiftUI
import Walberg

//extension PrimitiveButtonStyle where Self == MenuItemStyle {
//    /// Style for a regular button in a menu
//    static var menuItem: MenuItemStyle {
//        MenuItemStyle()
//    }
//}



//struct MenuItemStyle: PrimitiveButtonStyle {
//    @Environment(\.isEnabled) private var isEnabled
//    
//    @State private var isPressed: Bool = false
//    @State private var isHovering: Bool = false
//    
//    var hoverEffect: Bool = true
//    
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .environment(\.isPressed, isPressed)
//            .padding(.vertical, 3)
//            .menuInset(.horizontal, to: .content)
//            .background {
//                if isHovering {
//                    RoundedRectangle(cornerRadius: 4, style: .continuous)
//                        .foregroundStyle(.quaternary)
//                }
//            }
//            .onReliablePress(binding: $isPressed) {
//                configuration.trigger()
//            }
//            .menuInset(.horizontal, to: .highlight)
//            .onReliableHover(binding: $isHovering)
//            .menuInset(.horizontal, to: .edge)
//            .opacity(isEnabled ? 1 : 0.33)
//    }
//}

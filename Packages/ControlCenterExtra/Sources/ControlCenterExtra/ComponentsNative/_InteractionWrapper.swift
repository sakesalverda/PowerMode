//
//  _InteractionWrapper.swift
//
//
//  Created by Sake Salverda on 12/03/2024.
//

import SwiftUI

struct OuterMenuItemWrapper: ViewModifier {
    @Environment(\.isEnabled) private var isEnabled
    
    @State var isHovered: Bool = false
    @State var isPressed: Bool = false
    
    private let shouldHover: Bool
    private let shouldPress: Bool
    
    init(hover: Bool, press: Bool = false, trigger: (() -> Void)? = nil) {
        self.shouldHover = hover
        self.shouldPress = press
        
        self.trigger = trigger
    }
    
    var trigger: (() -> Void)?
    
    var cornerRadius: CGFloat {
        if #available(macOS 26, *) {
            10
        } else {
            5
        }
    }
    
    func body(content: Content) -> some View {
        content
            .conditional(shouldPress) {
                $0.environment(\._isPressed, isPressed && isHovered)
            }
            .environment(\._isHovered, isHovered)
            .padding(.vertical, MenuGeometry.menuVerticalHighlightPadding)
            
            .menuInset(.horizontal, to: .content)
            
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .foregroundStyle(.quaternary)
                    .opacity(isHovered && isEnabled ? 1 : 0)
            }
            .contentShape(.rect)
        
            // Hover setup
            .conditional(shouldHover) {
//                $0.onHover { isHovered = $0 }
                $0.onReliableHover(binding: $isHovered)
            }
        
//            // Press setup
            .conditional(shouldPress) {
                $0.onReliablePress(binding: $isPressed) {
                    // when moving mouse out of the window, and then back
                    // this ispressed is fired, while hovered is false (this is not desired)
                    if shouldHover {
                        if isHovered {
                            trigger?()
                        }
                    } else {
                        trigger?()
                    }
                }
            }
        
            .menuInset(.horizontal, to: .highlight)
            
            .opacity(isEnabled ? 1 : 0.33)
    }
}

extension View {
    public func defaultMenuInteractions(hover: Bool = true, press: Bool = false, trigger: (() -> Void)? = nil) -> some View {
        modifier(OuterMenuItemWrapper(hover: hover, press: press, trigger: trigger))
    }
}

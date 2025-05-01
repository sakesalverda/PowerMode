//
//  SettingsCapsuleButton.swift
//  PowerMode
//
//  Created by Sake Salverda on 05/02/2024.
//

import SwiftUI

extension CapsuleButton {
    enum SupportedColor {
        case tint
        case white
        case red
    }
}

struct CapsuleButton: ButtonStyle {
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.controlSize) private var controlSize
    
    private var supportedColor: SupportedColor
    
    init(_ color: SupportedColor) {
        self.supportedColor = color
    }
    
    var foregroundStyle: Color {
        switch supportedColor {
        case .tint:
            .white
        case .white:
            .primary
        case .red:
            .white
        }
    }
    
    var backgroundStyle: AnyShapeStyle {
        switch supportedColor {
        case .tint:
            AnyShapeStyle(TintShapeStyle.tint)
        case .white:
            if colorSchemeContrast == .increased && colorScheme == .dark {
                AnyShapeStyle(.quaternary)
            } else {
                AnyShapeStyle(Color(nsColor: .controlColor))
            }
        case .red:
            AnyShapeStyle(Color.red)
        }
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(4)
            .padding(.top, -1.5)
            .padding(.horizontal, 5)
            .font(controlSize == .small ? .callout : .body)
            .fontWeight(.regular)
            .foregroundStyle(foregroundStyle)
            .background {
                ZStack {
                    Rectangle()
                        .foregroundStyle(backgroundStyle)
                    
                    Rectangle()
//                        .foregroundStyle(Color(nsColor: .controlTextColor))
                        .foregroundStyle(.primary)
                        .opacity(configuration.isPressed ? 0.1 : 0)
                }
                .clipShape(Capsule())
                .conditional(colorSchemeContrast == .standard) {
                    $0.shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 0.5)
                }
                .conditional(colorSchemeContrast == .increased) {
                    $0.overlay {
                        Capsule().strokeBorder(.secondary)
                    }
                }
            }
            .opacity(isEnabled ? 1 : 0.33)
    }
}

extension ButtonStyle where Self == CapsuleButton {
    static var capsule: CapsuleButton {
        CapsuleButton(.white)
    }
    
    static func capsule(_ color: CapsuleButton.SupportedColor) -> CapsuleButton {
        CapsuleButton(color)
    }
}

#Preview {
    VStack {
        // for reference
        Button {} label: {
            Text("Default Button")
        }
        .buttonStyle(.bordered)
        
        Button(action: {
            
        }) {
            Text("Some installation button")
        }
        .buttonStyle(.capsule)
        
        Button(action: {
            
        }) {
            Text("Some installation button")
        }
        .buttonStyle(.capsule)
        .disabled(true)
        
        Button(action: {
            
        }) {
            Text("Some installation button")
        }
        .buttonStyle(.capsule(.tint))
        
        Button(action: {
            
        }) {
            Text("Some installation button")
        }
        .buttonStyle(.capsule(.red))
        
        Button(action: {
            
        }) {
            Text("Some installation button")
        }
        .buttonStyle(.capsule)
    }
    .padding()
}

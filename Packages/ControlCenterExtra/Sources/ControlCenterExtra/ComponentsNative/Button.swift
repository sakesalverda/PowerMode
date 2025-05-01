//
//  SwiftUIView.swift
//  
//
//  Created by Sake Salverda on 05/03/2024.
//

import SwiftUI

struct PressedEnvironmentKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

struct HoveredEnvironmentKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    public var isPressed: Bool {
        get { self[PressedEnvironmentKey.self] }
    }
    
    var _isPressed: Bool {
        get { self[PressedEnvironmentKey.self] }
        set { self[PressedEnvironmentKey.self] = newValue }
    }
}

extension EnvironmentValues {
    public var isHovered: Bool {
        get { self[HoveredEnvironmentKey.self] }
    }
    
    var _isHovered: Bool {
        get { self[HoveredEnvironmentKey.self] }
        set { self[HoveredEnvironmentKey.self] = newValue }
    }
}

extension PrimitiveButtonStyle where Self == MenuButtonStyle {
    public static var controlCenter: MenuButtonStyle {
        MenuButtonStyle()
    }
}


struct MenuContentPositionKey: EnvironmentKey {
    static let defaultValue: TextAlignment = .leading
}

extension EnvironmentValues {
    public var menuButtonContentAlignment: TextAlignment {
        get { self[MenuContentPositionKey.self] }
    }
    
    var _menuButtonContentPosition: TextAlignment {
        get { self[MenuContentPositionKey.self] }
        set { self[MenuContentPositionKey.self] = newValue }
    }
}

extension View {
    public func menuButtonContent(at newPosition: TextAlignment) -> some View {
        environment(\._menuButtonContentPosition, newPosition)
    }
}

public struct MenuButtonStyle: PrimitiveButtonStyle {
    @Environment(\.menuButtonContentAlignment) private var alignment
    @Environment(\.controlSize) private var controlSize
    
    @State private var isPressed: Bool = false
    @State private var isHovered: Bool = false
    
    public func makeBody(configuration: Configuration) -> some View {
        HStack {
            if alignment != .leading {
                Spacer(minLength: 0)
            }
            
            configuration.label
            
            if alignment != .trailing {
                Spacer(minLength: 0)
            }
        }
        .conditional(controlSize == .large) { content in
            content
                .frame(minHeight: 26)
        }
        .labelStyle(MenuButtonLabelStyle())
        
        .defaultMenuInteractions(hover: true, press: true, trigger: configuration.trigger)
    }
}

struct MenuButtonLabelStyle: LabelStyle {
    @Environment(\.controlSize) private var controlSize
    
    private var isLarge: Bool {
        controlSize == .large
    }
    
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: isLarge ? 10 : 4) {
            if controlSize == .large {
                configuration.icon
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(width: 26)
            }
            else {
                configuration.icon
                    .font(.subheadline)
                    .fontWeight(.bold)
            }
            
            configuration.title
                .conditional(!isLarge) {
                    $0.labelStyle(.titleOnly)
                }
        }
        
    }
}

#Preview {
    MenuPreview {
        VStack(spacing: 0) {
            Button("Regular button", systemImage: "bolt.fill") {
                
            }
            
            Button("Regular button") {}
            
            Button("Regular button") {}
                .controlSize(.large)
            
            Button("Regular button", systemImage: "bolt.fill") {}
                .controlSize(.large)
            
            Button("Regular button") {}
                .controlSize(.large)
                .menuButtonContent(at: .center)
            
            Button("Regular button", systemImage: "bolt.fill") {}
                .controlSize(.large)
                .menuButtonContent(at: .center)
        }
    }
    .buttonStyle(.controlCenter)
}

//
//  SwiftUIView.swift
//  
//
//  Created by Sake Salverda on 05/03/2024.
//

import SwiftUI
import Walberg

///
/// .toggleStyle(.menu)
///
/// .toggleStyle(.menuTick)
/// .controlSize(.regular) and .controlSize(.large)
///

//typealias MenuButtonStyle = _MenuButton.Style
//public typealias MenuToggleStyle = MenuToggleStyle

extension ToggleStyle where Self == MenuToggleStyle {
    public static var controlCenter: MenuToggleStyle {
        MenuToggleStyle()
    }
}

extension ToggleStyle where Self == MenuToggleTickStyle {
    static var controlCenterTick: MenuToggleTickStyle {
        MenuToggleTickStyle()
    }
}

extension ControlSize: Comparable {
    public static func < (lhs: ControlSize, rhs: ControlSize) -> Bool {
        switch lhs {
        case .mini:
            switch rhs {
            case .mini: false
            @unknown default: true
            }
        case .small:
            switch rhs {
            case .mini, .small: false
            @unknown default: true
            }
        case .regular:
            switch rhs {
            case .mini, .small, .regular: false
            @unknown default: true
            }
        case .large:
            switch rhs {
            case .mini, .small, .regular, .large: false
            @unknown default: true
            }
        case .extraLarge:
            switch rhs {
            case .mini, .small, .regular, .large, .extraLarge: false
            @unknown default: true
            }
        }
    }
    
    
}

public struct MenuToggleTickStyle: ToggleStyle {
    @Environment(\.controlSize) var controlSize
    
    struct MenuToggleTickLabel: LabelStyle {
        @Environment(\.colorSchemeContrast) var colorSchemeContrast
        private var foreground: AnyShapeStyle {
            if colorSchemeContrast == .increased {
                AnyShapeStyle(Color(nsColor: .windowBackgroundColor))
            } else {
//                AnyShapeStyle(Color(nsColor: .secondaryLabelColor))
                AnyShapeStyle(.secondary)
            }
        }
        
        func makeBody(configuration: Configuration) -> some View {
            HStack(spacing: 10) {
                configuration.icon
//                    .frame(width: 26, height: 26)
                    .foregroundStyle(foreground)
                
                configuration.title
                
                Spacer(minLength: 0)
            }
        }
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            Label {
                if controlSize <= .regular {
                    configuration.label
                        .labelStyle(.titleOnly)
                } else {
                    configuration.label
                        .labelStyle(MenuToggleTickLabel())
                }
            } icon: {
                Image(systemName: "checkmark")
                    .conditional(controlSize > .regular) { content in
                        content.font(.body)
                    }
                    .hidden(!configuration.isOn)
                    .conditional(controlSize <= .regular) { content in
                        content
                            .offset(x: -4)
                            .padding(.horizontal, -4)
                    }
//                    .offset(x: -4)
//                    .padding(.trailing, -4)
//                    .opacity(configuration.isOn ? 1 : 0)
            }
        }
//        .buttonStyle(_ButtonStyle(isSelected: configuration.$isOn))
    }
    
    typealias _ButtonStyle = MenuButtonStyle
}

public struct MenuToggleStyle: ToggleStyle {
    public func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            configuration.label
        }
        .buttonStyle(_ButtonStyle(isSelected: configuration.$isOn))
    }
}

struct MenuLightIconKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    public var menuLightIcon: Bool {
        get { self[MenuLightIconKey.self] }
        set { self[MenuLightIconKey.self] = newValue }
    }
}

extension MenuToggleStyle {
    struct _ButtonStyle: PrimitiveButtonStyle {
        @Binding var isSelected: Bool
        
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .labelStyle(_LabelStyle(isSelected: isSelected))
                .defaultMenuInteractions(hover: true, press: true, trigger: configuration.trigger)
        }
    }
    
    struct _LabelStyle: LabelStyle {
        @Environment(\.colorScheme) private var colorScheme
        
        @Environment(\.isPressed) private var isPressed
        @Environment(\.isHovered) private var isHovered
        
        @Environment(\.colorSchemeContrast) private var colorSchemeContrast
        
        @Environment(\.menuLightIcon) private var lightIcon
        
        var isSelected: Bool
        
        private var foreground: AnyShapeStyle {
            if lightIcon && isSelected {
                AnyShapeStyle(.black)
            } else {
                if isSelected {
                    AnyShapeStyle(.tint)
                } else {
                    if colorSchemeContrast == .increased {
                        AnyShapeStyle(Color(nsColor: .windowBackgroundColor))
                    } else {
                        AnyShapeStyle(.secondary)
                    }
                }
            }
        }
        
        var buttonHighlightedStyle: AnyShapeStyle {
            if #available(macOS 26, *) {
                AnyShapeStyle(.white)
            } else {
                AnyShapeStyle(.tint)
            }
        }
        
        var buttonHighlightedTextStyle: AnyShapeStyle {
            if #available(macOS 26, *) {
                if isSelected {
                    AnyShapeStyle(.tint)
                } else {
                    AnyShapeStyle(.white.secondary)
                }
            } else {
                foreground
            }
        }
        
        func makeBody(configuration: Configuration) -> some View {
            HStack(spacing: 10) {
                configuration.icon
                    .frame(width: 26, height: 26)
                    .foregroundStyle(buttonHighlightedTextStyle)
                    .background {
                        if isSelected {
                            Circle()
                                .foregroundStyle(buttonHighlightedStyle)
                                .conditional(colorSchemeContrast == .increased && colorScheme != .light) {
                                    $0.overlay {
                                        Circle()
                                            .strokeBorder(.secondary)
                                    }
                                }
                        } else {
                            Group {
                                if colorSchemeContrast == .increased {
                                    Circle()
                                        .foregroundStyle(isHovered ? .secondary : .tertiary)
                                    
                                } else {
                                    Circle()
                                        .foregroundStyle(.tertiary)
                                }
                            }
                            .conditional(colorSchemeContrast == .increased) {
                                $0.overlay {
                                    Circle()
                                        .strokeBorder(.secondary)
                                }
                            }
                        }
                    }
                    .overlay {
                        if isPressed {
                            Circle()
                                .foregroundStyle(.primary)
                                .opacity(0.15)
                                .preferredColorScheme(colorScheme == .dark ? .light : .dark)
                        }
                    }
                
                configuration.title
                
                Spacer(minLength: 0)
            }
        }
    }
}

#Preview {
    struct B: View {
        @State var test = true
        
        var body: some View {
            Toggle("Test", systemImage: "bolt.fill", isOn: $test)
        }
    }
    
    return StatePreviewWrapper(false) { binding in
        VStack {
            VStack(spacing: 0) {
                B()
                
                Toggle("Test", systemImage: "battery.50percent", isOn: .constant(false))
                
                Toggle("Test", systemImage: "battery.50percent", isOn: .constant(false))
                    .disabled(true)
            }
            .toggleStyle(.controlCenter)
            
            VStack(spacing: 0) {
                B()
                
                Toggle("Test", isOn: .constant(true))
                
                Toggle("Test", isOn: .constant(false))
                    .disabled(true)
            }
            .toggleStyle(.controlCenterTick)
        }
    }
    .padding(.vertical)
    .frame(maxWidth: 300)
}

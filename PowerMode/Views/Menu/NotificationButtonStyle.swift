//
//  NotificationButtonStyle.swift
//  PowerMode
//
//  Created by Sake Salverda on 16/01/2024.
//

import SwiftUI
import ControlCenterExtra

enum MenuNotificationType {
    case warning
    case info
}

struct MenuNotificationButtonStyle: ButtonStyle {
    @State private var isHovering: Bool = false
    
    @Environment(\.controlSize) var controlSize
    
    var type: MenuNotificationType
    
    private var bold: Bool {
        controlSize == .large
    }
    
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 5) {
            Group {
                if type == .warning {
//                    Image(systemName: "exclamationmark.triangle")
//                        .fontWeight(.medium)
                    
                    Image(systemName: "exclamationmark.triangle.fill")
                        .fontWeight(.bold)
//                        .foregroundStyle(.white, .tertiary)
//                        .foregroundStyle(.orange)
                        .foregroundStyle(.white, .orange)
                } else {
//                    Image(systemName: "info.circle")
//                        .fontWeight(.medium)
                    
                    Image(systemName: "info.circle.fill")
                        .fontWeight(.bold)
//                        .foregroundStyle(.white, .tint)
                        .foregroundStyle(.white, .tint)
                }
            }
            .imageScale(.large)
            
            configuration.label
                .fontWeight(.medium)
        }
        .font(.callout)
        .conditional(bold) {
            $0
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity)
                .background(.quinary.opacity(configuration.isPressed ? 0.75 : isHovering ? 1 : 0), in: RoundedRectangle(cornerRadius: 6))
        }
        .conditional(!bold) {
            $0
            .padding(.vertical, 5)
            .padding(.leading, 5)
            .padding(.trailing, 9)
            .background {
                Capsule()
                    .fill(.quinary)
                    .opacity(configuration.isPressed ? 0.75 : isHovering ? 1 : 0)
            }
        }
        .onReliableHover { isHovering in
            self.isHovering = isHovering
        }
    }
}

extension ButtonStyle where Self == MenuNotificationButtonStyle {
    static func menuNotification(type: MenuNotificationType) -> MenuNotificationButtonStyle {
        MenuNotificationButtonStyle(type: type)
    }
}

#Preview {
    MenuPreview {
        Button {} label: {
            Text("Update available")
        }
        .buttonStyle(.menuNotification(type: .info))
        
        Button {} label: {
            Text("Issue with helper")
        }
        .buttonStyle(.menuNotification(type: .warning))
    }
}

//
//  DonationButton.swift
//  PowerMode
//
//  Created by Sake Salverda on 24/02/2024.
//

import SwiftUI

struct DonationButtonModifier: ViewModifier {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @Environment(\.colorScheme) private var colorScheme
    
    var isPrimary: Bool
    
    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    var fill: AnyShapeStyle {
        if colorScheme == .light {
            AnyShapeStyle(Color(nsColor: .controlColor))
        } else {
            AnyShapeStyle(.quaternary)
        }
    }
    
    func body(content: Content) -> some View {
        content
            .fontDesign(.rounded)
            .fontWeight(.medium)
            .font(isCompact ? .subheadline : .body)
            .padding(.vertical, 10)
            .frame(width: isCompact ? 55 : 70)
            .foregroundStyle(.primary)
            .multilineTextAlignment(.center)
            .background {
                RoundedRectangle(cornerRadius: 7)
                    .fill(.fill)
                    .strokeBorder(.tint, lineWidth: isPrimary ? 2 : 0)
            }
            .contentShape(Rectangle())
    }
}

extension View {
    func donateStyle(isPrimary: Bool = false) -> some View {
        modifier(DonationButtonModifier(isPrimary: isPrimary))
    }
}

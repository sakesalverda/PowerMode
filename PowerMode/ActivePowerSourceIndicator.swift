//
//  ActivePowerSourceIndicator.swift
//  PowerMode
//
//  Created by Sake Salverda on 24/01/2024.
//

import SwiftUI
import ControlCenterExtra

struct ActiveIndicatorOverlayModifier: ViewModifier {
    @Environment(AppState.self) private var appState
    
    @Preference(\.usePowerSourceIndicator) private var usePowerSourceIndicator
    
    private let offset = MenuGeometry.menuHorizontalContentInset - MenuGeometry.menuHorizontalHighlightInset*0
    
    var target: PowerSource
    
    var isActiveTarget: Bool {
        switch target {
        case .battery:
            appState.isUsingBattery
        case .adapter:
            appState.isUsingPowerAdapter
        }
    }
    
    let animationDuration: Double = 0.2
    let animationDelay: Double = 0.25
    
    func body(content: Content) -> some View {
        if usePowerSourceIndicator {
            HStack(alignment: .center, spacing: 5) {
                content
                
                ZStack {
                    if isActiveTarget {
                        Circle()
                            .foregroundStyle(.primary)
                            .foregroundColor(.green)
                            .frame(width: 5)
                            .offset(y: 0.5)
                            .transition(.scale(0.6).combined(with: .opacity))
                    }
                }
                .animation(
                    // we give it a short delay if it does become the active target
                    .easeInOut(duration: animationDuration).delay(isActiveTarget ? animationDelay : 0),
                    value: isActiveTarget
                )
            }
        } else {
            content
        }
    }
}

extension View {
    func activePowerSourceIndicator(for targetPowerSource: PowerSource) -> some View {
        modifier(ActiveIndicatorOverlayModifier(target: targetPowerSource))
    }
}

//
//  SingleComponents.swift
//  WidgetExtension
//
//  Created by Sake Salverda on 08/12/2023.
//

import SwiftUI
import Walberg

struct WidgetActivatedSymbol: View {
    @Environment(\.redactionReasons) private var reasons
    
    var width: CGFloat
    var color: Color
    
    var body: some View {
        Circle()
            .frame(width: width, height: width)
            .foregroundStyle(color)
            .hidden(!reasons.isEmpty)
            .id(color.description)
            .transition(.scale(0.1).combined(with: .opacity))
    }
}

struct WidgetHeadlineSmall: View {
    var source: PowerSource
    var activeSource: PowerSource?
    var selectedMode: EnergyMode?
    
    var body: some View {
        HStack {
            Text(source.widgetLabel)
                .fontWeight(.medium)
            
            Spacer()
            
            if let selectedMode = selectedMode {
                if source == activeSource {
                    WidgetActivatedSymbol(width: 6, color: selectedMode.widgetColor)
                }
            }
        }
    }
}

struct WidgetHeaderLarge: View {
    var source: PowerSource
    var activeSource: PowerSource? = nil
    var selectedMode: EnergyMode
    
    var body: some View {
//        VStack(spacing: 0) {
//            if activeSource != nil {
//                WidgetEyebrow(targetMode: selectedMode)
//                    .hidden(source != activeSource)
//            }
//
//            WidgetHeadline(source: source)
//        }
        
        HStack {
            WidgetHeadline(source: source)
            
            if activeSource != nil {
                WidgetActivatedSymbol(width: 8, color: selectedMode.widgetColor)
                    .hidden(source != activeSource)
            }
        }
    }
}

struct WidgetHeadline: View {
    var source: PowerSource
    
    @Environment(\.parentActive) private var parentActive
    
    var body: some View {
        HStack {
            Text(source.widgetLabel)
                .minimumScaleFactor(0.8)
                .font(.largeTitle.weight(.semibold))
                .foregroundStyle(.primary)
                .id("\(source.widgetLabel).\(parentActive.description)")
                .transition(.opacity)
            
            Spacer()
        }
    }
}

struct WidgetEyebrow: View {
    var targetMode: EnergyMode
    
    var body: some View {
        HStack {
            Text("Active Power Source:")
                .foregroundStyle(targetMode.widgetColor)
                .offset(x: 0.5)
            
            Spacer()
        }
        .font(.caption.weight(.medium))
    }
}

struct WidgetEditButtons: View {
    var selectedMode: EnergyMode
//    var availableWidth: CGFloat
    
    var body: some View {
        Grid {
            GridRow {
                WidgetModeButton(mode: .low, activeMode: selectedMode)
                WidgetModeButton(mode: .automatic, activeMode: selectedMode)
                WidgetModeButton(mode: .high, activeMode: selectedMode)
            }
        }
    }
}

struct WidgetModeDisplay: View, Equatable {
    static func == (lhs: WidgetModeDisplay, rhs: WidgetModeDisplay) -> Bool {
        lhs.selectedMode == rhs.selectedMode
    }
    
    var selectedMode: EnergyMode
    
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    var width: CGFloat {
        verticalSizeClass == .compact ? 34 : 60
    }
    
    var height: CGFloat {
        verticalSizeClass == .compact ? (width / 1.33) : (width / 1.468)
    }
    
    var radius: CGFloat {
        verticalSizeClass == .compact ? 9 : 10
    }
    
    @Environment(\.parentActive) private var parentActive
    @Environment(\.widgetRenderingMode) var widgetRenderingMode
    
    @Preference(\.widgetUseModeInLabel) private var widgetUseModeInLabel
    @Preference(\.widgetUsePowerInAutomaticLabel) private var widgetUsePowerInAutomaticLabel
    
    var transition: AnyTransition {
        return if parentActive {
            .asymmetric(insertion:
                    .push(from: .trailing),
                       removal:
                    .scale(scale: 0.8).combined(with: .opacity)
            )
        } else {
            .opacity.combined(with: .scale(scale: 0.8))
        }
    }
    
    var displayLabel: String {
        var label: [String] = [selectedMode.systemString]
        
        if selectedMode == .automatic && (widgetUsePowerInAutomaticLabel && widgetUseModeInLabel) {
            label.append("Power")
        }
        
        if widgetUseModeInLabel {
            label.append("Mode")
        }
        
        return label.joined(separator: " ")
    }
    
    var body: some View {
        AdaptiveStack(horizontalAlignment: .leading, horizontalSpacing: nil, verticalSpacing: 7) {
            ZStack {
                let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)
                
                if widgetRenderingMode == .vibrant {
                    shape
                        .foregroundStyle(.secondary)
                } else {
                    shape
                        .foregroundStyle(selectedMode.widgetColor)
                }
                
                Image(systemName: selectedMode.widgetSymbol)
                    .font(.title3.weight(.medium))
                    .imageScale(verticalSizeClass == .compact ? .medium : .large)
                    .foregroundStyle(.white)
            }
            .frame(width: width, height: height)
            .id("\(selectedMode).\(parentActive)")
            .transition(transition)
                
            Text(displayLabel)
                .font(.body.weight(.medium))
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(verticalSizeClass == .compact ? .secondary : .primary)
                .id("\(selectedMode).\(parentActive)")
                .transition(.opacity)
//                .transition(.push(from: .leading))
        }
        .environment(\.adaptiveStackDirection, verticalSizeClass == .compact ? .horizontal : .vertical)
    }
}

struct WidgetModeButton: View {
    var mode: EnergyMode
    var activeMode: EnergyMode
    
    var isActive: Bool {
        mode == activeMode
    }
    
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    let activeWidth: CGFloat = 50
    
    var height: CGFloat {
        return 50 / 1.468
    }
    
    var body: some View {
        fatalError("No transitions setup yet")
        VStack {
            ZStack {
                let rectangle = RoundedRectangle(cornerRadius: 9, style: .continuous)
                rectangle
                    .foregroundStyle(.quaternary)
                    .opacity(isActive ? 0 : 1)
                
                rectangle
                    .foregroundStyle(mode.widgetColor)
                    .opacity(isActive ? 1 : 0)
                
                Image(systemName: mode.widgetSymbol) //battery.25percent
                    .font(.title3.weight(.medium))
                    .imageScale(isActive ? .large : .small)
                    .foregroundStyle(isActive ? .white : .secondary)
            }
            .frame(width: isActive ? activeWidth : nil, height: height)
            
            if verticalSizeClass != .compact {
                Text(mode.widgetLabel)
                    .opacity(isActive ? 1 : 0.75)
                    .font(.callout)
                    .lineLimit(1)
            }
        }
    }
}

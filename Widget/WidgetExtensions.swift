//
//  WidgetExtensions.swift
//  WidgetExtension
//
//  Created by Sake Salverda on 08/12/2023.
//

import SwiftUI

extension EnergyMode {
    var widgetSymbol: String {
        systemImage
    }
    
    var widgetColor: Color {
        switch self {
        case .high:
            return .blue
        case .automatic:
            return .green
        case .low:
            return .orange
        }
    }
    
    var widgetLabel: String {
        switch self {
        case .automatic:
            "Automatic"
        case .low:
            "Low"
        case .high:
            "High"
        }
    }
}

extension PowerSource {
    var widgetLabel: String {
        switch self {
        case .battery:
            "Battery"
        case .adapter:
            "Adapter"
        }
    }
}

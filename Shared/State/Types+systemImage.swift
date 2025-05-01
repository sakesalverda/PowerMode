//
//  Types+systemImage.swift
//  PowerMode
//
//  Created by Sake Salverda on 21/12/2023.
//

import SwiftUI

// MARK: Visualisation extensions

extension EnergyMode {
    /// SF Symbol representation of the energy mode
    var systemImage: String {
        switch self {
//        case .low: "thermometer.low"
        case .low: "battery.25percent"
//            case .automatic: "swirl.circle.righthalf.filled"
        case .automatic: "wand.and.stars.inverse"
//        case .automatic: "gearshape.fill"
//        case .automatic: "target"
//        case .automatic: "drop.halffull"
//        case .automatic: "drop.fill"
//        case .automatic: "sparkle"
//        case .automatic: "mappin.and.ellipse"
//        case .automatic: "figure.walk"
            case .high: "bolt.fill"
        }
    }
    
    /// Color representation of the energy mode
    var systemColor: Color {
        switch self {
        case .high:
            return .blue
        case .automatic:
            return .blue
        case .low:
            return .orange
        }
    }
    
    /// String representation of the energy mode
    var systemString: String {
        switch self {
        case .automatic:
            "Automatic"
        case .low:
            "Low Power"
        case .high:
            "High Power"
        }
    }
}

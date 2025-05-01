//
//  Types+humanReadable.swift
//  PowerMode
//
//  Created by Sake Salverda on 21/12/2023.
//

import Foundation

// MARK: Human Readable Extensions
// used in logging strings

extension PowerSource: HumanReadableRepresentable {
    /// Representation used for logging
    var humanReadableValue: String {
        switch self {
        case .battery: "battery"
        case .adapter: "ac adapter"
        }
    }
}

extension EnergyModeKey: HumanReadableRepresentable {
    /// Representation used for logging
    var humanReadableValue: String {
        switch self {
        case .lowpowermode: "lowpowermode"
        case .powermode: "powermode"
        }
    }
}

extension EnergyMode: HumanReadableRepresentable {
    /// Representation used for logging
    var humanReadableValue: String {
        switch self {
        case .automatic:
            "automatic"
        case .low:
            "low"
        case .high:
            "high"
        }
    }
}

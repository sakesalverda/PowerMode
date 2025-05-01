//
//  Types.swift
//  PowerMode
//
//  Created by Sake Salverda on 03/12/2023.
//

import Foundation
import SwiftUI

protocol HumanReadableRepresentable {
    var humanReadableValue: String { get }
}

typealias XPCTransfer = UInt8

// NOTE: For each defined type, we use different raw values. This to prevent any possibility of accidentally mixing-up raw values
//
// additionally, we use UInt16 just to make sure we cannot accidentaly use an Int variable (which is likely a response from terminal) to initiate a new variable, this will likely fail and can result in crashes. This ensures that the proper init(cmdValue: ) is used for terminal responses

enum PowerSource: UInt8, RawRepresentable {
    case battery = 20
    case adapter = 21
    
    init?(rawValue: UInt8?) {
        if rawValue == Self.battery.rawValue {
            self = .battery
        } else if rawValue == Self.adapter.rawValue {
            self = .adapter
        } else {
            return nil
        }
    }
}


/// Value indicating the key that pmset should use to set the energy mode
enum EnergyModeKey: UInt8, RawRepresentable {
    case lowpowermode = 50
    case powermode = 51
}


enum EnergyMode: UInt8, RawRepresentable, CaseIterable {
    case automatic = 90
    case low = 91
    case high = 92
    
    /// The order used for displaying in views
    var displaySortIndex: Int {
        switch self {
        case .low: 0
        case .automatic: 1
        case .high: 2
        }
    }
}

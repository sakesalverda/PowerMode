//
//  Types+Terminal.swift
//  PowerMode
//
//  Created by Sake Salverda on 21/12/2023.
//

import Foundation
import IOKit.ps

extension PowerSource {
    var cmdValue: String {
        switch self {
        case .battery: kIOPSBatteryPowerValue
        case .adapter: kIOPSACPowerValue
        }
    }
    
    var cmdKey: String {
        switch self {
            case .battery: "-b"
            case .adapter: "-c"
            // case .ups: "-u"
        }
    }
    
    init?(cmdValue: String) {
        switch cmdValue {
        case kIOPSBatteryPowerValue:
            self = .battery
        case kIOPSACPowerValue:
            self = .adapter
        default:
            return nil
        }
    }
}

extension EnergyModeKey {
    var cmdValue: String {
        switch self {
        case .lowpowermode:
            return "lowpowermode"
        case .powermode:
            return "powermode"
        }
    }
    
    init?(cmdValue: String) {
        switch cmdValue {
        case "lowpowermode":
            self = .lowpowermode
        case "powermode":
            self = .powermode
        default:
            return nil
        }
    }
}

extension EnergyMode {
    /// Get the terminal value given the energy mode
    
    private func cmdValue(forKey powerModeKey: EnergyModeKey) -> Int {
        switch powerModeKey {
        case .lowpowermode:
            switch self {
            case .automatic: return 0
            case .low: return 1
            case .high:
                // FIXME: Should we crash app here?
                assertionFailure("This should not happen as `high power mode` is not available on devices with a lowpowermode pmset key")
                
                return 0
            }
        case .powermode:
            switch self {
            case .automatic: return 0
            case .low: return 1
            case .high: return 2
            }
        }
    }
    
    func cmdValue(forKey powerModeKey: EnergyModeKey) -> String {
        let cmdValue: Int = cmdValue(forKey: powerModeKey)
        
        return String(cmdValue)
    }
    
    init?(cmdValue: Int, forKey energyModeKey: EnergyModeKey) {
        switch energyModeKey {
        case .lowpowermode:
            switch cmdValue {
            case 0: self = .automatic
            case 1: self = .low
            default: return nil
            }
        case .powermode:
            switch cmdValue {
            case 0: self = .automatic
            case 1: self = .low
            case 2: self = .high
            default: return nil
            }
        }
    }
}

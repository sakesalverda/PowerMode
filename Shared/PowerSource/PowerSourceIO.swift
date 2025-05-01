//
//  PowerSourceIO.swift
//  PowerMode
//
//  Created by Sake Salverda on 29/11/2023.
//

import Foundation
import IOKit.ps
import OSLog

extension Logger {
    
}

// inspired by https://github.com/sindresorhus/Plash/blob/f8c09be4eb6ed2057bc6559de782645a2f497f72/Plash/Utilities.swift#L2411
// apple developer page https://developer.apple.com/documentation/iokit/iopowersources_h/1810316-iopsgetprovidingpowersourcetype
public enum PowerSourceIO {
    case internalBattery
    case externalUnlimited
    case externalUPS
    
    init(identifier: String) {
        switch identifier {
        case kIOPMBatteryPowerKey:
            self = .internalBattery
        case kIOPMACPowerKey:
            self = .externalUnlimited
        case kIOPMUPSPowerKey:
            self = .externalUPS
        default:
            self = .externalUnlimited
            
            Logger.powerSource.critical("This should not happen as `IOPSGetProvidingPowerSourceType` is documented to return one of the defined types")
            
            assertionFailure("This should not happen as `IOPSGetProvidingPowerSourceType` is documented to return one of the defined types")
        }
    }
}

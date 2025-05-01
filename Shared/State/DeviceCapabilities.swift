//
//  DeviceCapabilitiesState.swift
//  PowerMode
//
//  Created by Sake Salverda on 10/01/2024.
//

import Foundation

@Observable
class DeviceCapabilitiesState: Encodable {
    /// Variable indicating whether the device is capable of being powered by an internal battery
    var isBatteryCapableDevice: Bool = false
    
    /// Variable indicating whether the device is capable of being powered by an AC adapter
    var isAdapterCapableDevice: Bool = false
    
    /// Variable indicating whether the device is capable of getting/setting energy modes
    var isAnyPowerModeCapableDevice: Bool = false
    
    /// Variable indicating whether the device is capable of getting/setting high energy mode
    var isHighPowerModeCapableDevice: Bool = false
    
    
//    var isConfigured: Bool = false
}

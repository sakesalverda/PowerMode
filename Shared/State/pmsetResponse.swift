//
//  pmsetResponse.swift
//  PowerMode
//
//  Created by Sake Salverda on 03/02/2024.
//

import Foundation
import OSLog

struct pmsetResponse {
    let powerSource: PowerSource
    let energyModeKey: EnergyModeKey
    let energyMode: EnergyMode
    
    init?(powerSource: Substring, energyModeKey: Substring, energyMode: Substring) {
        self.init(powerSource: String(powerSource), energyModeKey: String(energyModeKey), energyMode: String(energyMode))
    }
    
    init?(powerSource: String, energyModeKey: String, energyMode: String) {
        guard let powerSource = PowerSource.init(cmdValue: powerSource) else {
            Logger.energyModeTerminal.warning("Could not identify power source from terminal response")
            
            return nil
        }
        
        guard let energyModeKey = EnergyModeKey.init(cmdValue: energyModeKey) else {
            Logger.energyModeTerminal.warning("Could not identify energy mode key from terminal response")
            
            return nil
        }
        
        guard let energyModeValueInt = Int(energyMode) else {
            Logger.energyModeTerminal.warning("Could not convert energy mode value from terminal response to type Int")
            
            return nil
        }
        
        guard let energyMode: EnergyMode = .init(cmdValue: energyModeValueInt, forKey: energyModeKey) else {
            Logger.energyModeTerminal.warning("Could not identify energy mode value from response")
            
            return nil
        }
        
        self.powerSource = powerSource
        self.energyModeKey = energyModeKey
        self.energyMode = energyMode
    }
}

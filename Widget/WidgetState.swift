//
//  WidgetState.swift
//  WidgetExtension
//
//  Created by Sake Salverda on 09/12/2023.
//

import Foundation

struct WidgetState {
    var powerSource: PowerSource
    var batteryEnergyMode: EnergyMode
    var adapterEnergyMode: EnergyMode
    var parentActive: Bool
    
    static let placeholder = WidgetState(powerSource: .battery, batteryEnergyMode: .low, adapterEnergyMode: .automatic, parentActive: true)
    
    init(powerSource: PowerSource, batteryEnergyMode: EnergyMode, adapterEnergyMode: EnergyMode, parentActive: Bool = false) {
        self.powerSource = powerSource
        self.batteryEnergyMode = batteryEnergyMode
        self.adapterEnergyMode = adapterEnergyMode
        self.parentActive = parentActive
    }
    
    init() {
        let widgetState = WidgetStateCacheModel.instance
        
        self.powerSource = widgetState.currentPowerSource ?? Self.placeholder.powerSource
        self.batteryEnergyMode = widgetState.batteryEnergyMode ?? Self.placeholder.batteryEnergyMode
        self.adapterEnergyMode = widgetState.adapterEnergyMode ?? Self.placeholder.adapterEnergyMode
        self.parentActive = widgetState.isMainApplicationActive && checkForRunningApp(.main)
//        self.parentActive = false
        
        if widgetState.currentPowerSource == nil || widgetState.batteryEnergyMode == nil || widgetState.adapterEnergyMode == nil {
            self.parentActive = false
        }
    }
}

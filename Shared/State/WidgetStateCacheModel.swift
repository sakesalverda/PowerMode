//
//  WidgetStateCacheModel.swift
//  PowerMode
//
//  Created by Sake Salverda on 10/01/2024.
//

import SwiftUI
import WidgetKit

import OSLog

extension Logger {
    static let widgetReloadManager = Self(.main, "widget.reload")
}

enum DeviceSupport: Int {
    case unknown = 0
    case no = 1
    case yes = 2
}

final class WidgetStateCacheModel {
    static let instance = WidgetStateCacheModel()
    
    private var needsImmediateUpdate: Bool = false
    
    private var hasScheduledUpdate: Bool = false
    
    private func reloadWidgets() {
        Logger.widgetReloadManager.info("Sending reload signal to widgets")
        
        WidgetCenter.shared.reloadAllTimelines()
        
        self.hasScheduledUpdate = false
    }
    
    private func immediateUpdate() {
        Logger.widgetReloadManager.notice("Received request to immediately reload widgets")
        
        reloadWidgets()
    }
    
    fileprivate func scheduleUpdate() {
        Logger.widgetReloadManager.notice("Received request to schedule reload widgets \(self.hasScheduledUpdate)")
        if hasScheduledUpdate == true {
            return
        }
        
        hasScheduledUpdate = true
        
        Logger.widgetReloadManager.info("Scheduled request to reload widgets")
        
        Task {
            try await Task.sleep(for: .seconds(Constants.widgetRefreshTimeout) + .seconds(0.1), tolerance: .seconds(0.3))
            
            reloadWidgets()
        }
    }
    
    
    private var currentPowerSourceInternal = StorableState<PowerSource?>("widget.activePowerSource", defaultValue: nil, store: .group)
    private var batteryEnergyModeInternal = StorableState<EnergyMode?>("widget.energyMode.battery", defaultValue: nil, store: .group)
    private var adapterEnergyModeInternal = StorableState<EnergyMode?>("widget.energyMode.adapter", defaultValue: nil, store: .group)
    private var isMainApplicationActiveInternal = StorableState<Bool>("widget.mainActive", defaultValue: false, store: .group)
    private var deviceSupportInternal = StorableState<DeviceSupport>("widget.deviceSupported", defaultValue: .unknown, store: .group)
    
    var hasValidData: Bool {
        currentPowerSource != nil && (batteryEnergyMode != nil || adapterEnergyMode != nil)
    }
    
    var currentPowerSource: PowerSource? {
        get {
            currentPowerSourceInternal.wrappedValue
        }
        
        set {
            if newValue != currentPowerSourceInternal.storedValue {
                currentPowerSourceInternal.wrappedValue = newValue
                
                scheduleUpdate()
            }
        }
    }
    
    var batteryEnergyMode: EnergyMode? {
        get {
            batteryEnergyModeInternal.wrappedValue
        }
        
        set {
            if newValue != batteryEnergyModeInternal.storedValue {
                batteryEnergyModeInternal.wrappedValue = newValue
                
                scheduleUpdate()
            }
        }
    }
    
    var adapterEnergyMode: EnergyMode? {
        get {
            adapterEnergyModeInternal.wrappedValue
        }
        
        set {
            if newValue != adapterEnergyModeInternal.storedValue {
                adapterEnergyModeInternal.wrappedValue = newValue
                
                scheduleUpdate()
            }
        }
    }
    
    var isMainApplicationActive: Bool {
        get {
            isMainApplicationActiveInternal.wrappedValue
        }
        set {
            if newValue != isMainApplicationActiveInternal.storedValue {
                isMainApplicationActiveInternal.wrappedValue = newValue
                
                if newValue == false {
                    immediateUpdate()
                } else {
                    scheduleUpdate()
                }
            }
        }
    }
    
    var isSupportedDevice: DeviceSupport {
        get {
            deviceSupportInternal.wrappedValue
        }
        
        set {
            if newValue != deviceSupportInternal.storedValue {
                deviceSupportInternal.wrappedValue = newValue
                
                scheduleUpdate()
            }
        }
    }
}

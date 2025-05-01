//
//  PowerSourceWatcher.swift
//  PowerMode
//
//  Created by Sake Salverda on 29/11/2023.
//

// Relevant keys are documented here: https://developer.apple.com/documentation/iokit/iopskeys_h/defines

import Foundation
import SwiftUI
import IOKit.ps
import Combine
import OSLog

extension Logger {
    static let batteryRetriever = Self(.main, "batterywatcher.retriever")
}

fileprivate extension PowerSourceIO {
    var isUsingBattery: Bool {
        self == .internalBattery
    }
    
    var isUsingPowerAdapter: Bool {
        self == .externalUnlimited
    }
    
    var asPowerSource: PowerSource {
        switch self {
        case .internalBattery:
            .battery
        case .externalUnlimited:
            .adapter
        case .externalUPS:
            .adapter
        }
    }
}

// inspired by https://github.com/sindresorhus/Plash/blob/f8c09be4eb6ed2057bc6559de782645a2f497f72/Plash/Utilities.swift#L2447
// and https://stackoverflow.com/a/41528433
@Observable
class PowerSourceWatcher {
    var powerSource: PowerSourceIO?
    
    var batteryCurrentPercentage: Int?
    
    var isUsingBattery: Bool { powerSource?.isUsingBattery ?? false }
    
    var isUsingPowerAdapter: Bool { powerSource?.isUsingPowerAdapter ?? false }
    
    private(set) var isFullyCharged: Bool
    
    private(set) var isCharging: Bool
    
    private(set) var timeToFullyCharge: Int?
    
    private(set) var timeToEmpty: Int?
    
    @ObservationIgnored private var runLoop: CFRunLoop!
    @ObservationIgnored private var runLoopLimited: CFRunLoopSource!
    @ObservationIgnored private var runLoopBattery: CFRunLoopSource!
    
    init() {
        powerSource = Self.getProvidingPowerSource()
        batteryCurrentPercentage = Self.getCurrentBatteryPercentage()
        
        (isCharging, isFullyCharged, timeToFullyCharge, timeToEmpty) = Self.getIsCharging()
        
        
        _setupObservers()
    }
    
    deinit {
        CFRunLoopRemoveSource(runLoop, runLoopLimited, .defaultMode)
        CFRunLoopStop(runLoop)
    }
    
    /// Returns the current battery percentage as an Int
    static private func getCurrentBatteryPercentage() -> Int? {
        enum BatteryError: Error {
            case snapshot
            case sources
            case dictionary
            
            var localizedDescription: String {
                switch self {
                case .snapshot:
                    "Could not create power source snapshot"
                case .sources:
                    "Could not create power sources list"
                case .dictionary:
                    "Could not create power source description dictionary"
                }
            }
        }

        Logger.batteryRetriever.notice("Initialising reading of battery level")
        
        do {
            // Take a snapshot of all the power source info
            guard let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue()
                else { throw BatteryError.snapshot }

            // Pull out a list of power sources
            guard let sources: NSArray = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue()
                else { throw BatteryError.sources }
            
            var batteries: [String: Double] = [:]
            var ups: [String: Double] = [:]
            
            // For each power source...
            for ps in sources {
                // Fetch the information for a given power source out of our snapshot
                guard let info: NSDictionary = IOPSGetPowerSourceDescription(snapshot, ps as CFTypeRef)?.takeUnretainedValue()
                    else { throw BatteryError.dictionary }

                // Pull out the name and current capacity
                if let name = info[kIOPSNameKey] as? String,
                   let type = info[kIOPSTypeKey] as? String,
                   let capacity = info[kIOPSCurrentCapacityKey] as? Double,
                   let max = info[kIOPSMaxCapacityKey] as? Double {
                    
                    if type == kIOPSInternalBatteryType {
                        batteries[name] = capacity / max * 100
                    } else if type == kIOPSUPSType {
                        ups[name] = capacity / max * 100
                    }
                }
            }
            
            var returnValue: Int? = nil
            
            if batteries.count > 0 {
                if let firstValue = batteries.first?.value.rounded(.toNearestOrAwayFromZero) {
                    returnValue = Int(firstValue)
                }
                
                if batteries.count > 1 {
                    Logger.batteryRetriever.debug("More than 1 internal battery detected. \(batteries.keys)")
                }
            } else {
                Logger.batteryRetriever.warning("No internal battery detected.")
                
                if ups.count > 0 {
                    Logger.batteryRetriever.info("Some UPS power source was found.")
                }
            }
            
            return returnValue
        } catch {
            Logger.batteryRetriever.error("There was an error in obtaining the battery level: \(error.localizedDescription)")
            
            return nil
        }
        
//        let warningLevel = IOPSGetBatteryWarningLevel()
//        // otherwise it is either kIOPSLowBatteryWarningFinal
//        // or kIOPSLowBatteryWarningEarly
//        return warningLevel != kIOPSLowBatteryWarningNone
    }
    
    /// Returns the current power source
    static private func getProvidingPowerSource() -> PowerSourceIO? {
        guard let powerSourceIdentifier = IOPSGetProvidingPowerSourceType(nil)?.takeRetainedValue() as? String else { return nil }
        
        return PowerSourceIO(identifier: powerSourceIdentifier)
    }
    
    
    // source: https://forums.developer.apple.com/forums/thread/128048
    static private func getIsCharging() -> (isCharging: Bool, isFullyCharged: Bool, timeToFullyCharge: Int?, timeToEmpty: Int?) {
        let emptyOut = (
            isCharging: true,
            isFullyCharged: false,
            timeToFullyCharge: Optional<Int>.none,
            timeToEmpty: Optional<Int>.none
        )
        
        guard let blob = IOPSCopyPowerSourcesInfo()?.takeRetainedValue() else {
            return emptyOut
        }
//        print("ISCHARGING 2")
        
        guard let sources = IOPSCopyPowerSourcesList(blob)?.takeRetainedValue() as [CFTypeRef]? else {
            return emptyOut
        }
        
//        print("ISCHARGING 3")
        
        for source in sources {
            guard let sourceInfo = IOPSGetPowerSourceDescription(blob, source)?.takeUnretainedValue() as? [String: Any] else {
                continue
            }
            
//            print("ISCHARGING 3.1")
            
            // @todo: why is this a guard?
            guard var isCharging = sourceInfo[kIOPSIsChargingKey] as? Bool else {
                continue
            }
            
//            print("ISCHARGING 3.2")
//            
//            print(sourceInfo[kIOPSIsFinishingChargeKey])
            
//            print(kIOPSProvidesTimeRemaining, kIOPSIsChargedKey)
//            let kIOPSProvidesTimeRemaining = "Battery Provides Time Remaining"
            
            
            
//            isCharging = sourceInfo[kIOPSIsChargingKey] as? Bool ?? false
            
            let isFinishingCharge = sourceInfo[kIOPSIsFinishingChargeKey] as? Bool ?? false
            let isFullyCharged = sourceInfo[kIOPSIsChargedKey] as? Bool ?? false
            
            if isFullyCharged || isFinishingCharge {
                isCharging = false
            }
            
            // only valid if isChargingKey is true!
            // value of -1 indicates "Still Calculating the Time" (note, that 'still calculating' is not displayed by apple themselves)
            let timeToFullyCharge = sourceInfo[kIOPSTimeToFullChargeKey] as? Int
            
            let timeToEmpty = sourceInfo[kIOPSTimeToEmptyKey] as? Int
            
//            let timeToFullyCharge = (isCharging ? sourceInfo[kIOPSTimeToFullChargeKey] as? Int : nil) ?? 0
            // display as 15m until fully charged
            // or as 2h 15m until fully charged
            
            // either
            // - charging
            // - fully charged
            // - running on battery
            
            return (
                isCharging:         isCharging,
                isFullyCharged:     isFullyCharged || isFinishingCharge,
                timeToFullyCharge:  isCharging ? timeToFullyCharge : nil,
                timeToEmpty:        (isCharging || isFullyCharged || isFinishingCharge) ? nil : timeToEmpty
            )
        }
        
        return emptyOut
    }
    
    
    // update the stored power source
    private func handlePowerSourceChange() {
        self.powerSource = Self.getProvidingPowerSource()
    }
    
    private func handleChargingStateChange() {
        (isCharging, isFullyCharged, timeToFullyCharge, timeToEmpty) = Self.getIsCharging()
//        self.isCharging =
    }
    
    // update the current battery percentage
    private func handleBatteryPercentageChange() {
        self.batteryCurrentPercentage = Self.getCurrentBatteryPercentage()
    }
    
    private func _setupObservers() {
        runLoop = CFRunLoopGetCurrent()
        
        let batteryPercentageCallback: IOPowerSourceCallbackType = { context in
            guard let context = context else {
                assertionFailure("This should not happen as `context` is passed to here by ourselves")
                
                return
            }
            
            let watcher = Unmanaged<PowerSourceWatcher>.fromOpaque(context).takeUnretainedValue()
            
            watcher.handleBatteryPercentageChange()
            
            watcher.handleChargingStateChange()
        }
        
        let powerSourceCallback: IOPowerSourceCallbackType = { context in
            guard let context = context else {
                assertionFailure("This should not happen as `context` is passed to here by ourselves")
                
                return
            }
            
            let watcher = Unmanaged<PowerSourceWatcher>.fromOpaque(context).takeUnretainedValue()
            
            watcher.handlePowerSourceChange()
        }
        
        // this fires when any power source information changes (amongst others the battery percentage, and charging state)
        runLoopBattery = IOPSNotificationCreateRunLoopSource(batteryPercentageCallback,
                                                             UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        ).takeRetainedValue()
        
        // this fires only when switching between limited and unlimited power source
        runLoopLimited = IOPSCreateLimitedPowerNotification(powerSourceCallback,
                                                            UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        ).takeRetainedValue()
        
        CFRunLoopAddSource(runLoop, runLoopBattery, .defaultMode)
        CFRunLoopAddSource(runLoop, runLoopLimited, .defaultMode)
    }
}

//
//  Helper+PeriodicChecker.swift
//  nl.sakesalverda.PowerMode.helper
//
//  Created by Sake Salverda on 04/02/2024.
//

import Foundation
import AppKit
import OSLog

extension Logger {
    static let helperPeriodic = Self(.helper, "periodic")
}

extension Helper {
    final class PeriodicChecker2: @unchecked Sendable {
        var observer: NSKeyValueObservation? = nil
        
        init() {
            Logger.helperPeriodic.trace("Initiating active applications observer")
            
            observer = NSWorkspace.shared.observe(\.runningApplications, options: [.new]) { [weak self] (model, change) in
                Logger.helperPeriodic.trace("Initiating check to determine if main application is active")
                
                let hasFound = model.runningApplications.compactMap { $0.bundleIdentifier }.contains(Constants.bundle)
                
//                let value = model.runningApplications
//                guard let value = change.newValue else {
//                    Logger.helperPeriodic.trace("No new value found, \(change.oldValue == nil, privacy: .public), \(change.newValue == nil, privacy: .public)")
//
//                    return
//                }
                
//                var hasFound = false
//
//                for app in value {
//                    if app.bundleIdentifier == Constants.bundle {
//                        Logger.helperPeriodic.trace("Main application is running")
//                        hasFound = true
//                    }
//                }
                
                if !hasFound {
                    Logger.helperPeriodic.trace("Main application is not active, terminating helper")
                    
                    self?.observer?.invalidate()
                    
                    exit(0)
                }
            }
        }
    }
}

//
//  checkForRunningApp.swift
//  PowerMode
//
//  Created by Sake Salverda on 03/02/2024.
//

import AppKit
import OSLog

enum RunningApplications {
    case main
    case helper
    
    var bundleIdentifier: String {
        switch self {
        case .main:
            Constants.bundle
        case .helper:
            "\(Constants.bundle).helper"
        }
    }
}

func checkForRunningApp(_ executable: RunningApplications) -> Bool {
    checkForRunningApp(bundleIdentifier: executable.bundleIdentifier)
}

fileprivate extension Logger {
    static let runningAppCheck = Self(.main, "runningAppCheck")
//    static let runningAppCheck = Self(subsystem: "nl.sakesalverda.Veldkamp", category: "runningAppCheck")
}

public func checkForRunningApp(bundleIdentifier: String) -> Bool {
    let applications = NSWorkspace.shared.runningApplications
    
    Logger.runningAppCheck.trace("Determining whether application \(bundleIdentifier) is active")
//
//    for app in NSWorkspace.shared.runningApplications {
//        if app.bundleIdentifier == "nl.sakesalverda.PowerMode" {
//            Logger.runningAppCheck.trace("Application is truly active")
//        }
//    }
    
    for app in applications {
        if app.bundleIdentifier == bundleIdentifier {
            Logger.runningAppCheck.debug("Application \(bundleIdentifier) is active")
            
            return true
        }
    }
    
    Logger.runningAppCheck.trace("Application \(bundleIdentifier) is not active")
    
    return false
}

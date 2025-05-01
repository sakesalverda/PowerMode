//
//  main.swift
//  Helper
//
//  Created by Sake Salverda on 29/11/2023.
//

import AppKit
import OSLog

extension Logger {
    static let helper = Self(.helper, "helper")
}

Logger.helper.notice("Setting up checkers and listeners")

Logger.helper.trace("Setting up helper main")
// initiate the helper tool
let helper = Helper()
helper.run()

Logger.helper.trace("Setting up periodic checker")
// start the watching for the parent app
let periodicChecker = Helper.PeriodicChecker2()

// keep the application active
RunLoop.current.run()

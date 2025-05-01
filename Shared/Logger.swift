//
//  Logger.swift
//  PowerMode
//
//  Created by Sake Salverda on 21/12/2023.
//

import Foundation
import OSLog

// descriptions from https://www.avanderlee.com/workflow/oslog-unified-logging/

/// A wrapper around Logger, for writing interpolated string messages to the unified logging system.
///
/// - Parameter notice: The default log level, which is not really telling anything about the logging. It’s better to be specific by using the other log levels.
/// - Parameter info: Call this function to capture information that may be helpful, but isn’t essential, for troubleshooting.
///
/// - Parameter debug or trace: Debug-level messages to use in a development environment while actively debugging.
///
/// - Parameter warning: Warning-level messages for reporting unexpected non-fatal failures.
///
/// - Parameter error: Error-level messages for reporting critical errors and failures.
///
/// - Parameter fault or critical: Fault-level messages for capturing system-level or multi-process errors only.

extension Logger {
    enum BinaryTarget: String {
        case main
        case helper
        case widget
    }
}

extension Logger {
    /// main.helper.connection
    init(_ target: BinaryTarget, _ category: String) {
        self.init(subsystem: Constants.bundle, category: "\(target.rawValue).\(category)")
    }
    
    static let helperConnection = Logger(.main, "helper-connection")
}

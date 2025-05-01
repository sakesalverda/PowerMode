//
//  Throttle.swift
//  PowerMode
//
//  Created by Sake Salverda on 16/03/2024.
//

import Foundation

public class Throttle {
    private let throttleQueue = DispatchQueue(label: "com.throttlequeue")
    private var currentTimer: DispatchSourceTimer?
    
    let timeoutInterval: DispatchTimeInterval
    
    /// Creates a new throttle that performs work after waiting the given timeout interval.
    ///
    /// - Parameter interval: The time period to wait before performing work.
    public init(interval: DispatchTimeInterval) {
        timeoutInterval = interval
    }
    
    /// Schedule a block for execution.
    ///
    /// Scheduling a `block`, executes it after the pre-set interval of time for the current `Throttle` instance.
    /// If you schedule a new block before the throttle interval has passed,
    /// the previous block is canceled in favor of the latest one.
    public func schedule(block: @escaping ()->Void) {
        throttleQueue.sync {
            if let currentTimer = currentTimer {
                currentTimer.cancel()
            }

            currentTimer = DispatchSource.makeTimerSource()
            currentTimer?.schedule(wallDeadline: .now() + timeoutInterval)
            currentTimer?.setEventHandler {
                block()
            }
            currentTimer?.resume()
        }
    }
}

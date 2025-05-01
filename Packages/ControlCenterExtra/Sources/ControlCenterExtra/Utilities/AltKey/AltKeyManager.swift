//
//  AltKeyTrackedModifier.swift
//  PowerMode
//
//  Created by Sake Salverda on 16/01/2024.
//

import SwiftUI

@Observable
class AltKeyManager {
    private var observer = AltKeyObserver()
    
    var isAltKeyPressed: Bool {
        observer.isPressed
    }
    
    @ObservationIgnored var lastAltKeyPressedChange: Date? = nil
    
    func startObserving() {
        observer.startObserving()
    }
    
    func stopObserving() {
        observer.stopObserving()
    }
    
    private func startWithObservation() {
        withObservationTracking {
            _ = observer.isPressed
            
            lastAltKeyPressedChange = .now
        } onChange: {
            self.startWithObservation()
        }
    }
    
    init() {
        startWithObservation()
    }
    
    @ObservationIgnored var isUpdatingFromAltKey: Bool {
        access(keyPath: \.isAltKeyPressed)
        
        guard let lastAltChange = lastAltKeyPressedChange else {
            return false
        }
        
        // takes approximately 0.0007 and 0.015 seconds
        return lastAltChange.timeIntervalSinceNow.magnitude < 0.05
    }
}

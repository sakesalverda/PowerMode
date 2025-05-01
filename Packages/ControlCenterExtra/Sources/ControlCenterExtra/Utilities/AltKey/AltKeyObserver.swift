//
//  AltKeyObserver.swift
//  PowerMode
//
//  Created by Sake Salverda on 10/01/2024.
//

import AppKit
import Combine

@Observable
class AltKeyObserver {
    // MARK: option key listener
    // from https://gist.github.com/joncardasis/78c7dee7e8de306cfd53e3bb714c6b0a
    
    @ObservationIgnored private var menuObserver: CFRunLoopObserver? = nil
    @ObservationIgnored private var menuObservedPreviousState: Bool? = nil
    
    var isPressed: Bool = false
    
    fileprivate func menuRecievedEvents() {
        let optionKeyIsPressed = NSEvent.modifierFlags.contains(.option)
        
        if optionKeyIsPressed != menuObservedPreviousState {
            Task { @MainActor in
//            DispatchQueue.main.async {
                self.isPressed = optionKeyIsPressed
            }
        }
        
        menuObservedPreviousState = optionKeyIsPressed
    }
    
    func startObserving() {
        menuObservedPreviousState = nil
        
        if menuObserver == nil {
            menuObserver = CFRunLoopObserverCreateWithHandler(nil, CFRunLoopActivity.beforeWaiting.rawValue, true, 0, { (observer, activity) in
                self.menuRecievedEvents()
            })
            
            CFRunLoopAddObserver(CFRunLoopGetCurrent(), menuObserver, CFRunLoopMode.commonModes)
        }
    }
    
    func stopObserving() {
        guard menuObserver != nil else {
            return
        }
        
        CFRunLoopObserverInvalidate(menuObserver)
        
        menuObserver = nil
        menuObservedPreviousState = nil
    }
    
    // MARK: init
    
    deinit {
        self.stopObserving()
    }
    
    init() {
        
    }
}

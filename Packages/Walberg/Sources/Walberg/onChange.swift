//
//  onChange.swift
//  
//
//  Created by Sake Salverda on 05/02/2024.
//

import Foundation

import Foundation

@discardableResult
public func onChange<V>(of value: @Sendable @escaping @autoclosure () -> V,
                 initial: Bool = false,
                 once: Bool = false,
                 _ action: @escaping (V, V) -> Void) -> onChangeObserverCancellable<V> where V: Equatable {
    let observer = onChangeObserverCancellable(of: value, initial: initial, once: once) { (previousValue, newValue) in
        action(previousValue, newValue)
    }
    
    observer.startObservation()
    
    return observer
}

@discardableResult
public func onChange<V>(of value: @Sendable @escaping @autoclosure () -> V,
                 initial: Bool = false,
                 once: Bool = false,
                 _ action: @escaping () -> Void) -> onChangeObserverCancellable<V> where V: Equatable {
    let observer = onChangeObserverCancellable(of: value, initial: initial, once: once) { (previousValue, newValue) in
        action()
    }
    
    observer.startObservation()
    
    return observer
}

actor onChangeObserverCancellableActor<V> where V: Equatable & Sendable {
    private var previousValue: V
    
    private let value: @Sendable () -> V
    private let action: @Sendable (V, V) -> Void
    
    private var _isCancelled: Bool = false
    private var _shouldCancel: Bool = false
    
    init(of value: @escaping @Sendable () -> V, initial: Bool, once: Bool = false, perform action: @escaping @Sendable (V, V) -> Void) {
        self.value = value
        self.action = action
        
        // store the current value as the previous value
        self.previousValue = value()
        
        if once {
            _shouldCancel = true
        }
        
        if initial {
            action(previousValue, previousValue)
        }
    }
    
    func _updatePreviousValue(_ newValue: V) {
        self.previousValue = newValue
    }
    
    func startObservation() {
        if self._isCancelled { return }
        
        _ = withObservationTracking {
            value()
        } onChange: {
            Task { @MainActor in
                if await self._isCancelled { return }
                
                let newValue = self.value()
                
                if await newValue != self.previousValue {
                    // perform the action
                    await self.action(self.previousValue, newValue)
                }
                
                // update the previous value to the current value for the next iteration
                await self._updatePreviousValue(newValue)
                
                // if should cancel, we set the state to cancelled
                if await self._shouldCancel {
                    await self.cancelObservation()
//                    self._isCancelled = true
                } else {
                    await self.startObservation()
                }
            }
        }
    }
    
    func cancelObservation() {
        _isCancelled = true
    }
}

public class onChangeObserverCancellable<V> where V: Equatable {
    private var previousValue: V
    
    private let value: () -> V
    private let action: (V, V) -> Void
    
    init(of value: @escaping () -> V, initial: Bool, once: Bool = false, perform action: @escaping (V, V) -> Void) {
        self.value = value
        self.action = action
        
        // store the current value as the previous value
        self.previousValue = value()
        
        if once {
            _shouldCancel = true
        }
        
        if initial {
            action(previousValue, previousValue)
        }
    }
    
    private var _isCancelled: Bool = false
    private var _shouldCancel: Bool = false
    
    func startObservation() {
        if self._isCancelled { return }
        
        _ = withObservationTracking {
            value()
        } onChange: {
            if self._isCancelled { return }
            
            Task { @MainActor in
                let newValue = self.value()
                
                if newValue != self.previousValue {
                    // perform the action
                    self.action(self.previousValue, newValue)
                }
                
                // update the previous value to the current value for the next iteration
                self.previousValue = newValue
                
                // if should cancel, we set the state to cancelled
                if self._shouldCancel {
                    self._isCancelled = true
                } else {
                    self.startObservation()
                }
            }
        }
    }

    public func cancelObservation() {
        _isCancelled = true
    }
}

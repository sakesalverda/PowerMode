//
//  StorableState.swift
//  PowerMode
//
//  Created by Sake Salverda on 10/01/2024.
//

import SwiftUI
import OSLog

extension Logger {
    static let storableState = Self(.main, "storablestate")
}

struct StorableState<Value> where Value: Equatable {
    private var store = UserDefaults.standard
    
    private let storageKey: String
    
    private var defaultValue: Value
    
    private(set) var storedValue: Value
    private var retrieveValue: () -> Value
    private var storeValue: (Value) -> Void = {_ in}
    
    var wrappedValue: Value {
        get {
            Logger.storableState.trace("Getting value for key: \(storageKey)")
//            _ = storedValue
//            access(keyPath: \.wrappedValue)
            return retrieveValue()
        }
        
        set {
            Logger.storableState.trace("Attempting to store new value for some key")
            
//            withMutation(keyPath: \.wrappedValue) {
            if newValue != storedValue {
                Logger.storableState.trace("Storing new value for some key")
                storeValue(newValue)
                
                storedValue = newValue
            } else {
                Logger.storableState.trace("No new value to set for some key")
            }
        }
    }
}
   
extension StorableState {
    init(_ key: String, defaultValue: Value = false, store userDefaultsStore: UserDefaults? = nil) where Value == Bool {
        self.storageKey = key
        self.defaultValue = false
        self.storedValue = defaultValue
        self.retrieveValue = { false }
        
        if let userDefaultsStore {
            self.store = userDefaultsStore
        }
        
        self.storeValue = { [self] newValue in
            store.set(newValue, forKey: storageKey)
        }
        
        self.retrieveValue = { [self] in
            store.bool(forKey: storageKey)
        }
        
        storedValue = retrieveValue()
    }
    
    init(_ key: String, defaultValue: Value, store userDefaultsStore: UserDefaults? = nil) where Value: RawRepresentable, Value.RawValue == Int {
        self.storageKey = key
        self.defaultValue = defaultValue
        self.storedValue = defaultValue
        self.retrieveValue = { defaultValue }
        
        if let userDefaultsStore {
            self.store = userDefaultsStore
        }
        
        self.storeValue = { [self] newValue in
            store.set(newValue, forKey: storageKey)
        }
        
        self.retrieveValue = { [self] in
            if store.object(forKey: storageKey) != nil {
                let value = store.integer(forKey: storageKey)

                if let casted = Value(rawValue: value) {
                    return casted
                }
            }
            
            return defaultValue
        }
        
        self.storedValue = retrieveValue()
    }
    
    init(_ key: String, defaultValue: Value, store userDefaultsStore: UserDefaults? = nil) where Value: RawRepresentable, Value.RawValue == UInt8 {
        self.storageKey = key
        self.defaultValue = defaultValue
        self.storedValue = defaultValue
        self.retrieveValue = { defaultValue }
        
        if let userDefaults = userDefaultsStore {
            self.store = userDefaults
        }
        
        self.storeValue = { [self] newValue in
            store.set(newValue, forKey: storageKey)
        }
        
        self.retrieveValue = { [self] in
            if store.object(forKey: storageKey) != nil {
                let value = store.integer(forKey: storageKey)

                if let casted = Value(rawValue: Value.RawValue(value)) {
                    return casted
                }
            }
            
            return defaultValue
        }
        
        self.storedValue = retrieveValue()
    }
    
    init<R>(_ key: String, defaultValue: R? = nil, store userDefaultsStore: UserDefaults? = nil) where Value == R?, R: RawRepresentable, R.RawValue == Int {
        self.storageKey = key
        self.defaultValue = defaultValue
        self.storedValue = defaultValue
        self.retrieveValue = { nil }
        
        if let userDefaults = userDefaultsStore {
            self.store = userDefaults
        }
        
        self.storeValue = { [self] newValue in
            store.set(newValue?.rawValue, forKey: storageKey)
        }
        
        self.retrieveValue = { [self] in
            if store.object(forKey: storageKey) != nil {
                let value = store.integer(forKey: storageKey)

                if let casted = R(rawValue: value) {
                    return casted
                }
            }
            
            return nil
        }
        
        self.storedValue = retrieveValue()
    }
    
    init<R>(_ key: String, defaultValue: R? = nil, store userDefaultsStore: UserDefaults? = nil) where Value == R?, R: RawRepresentable, R.RawValue == UInt8 {
        self.storageKey = key
        self.defaultValue = defaultValue
        self.storedValue = defaultValue
        self.retrieveValue = { nil }
        
        if let userDefaults = userDefaultsStore {
            self.store = userDefaults
        }
        
        self.storeValue = { [self] newValue in
            store.set(newValue?.rawValue, forKey: storageKey)
        }
        
        self.retrieveValue = { [self] in
            if store.object(forKey: storageKey) != nil {
                let value = store.integer(forKey: storageKey)

                if let casted = R(rawValue: R.RawValue(value)) {
                    return casted
                }
            }
            
            return nil
        }
        
        self.storedValue = retrieveValue()
    }
}

//struct StorableState<Value> {
//    private var storageKey: String
//    private var storedValue: Value
//    private var defaultValue: Value
////    private var retrieveValue: () -> Value
//
//    init(_ key: String, defaultValue: Value) where Value == Bool {
//
//    }
//
//}
//
//extension StorableState where Value: RawRepresentable, Value.RawValue == Int {
//    func retrieveValue() -> Value {
//        if UserDefaults.group.object(forKey: storageKey) != nil {
//            let value = UserDefaults.group.value(forKey: storageKey)
//
//            if let casted = value as? Value {
//                return casted
//            }
//        }
//
//        return defaultValue
//    }
//
//    func storeValue(_ newValue: Value) {
//        UserDefaults.group.set(newValue, forKey: storageKey)
//    }
//
//    init(_ key: String, defaultValue: Value) where Value: RawRepresentable, Value.RawValue == Int {
//        self.storageKey = key
//        self.defaultValue = defaultValue
//        self.storedValue = defaultValue
////        self.retrieveValue = customRetrieveValue
//
//        self.storedValue = retrieveValue()
//    }
//
//    var wrappedValue: Value {
//        get {
//            storedValue
//        }
//
//        set {
//            if newValue != storedValue {
//                storeValue(newValue)
//
//                storedValue = newValue
//            }
//        }
//    }
//}
//
//extension StorableState where Value == Bool {
//    func retrieveValue() -> Value {
//        UserDefaults.group.bool(forKey: storageKey)
//    }
//
//    func storeValue(_ newValue: Value) {
//        UserDefaults.group.set(newValue, forKey: storageKey)
//    }
//
//    init(_ key: String, defaultValue: Value) where Value == Bool {
//        self.storageKey = key
//        self.defaultValue = defaultValue
//        self.storedValue = defaultValue
////        self.retrieveValue = customRetrieveValue
//
//        self.storedValue = retrieveValue()
//    }
//
//    var wrappedValue: Value {
//        get {
//            storedValue
//        }
//
//        set {
//            if newValue != storedValue {
//                storeValue(newValue)
//
//                storedValue = newValue
//            }
//        }
//    }
//}

//extension StorableState where Value: RawRepresentable, Value.RawValue == Int {
//    func storeValue(_ newValue: Value) {
//        UserDefaults.group.set(newValue, forKey: storageKey)
//    }
//
//    init(key: String, defaultValue: Value) {
//        self.storageKey = key
//        self.defaultValue = defaultValue
//
//        if UserDefaults.group.object(forKey: storageKey) != nil {
//            let value = UserDefaults.group.value(forKey: storageKey)
//
//            if let casted = value as? Value {
//                storedValue = casted
//
//                return
//            }
//        }
//
//        storedValue = defaultValue
//    }
//
//    var wrappedValue: Value {
//        get {
//            storedValue
//        }
//
//        set {
//            if newValue != storedValue {
//                storeValue(newValue)
//
//                storedValue = newValue
//            }
//        }
//    }
//}
//
//extension StorableState where Value == Bool {
//    func storeValue(_ newValue: Value) {
//        UserDefaults.group.set(newValue, forKey: storageKey)
//    }
//
//    init(key: String, defaultValue: Value) {
//        self.storageKey = key
//        self.defaultValue = defaultValue
//
//        storedValue = UserDefaults.group.bool(forKey: storageKey)
//    }
//
//    var wrappedValue: Value {
//        get {
//            storedValue
//        }
//
//        set {
//            if newValue != storedValue {
//                storeValue(newValue)
//
//                storedValue = newValue
//            }
//        }
//    }
//}

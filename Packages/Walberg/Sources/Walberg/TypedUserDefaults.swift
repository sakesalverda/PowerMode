//
//  File.swift
//  
//
//  Created by Sake Salverda on 17/03/2024.
//

import SwiftUI
import OSLog

fileprivate let logger = Logger(subsystem: "nl.sakesalverda.Walberg", category: "typeduserdefaults")

extension TypedUserDefaults {
    public convenience init(_ key: String, value: Value, store: UserDefaults? = nil) where Value == Bool {
        let store = store ?? .standard
        
        self.init(key: key, store: store, defaultValue: value, unwrap: {
            ($0 as? Value)
        }, wrap: { $0 })
    }
    
    public convenience init(_ key: String, value: Value, store: UserDefaults? = nil) where Value == Int {
        let store = store ?? .standard
        
        self.init(key: key, store: store, defaultValue: value, unwrap: {
            ($0 as? Value)
        }, wrap: { $0 })
    }
    
    public convenience init(_ key: String, value: Value, store: UserDefaults? = nil) where Value == Double {
        let store = store ?? .standard
        
        self.init(key: key, store: store, defaultValue: value, unwrap: {
            ($0 as? Value)
        }, wrap: { $0 })
    }
    
    public convenience init(_ key: String, value: Value, store: UserDefaults? = nil) where Value == String {
        let store = store ?? .standard
        
        self.init(key: key, store: store, defaultValue: value, unwrap: {
            ($0 as? Value)
        }, wrap: { $0 })
    }
    
    public convenience init(_ key: String, value: Value, store: UserDefaults? = nil) where Value == URL {
        let store = store ?? .standard
        
        self.init(key: key, store: store, defaultValue: value, unwrap: {
            ($0 as? Value)
        }, wrap: { $0 })
    }
    
    public convenience init(_ key: String, value: Value, store: UserDefaults? = nil) where Value == Data {
        let store = store ?? .standard
        
        self.init(key: key, store: store, defaultValue: value, unwrap: {
            ($0 as? Value)
        }, wrap: { $0 })
    }
    
    public convenience init(_ key: String, value: Value, store: UserDefaults? = nil) where Value: Codable {
        let store = store ?? .standard
        
        self.init(key: key, store: store, defaultValue: value, unwrap: {
            if let data = $0 as? Data {
                return try? JSONDecoder().decode(Value.self, from: data)
            }
            return nil
        }, wrap: { try? JSONEncoder().encode($0) })
    }
    
    public convenience init(_ key: String, value: Value, store: UserDefaults? = nil) where Value : RawRepresentable, Value.RawValue == Int {
        let store = store ?? .standard
        
        self.init(key: key, store: store, defaultValue: value, unwrap: {
            guard let raw = $0 as? Value.RawValue else { if key == "pref_menu_iconVariant" { print("Failed unwrapping an Int") }; return nil }
            
            return Value.init(rawValue: raw)
        }, wrap: { $0.rawValue })
    }
    
    public convenience init(_ key: String, value: Value, store: UserDefaults? = nil) where Value : RawRepresentable, Value.RawValue == UInt8 {
        let store = store ?? .standard
        
        self.init(key: key, store: store, defaultValue: value, unwrap: {
            guard let raw = $0 as? Value.RawValue else { return nil }
            
            return Value.init(rawValue: raw)
        }, wrap: { $0.rawValue })
    }
    
    public convenience init(_ key: String, value: Value, store: UserDefaults? = nil) where Value : RawRepresentable, Value.RawValue == String {
        let store = store ?? .standard
        
        self.init(key: key, store: store, defaultValue: value, unwrap: {
            guard let raw = $0 as? Value.RawValue else { return nil }
            
            return Value.init(rawValue: raw)
        }, wrap: { $0.rawValue })
    }
}

extension TypedUserDefaults where Value: ExpressibleByNilLiteral {
    public convenience init(_ key: String, store: UserDefaults? = nil) where Value == Bool? {
        let store = store ?? .standard
        
        self.init(key: key, store: store, defaultValue: nil, unwrap: {
            ($0 as? Value)
        }, wrap: { $0 })
    }
    
    public convenience init(_ key: String, store: UserDefaults? = nil) where Value == Int? {
        let store = store ?? .standard
        
        self.init(key: key, store: store, defaultValue: nil, unwrap: {
            ($0 as? Value)
        }, wrap: { $0 })
    }
    
    public convenience init(_ key: String, store: UserDefaults? = nil) where Value == Double? {
        let store = store ?? .standard
        
        self.init(key: key, store: store, defaultValue: nil, unwrap: {
            ($0 as? Value)
        }, wrap: { $0 })
    }
    
    public convenience init(_ key: String, store: UserDefaults? = nil) where Value == String? {
        let store = store ?? .standard
        
        self.init(key: key, store: store, defaultValue: nil, unwrap: {
            ($0 as? Value)
        }, wrap: { $0 })
    }
    
    public convenience init(_ key: String, store: UserDefaults? = nil) where Value == URL? {
        let store = store ?? .standard
        
        self.init(key: key, store: store, defaultValue: nil, unwrap: {
            ($0 as? Value)
        }, wrap: { $0 })
    }
    
    public convenience init(_ key: String, store: UserDefaults? = nil) where Value == Data? {
        let store = store ?? .standard
        
        self.init(key: key, store: store, defaultValue: nil, unwrap: {
            ($0 as? Value)
        }, wrap: { $0 })
    }
}


extension TypedUserDefaults {
    public convenience init<R>(_ key: String, store: UserDefaults? = nil) where Value == R?, R : RawRepresentable, R.RawValue == String {
        let store = store ?? .standard
        
        self.init(key: key, store: store, defaultValue: nil, unwrap: {
            guard let raw = $0 as? R.RawValue else { return nil }
            
            return R.init(rawValue: raw)
        }, wrap: { $0?.rawValue })
    }
    
    public convenience init<R>(_ key: String, store: UserDefaults? = nil) where Value == R?, R : RawRepresentable, R.RawValue == Int {
        let store = store ?? .standard
        
        self.init(key: key, store: store, defaultValue: nil, unwrap: {
            guard let raw = $0 as? R.RawValue else { return nil }
            
            return R.init(rawValue: raw)
        }, wrap: { $0?.rawValue })
    }
    
    public convenience init<R>(_ key: String, store: UserDefaults? = nil) where Value == R?, R : RawRepresentable, R.RawValue == UInt8 {
        let store = store ?? .standard
        
        self.init(key: key, store: store, defaultValue: nil, unwrap: {
            guard let raw = $0 as? R.RawValue else { return nil }
            
            return R.init(rawValue: raw)
        }, wrap: { $0?.rawValue })
    }
}

@Observable
public class TypedUserDefaults<Value: Equatable>: NSObject {
    typealias Transform = (Any?) -> Value?
    typealias Save = (Value) -> Any?
    
    private let key: String
    private let store: UserDefaults
    public let defaultValue: Value
    
    dynamic private let unwrap: Transform
    dynamic private let wrap: Save
    
    private var _storedValue: Value
    
    init(key: String, store: UserDefaults, defaultValue: Value, unwrap: @escaping Transform, wrap: @escaping Save) {
        self.key = key
        self.store = store
        self.defaultValue = defaultValue
        self.unwrap = unwrap
        self.wrap = wrap
        
        self._storedValue = unwrap(store.object(forKey: key)) ?? defaultValue
        
        super.init()
        
        store.addObserver(self, forKeyPath: key, options: .new, context: nil)
    }
    
    public override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        // Ensure keyPath matches our expected key
        if keyPath == key {
            let newValue = unwrap(change?[.newKey]) ?? defaultValue
            
            if newValue != _storedValue {
                _storedValue = newValue
            }
        }
    }
    
    deinit {
        store.removeObserver(self, forKeyPath: key, context: nil)
    }
    
    /// Restore a value from another userdefaults source
    public func restore(_ input: Any?) {
        store.set(input, forKey: key)
    }
    
    public var wrappedValue: Value {
        get {
            _storedValue ?? defaultValue
        }
        
        set {
            if newValue != _storedValue {
                // update the cached variable
                _storedValue = newValue
                
                // update persisted value
                store.set(wrap(newValue), forKey: key)
            }
        }
    }
    
    public var projectedValue: Binding<Value> {
        .init {
            self.wrappedValue
        } set: { newValue in
            self.wrappedValue = newValue
        }
    }
}


/*public struct DeprTypedUserDefaults<Value> {
    typealias Transform = (Any?) -> Value?
    typealias Save = (Value) -> Any?
    
    private let key: String
    private let store: UserDefaults
    public let defaultValue: Value
    
    private let transform: Transform
    private let save: Save
    
    init(key: String, store: UserDefaults, defaultValue: Value, unwrap: @escaping Transform, wrap: @escaping Save) {
        self.key = key
        self.store = store
        self.defaultValue = defaultValue
        self.transform = unwrap
        self.save = wrap
    }
    
    public func restore(_ input: Any?) {
        store.set(input, forKey: key)
    }
    
//    init(_ key: Key, store: UserDefaults, defaultValue: Value, unwrap: @escaping (Any?) -> Value?, wrap: @escaping (Value) -> Void) where Key: RawRepresentable, Key.RawValue == String {
//        self.key = key.rawValue
//        self.store = store
//        self.defaultValue = defaultValue
//        self.transform = transform
//        self.save = save
//    }
    
    public var wrappedValue: Value {
        get {
            store.object(forKey: key).flatMap(transform) ?? defaultValue
        }
        
        nonmutating set {
            store.set(save(newValue), forKey: key)
//            save(newValue)
        }
    }
    
    public var projectedValue: Binding<Value> {
        .init {
            wrappedValue
        } set: { newValue in
            wrappedValue = newValue
        }
    }
}*/

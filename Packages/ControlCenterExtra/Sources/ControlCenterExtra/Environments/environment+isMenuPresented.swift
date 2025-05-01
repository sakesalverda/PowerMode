//
//  isMenuPresented.swift
//  PowerMode
//
//  Created by Sake Salverda on 16/01/2024.
//

import SwiftUI

struct IsMenuPresentedKey: EnvironmentKey {
    static let defaultValue: Bool = false
//    static let defaultValue: IsMenuPresentedKey = .init(wrappedValue: false)
    
    var wrappedValue: Bool
}

extension EnvironmentValues {    
    public var isMenuPresented: Bool {
        get { self[IsMenuPresentedKey.self] }
        set { self[IsMenuPresentedKey.self] = newValue}
    }
}


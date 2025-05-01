//
//  SwiftUIView.swift
//  
//
//  Created by Sake Salverda on 18/01/2024.
//

import SwiftUI

struct AltKeyManagerKey: EnvironmentKey {
    static let defaultValue: AltKeyManager? = nil
}

struct AltKeyPressedKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    public var isAltKeyPressed: Bool {
        get { self[AltKeyPressedKey.self] }
        set { self[AltKeyPressedKey.self] = newValue }
    }
}

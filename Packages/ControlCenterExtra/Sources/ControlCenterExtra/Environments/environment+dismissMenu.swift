//
//  DismissMenu.swift
//  PowerMode
//
//  Created by Sake Salverda on 16/01/2024.
//

import SwiftUI

public struct DismissMenuAction: EnvironmentKey {
    public static let defaultValue: DismissMenuAction = .init {}
    
    typealias Callback = () -> Void
    
    private var callback: Callback
    
    init(perform action: @escaping Callback) {
        self.callback = action
    }
    
    public func callAsFunction() {
        callback()
    }
}

extension EnvironmentValues {
    public var dismissMenu: (DismissMenuAction) {
        get { self[DismissMenuAction.self] }
        set { self[DismissMenuAction.self] = newValue}
    }
}

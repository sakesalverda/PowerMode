//
//  UpdateSizeAction.swift
//  MemoryReleaseIssueDemo
//
//  Created by Sake Salverda on 18/01/2024.
//

import SwiftUI

struct UpdateSizeAction {
    typealias Action = (_ size: CGSize, _ useAnimation: Bool) -> Void

    let action: Action

    func callAsFunction(size: CGSize, useAnimation: Bool = true) {
        action(size, useAnimation)
    }
}

private struct UpdateSizeKey: EnvironmentKey {
    static var defaultValue: UpdateSizeAction?
}

extension EnvironmentValues {
    var updateSize: UpdateSizeAction? {
        get { self[UpdateSizeKey.self] }
        set { self[UpdateSizeKey.self] = newValue }
    }
}

extension View {
    /// Adds an action to perform when a child view reports that it has resized.
    /// - Parameter action: The action to perform.
    func onSizeUpdate(_ action: @escaping (_ size: CGSize, _ useAnimation: Bool) -> Void) -> some View {
        let action = UpdateSizeAction { size, useAnimation in
            action(size, useAnimation)
        }

        return environment(\.updateSize, action)
    }
}

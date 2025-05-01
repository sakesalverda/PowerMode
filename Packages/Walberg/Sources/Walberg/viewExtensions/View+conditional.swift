//
//  View+conditional.swift
//  
//
//  Created by Sake Salverda on 05/02/2024.
//

import SwiftUI

// extension for conditional viewModifiers
public extension View {
    @ViewBuilder func unwrapped<Value, T>(
        _ condition: Value?,
        @ViewBuilder transform: (Self) -> some View
    ) -> some View where Value == Optional<T> {
        if let condition {
            transform(self)
        } else {
            self
        }
    }
    
    @ViewBuilder func unwrapped<Value>(
        _ condition: Value?,
        @ViewBuilder transform: (Self, Value) -> some View
    ) -> some View {
        if let v = condition {
            transform(self, v)
        } else {
            self
        }
    }
    
    // DO NOT USE WITH ANY DYNAMIC, see https://www.objc.io/blog/2021/08/24/conditional-view-modifiers/
    
    /// Conditional
    /// **The condition must be static!!**
    @ViewBuilder func conditional(
        _ condition: Bool,
        @ViewBuilder transform: (Self) -> some View
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

#Preview {
    VStack {
        let bool: Bool? = true
        
        Text("Test")
            .conditional(true) {
                $0.foregroundStyle(.green)
            }
        
        Text("Test")
            .unwrapped(bool) { content, value in
//                Text("\(value)")
            }
        
        Text("Test")
            .unwrapped(bool) {
                $0.foregroundStyle(.green)
            }
    }
    .padding()
}

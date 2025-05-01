//
//  StatePreviewWrapper.swift
//
//
//  Created by Sake Salverda on 05/02/2024.
//

import SwiftUI

// source: https://github.com/AlanQuatermain/AQUI/blob/master/Sources/AQUI/StatefulPreviewWrapper.swift

/// Allows for a single state variable to be used in a preview
public struct StatePreviewWrapper<Value, Content: View>: View {
    @State var value: Value
    var content: (Binding<Value>) -> Content

    public var body: some View {
        content($value)
    }

    public init(_ value: Value, content: @escaping (Binding<Value>) -> Content) {
        self._value = State(wrappedValue: value)
        self.content = content
    }
}

#Preview {
    StatePreviewWrapper(true) { binding in
        Toggle("Toggle", isOn: binding)
    }
}

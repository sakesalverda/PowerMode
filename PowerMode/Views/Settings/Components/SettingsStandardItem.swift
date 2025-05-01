//
//  SettingsStandardItem.swift
//  PowerMode
//
//  Created by Sake Salverda on 23/01/2024.
//

import SwiftUI

struct SettingsStandardItem<Label: View>: View {
    var label: Label
    
    @Binding var binding: Bool
    
    init(label: () -> Label, binding: Binding<Bool>) {
        self.label = label()
        self._binding = binding
    }
    
    init(label: String, binding: Binding<Bool>) where Label == Text {
        self.label = Text(label)
        self._binding = binding
    }
    
    var body: some View {
        Toggle(isOn: $binding) {
            SettingsLabel {
                label
            }
        }
        .toggleStyle(.switch)
        .controlSize(.mini)
    }
}

struct SettingsLabel<Content: View>: View {
    var content: Content
    
    @Environment(\.isEnabled) private var isEnabled
    
    init(content: () -> Content) {
        self.content = content()
    }
    
    init(_ title: String) where Content == Text {
        self.content = Text(title)
    }
    
    init(_ title: LocalizedStringKey) where Content == Text {
        self.content = Text(title)
    }
    
    var body: some View {
        content
            .padding(.trailing, 20)
            .opacity(isEnabled ? 1 : 0.33)
    }
}

#Preview {
    SettingsPreview {
        SettingsStandardItem(label: "Some enabled item", binding: .constant(true))
        
        Toggle("Some enabled item", isOn: .constant(true))
            .toggleStyle(.switch)
            .controlSize(.mini)
        
        SettingsStandardItem(label: "Some disabled item", binding: .constant(true))
            .disabled(true)
    }
}

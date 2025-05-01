//
//  SettingsItem.swift
//  PowerMode
//
//  Created by Sake Salverda on 23/01/2024.
//

import SwiftUI

struct SettingsItem<Label: View, Content: View>: View {
    var label: Label
    
    var content: Content
    
    init(label: () -> Label, @ViewBuilder content: () -> Content) {
        self.label = label()
        self.content = content()
    }
    
    init(label: Label, @ViewBuilder content: () -> Content) {
        self.label = label
        self.content = content()
    }
    
    init(_ label: String, @ViewBuilder content: () -> Content) where Label == Text {
        self.label = Text(label)
        self.content = content()
    }
    
    var body: some View {
        HStack(alignment: .top) {
            SettingsLabel {
                VStack(alignment: .leading) {
                    label
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Spacer(minLength: 0)
            
            HStack {
                content
            }
        }
    }
}

#Preview {
    SettingsPreview {
        // even though we use Toggle's here, please use SettingsToggleItem for that
        SettingsItem("Some enabled item") {
            Toggle(isOn: .constant(true)) {}
        }
        
        SettingsItem("Some disabled item") {
            Toggle(isOn: .constant(true)) {}
        }
        .disabled(true)
    }
    .padding()
}

//
//  SwiftUIView.swift
//  
//
//  Created by Sake Salverda on 18/01/2024.
//

import SwiftUI
import SettingsAccess

extension MenuSettingsLink {
    public init(_ title: LocalizedStringKey) where Label == HStack<TupleView<(Text,Spacer)>> {
        self.label = {
            HStack {
                Text(title)
                
                Spacer()
            }
        }
    }
    
    public init<S>(_ title: S) where S: StringProtocol, Label == HStack<TupleView<(Text,Spacer)>> {
        self.label = {
            HStack {
                Text(title)
                
                Spacer()
            }
        }
    }
}

public struct MenuSettingsLink<Label: View>: View {
    @Environment(\.dismissMenu) private var dismissMenu
    
    private var label: () -> Label
    
    public init(@ViewBuilder label: @escaping () -> Label) {
        self.label = label
    }
    
    public var body: some View {
        SettingsLink(label: label, preAction: {
            NSApp.activate()
            
            dismissMenu()
        }, postAction: {
            
        })
    }
}

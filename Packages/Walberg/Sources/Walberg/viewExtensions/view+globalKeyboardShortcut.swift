//
//  File.swift
//  
//
//  Created by Sake Salverda on 31/03/2024.
//

import SwiftUI

fileprivate struct KeyboardButton: View {
    var action: () -> ()
    
    var body: some View {
        Button(action: action) {}
            .buttonStyle(.plain)
            .allowsHitTesting(false)
            .hidden()
    }
}

extension View {
    public func globalKeyboardShortcut(_ shortcut: KeyboardShortcut, perform: @escaping () -> ()) -> some View {
        self.background {
            KeyboardButton(action: perform)
                .keyboardShortcut(shortcut)
        }
    }
    
    public func globalKeyboardShortcut(_ shortcut: KeyboardShortcut?, perform: @escaping () -> ()) -> some View {
        self.background {
            KeyboardButton(action: perform)
                .keyboardShortcut(shortcut)
        }
    }
    
    public func globalKeyboardShortcut(_ key: KeyEquivalent, modifiers: EventModifiers = .command, perform: @escaping () -> ()) -> some View {
        self.background {
            KeyboardButton(action: perform)
                .keyboardShortcut(key, modifiers: modifiers)
        }
    }
    
    public func globalKeyboardShortcut(_ key: KeyEquivalent, modifiers: EventModifiers = .command, localization: KeyboardShortcut.Localization, perform: @escaping () -> ()) -> some View {
        self.background {
            KeyboardButton(action: perform)
                .keyboardShortcut(key, modifiers: modifiers, localization: localization)
        }
    }
}

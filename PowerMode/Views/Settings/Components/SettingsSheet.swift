//
//  SettingsSheet.swift
//  PowerMode
//
//  Created by Sake Salverda on 04/02/2024.
//

import SwiftUI

extension View {
    func readIntrinsicContentSize(to size: Binding<CGSize?>) -> some View {
        background(GeometryReader { proxy in
            Color.clear.preference(
                key: IntrinsicContentSizePreferenceKey.self,
                value: proxy.size
            )
        })
        .onPreferenceChange(IntrinsicContentSizePreferenceKey.self) {
            size.wrappedValue = $0
        }
    }
}

struct IntrinsicContentSizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize? = nil

    static func reduce(value: inout CGSize?, nextValue: () -> CGSize?) {
        let otherSize = nextValue()
        
        if otherSize == nil {
            return
        }
        
        value = otherSize
    }
}

struct SettingsSheet<Content: View, Dismiss: View>: View {
    private var title: Text
    private var content: Content
    private var dismissContent: Dismiss
    
    @State private var sheetSize: CGSize? = nil
    
    @Environment(\.dismiss) private var dismiss
    
    init(_ title: String, dismiss: String = "Dismiss", @ViewBuilder content: () -> Content) where Dismiss == Text {
        self.title = Text(title)
        self.content = content()
        self.dismissContent = Text(dismiss)
    }
    
    private var sheetHeight: CGFloat {
        let height = sheetSize?.height ?? 0
        
        if height < 320 {
            return 320
        } else if height > 500 {
            return 500
        } else {
            return height
        }
    }
    
    var body: some View {
        ScrollView {
            VStack {
                title
                    .font(.title2.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .padding(.vertical)
                    .fixedSize(horizontal: false, vertical: true)
                
                VStack(alignment: .leading, spacing: 8) {
                    content
                }
                .frame(maxWidth: .infinity)
                .fixedSize(horizontal: false, vertical: true)
                
                Spacer(minLength: 30)
                
                if Dismiss.self == Text.self {
                    Button(action: {
                        dismiss()
                    }) {
                        ZStack {
                            Text("Cancel")
                                .hidden()
                                .accessibilityHidden(true)
                            
                            dismissContent
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(.defaultAction)
                } else {
                    dismissContent
                }
            }
            .scenePadding()
            .frame(minHeight: 320)
            .readIntrinsicContentSize(to: $sheetSize)
        }
        .scrollBounceBehavior(.basedOnSize)
        .frame(width: 340, height: sheetHeight, alignment: .topLeading)
    }
}

#Preview {
    SettingsSheet("Test") {
        Text("Some more text")
    }
}

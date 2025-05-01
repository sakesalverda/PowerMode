//
//  InfoButton.swift
//  PowerMode
//
//  Created by Sake Salverda on 05/02/2024.
//

import SwiftUI

struct InfoButtonModifier<SheetContent: View>: ViewModifier {
    @State var isPresented: Bool = false
    
    var sheetContent: SheetContent
    
    init(sheet: () -> SheetContent) {
        self.sheetContent = sheet()
    }
    
    func body(content: Content) -> some View {
        HStack(alignment: .firstTextBaseline) {
            content
            
            Button(action: {
                isPresented = true
            }) {
                Image(systemName: "info.circle")
            }
            .buttonStyle(.plain)
            .sheet(isPresented: $isPresented) {
                sheetContent
            }
        }
    }
}

extension View {
//    func infoButton(action: @escaping () -> Void) -> some View {
//        HStack(alignment: .firstTextBaseline) {
//            self
//
//            Button(action: action) {
//                Image(systemName: "info.circle")
//            }
//            .buttonStyle(.plain)
//        }
//    }
    
    func infoButton<Content: View>(@ViewBuilder sheet: @escaping () -> Content) -> some View {
        modifier(InfoButtonModifier(sheet: sheet))
    }
}

#Preview {
    Text("Some text with info button")
        .infoButton {
            Text("Some text that will not show")
        }
        .padding()
}

//
//  View+extensions.swift
//  PowerMode
//
//  Created by Sake Salverda on 05/02/2024.
//

import SwiftUI

extension View {
    func settingsSubheadline() -> some View {
        self.font(.subheadline)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.trailing, 40)
            .offset(x: 0, y: 0)
            .padding(.bottom, -2)
            .frame(maxWidth: 320, alignment: .leading)
    }
}

#Preview {
    Text("Lorem Ipsum")
        .settingsSubheadline()
}

//
//  View+hidden.swift
//  
//
//  Created by Sake Salverda on 05/02/2024.
//

import SwiftUI

// extension for conditional hidden given a boolean
public extension View {
    /// Conditionally hide a view
    @ViewBuilder func hidden(_ isHidden: Bool) -> some View {
        if isHidden {
            self.hidden()
        } else {
            self
        }
    }
}

#Preview {
    VStack {
        Text("Some text").hidden(false)
        
        Text("Some text").hidden(true)
    }
}

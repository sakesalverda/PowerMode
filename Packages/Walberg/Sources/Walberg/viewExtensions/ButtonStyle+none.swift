//
//  File.swift
//  
//
//  Created by Sake Salverda on 05/02/2024.
//

import SwiftUI

public struct NoneButtonStyle: PrimitiveButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

extension PrimitiveButtonStyle where Self == NoneButtonStyle {
    public static var none: NoneButtonStyle {
        NoneButtonStyle()
    }
}

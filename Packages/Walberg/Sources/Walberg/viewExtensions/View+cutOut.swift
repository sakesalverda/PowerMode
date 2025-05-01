//
//  SwiftUIView.swift
//  
//
//  Created by Sake Salverda on 05/02/2024.
//

import SwiftUI

// @article: https://www.fivestars.blog/articles/reverse-masks-how-to/

extension View {
//    @available(*, deprecated, message: "please use a compositingGroup() and blendMode(.destinationOut)")
//    @inlinable public func reverseMask<Mask: View>(
//        alignment: Alignment = .center,
//        @ViewBuilder _ mask: () -> Mask
//    ) -> some View {
//        self.mask {
//            Rectangle()
//                .foregroundStyle(.black) // just needs to be any solid color
//                .overlay(alignment: alignment) {
//                    mask()
//                        .blendMode(.destinationOut)
//                }
//        }
//    }
    
    // https://stackoverflow.com/a/64209063/3711267
    public func cutout<Cutout: View>(alignment: Alignment =  .center, @ViewBuilder _ mask: () -> Cutout) -> some View {
            self
                .overlay(alignment: alignment) {
                    mask()
                        .foregroundStyle(.black) // just needs any non-opaque foregroundStyle
                        .blendMode(.destinationOut)
                }
                .compositingGroup()
    }
}

// MARK: Preview

#Preview {
    ZStack {
        Color.red
        
        Color.black
            .cutout {
                VStack {
                    Text("Test")
                    
                    Image(systemName: "play.circle.fill")
                        
                }
                .font(.title)
            }
            .frame(height: 150)
    }
    
    .frame(width: 200, height: 200)
}

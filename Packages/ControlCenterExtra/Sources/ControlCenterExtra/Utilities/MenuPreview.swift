//
//  ControlCenterPreview.swift
//  PowerMode
//
//  Created by Sake Salverda on 16/01/2024.
//

import SwiftUI

/// Utility tool to enable previews of 
public struct MenuPreview<Content: View>: View {
    private var content: Content
    
    public init(@ViewBuilder _ content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            MenuRoot {
                content
            }
        }
        
        .buttonStyle(.controlCenter)
        .toggleStyle(.controlCenter)
        
//        .menuInset(.horizontal, to: .content)
        .menuInset(.top, to: .content)
        .menuInset(.bottom, to: .content)
        
        .frame(width: MenuGeometry.menuWindowWidth)
        .frame(minHeight: 200)
    }
}

//#Preview {
//    Text("Test")
//        .onAppear {
//            print(NSMenu.didBeginTrackingNotification.rawValue)
//        }
//}

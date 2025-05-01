//
//  View+onGlobalHover.swift
//  PowerMode
//
//  Created by Sake Salverda on 17/01/2024.
//

import SwiftUI

// why? Here's why:
// the SwiftUI onHover can be buggy when the mouse is moving out fast (i.e. then the last hovering = false is not triggered)
//
// this implementation uses the suggestion from https://stackoverflow.com/a/67951126/3711267
// to keep track of which element is currently receiving the hover

//@Observable
//fileprivate class GlobalHoverableState {
//    static let shared = GlobalHoverableState()
//    
//    var currentHoveredTarget: UUID? = nil
//}
//
//struct GlobalHoverModifier: ViewModifier {
//    @State private var id: UUID = .init()
//    
//    @State private var didCallEnd: Bool = false
//    @State private var didCallStart: Bool = false
//    
//    var action: (Bool) -> Void
//    
//    init(perform action: @escaping (Bool) -> Void) {
//        self.action = action
//    }
//    
//    func body(content: Content) -> some View {
//        content.onHover { isHovering in
//            if isHovering {
//                GlobalHoverableState.shared.currentHoveredTarget = id
//            } else {
//                if GlobalHoverableState.shared.currentHoveredTarget == id {
//                    GlobalHoverableState.shared.currentHoveredTarget = nil
//                }
//            }
//        }
//        .onChange(of: GlobalHoverableState.shared.currentHoveredTarget) { oldValue, newValue in
//            // if the newValue IS NOT this item
//            // AND
//            //
//            // the callback has not been called yet
//            // OR
//            // the oldValue was this item (i.e. hover target changed)
//            if newValue != id && (!didCallEnd || oldValue == id)  {
//                action(false)
//                
//                didCallStart = false
//                didCallEnd = true
//            }
//            
//            // if the newValue IS this item
//            // AND
//            //
//            // the callback has not been called yet
//            // OR
//            // the oldValue was NOT this item (i.e. hover target changed)
//            if newValue == id && (!didCallStart || oldValue != id) {
//                didCallEnd = false
//                didCallStart = true
//                
//                action(true)
//            }
//        }
//    }
//}
//
//extension View {
//    public func onGlobalHover(perform action: @escaping (Bool) -> Void) -> some View {
//        modifier(GlobalHoverModifier(perform: action))
//    }
//}

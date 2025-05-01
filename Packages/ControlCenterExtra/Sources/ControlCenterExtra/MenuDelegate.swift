//
//  ControlCenterDelegate.swift
//  PowerMode
//
//  Created by Sake Salverda on 16/01/2024.
//

import Foundation

@Observable
open class MenuDelegate {
//    var disableHeightAnimationOnAlt: Bool = true
    
    var isMenuPresented: Bool = false
    
    var isInserted: Bool = true
    
    func dismissMenu() {
        isMenuPresented = false
    }
    
    public init() {
        
    }
}

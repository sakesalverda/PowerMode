//
//  HelperToolConstants.swift
//  PowerMode
//
//  Created by Sake Salverda on 29/11/2023.
//

import Foundation

enum HelperConstants {
    /// Helper connection identifier
    static let mach = "\(Constants.bundle).xpc"
    
    /// Helper plist file
    static let daemon = "nl.sakesalverda.powermode.helper.plist"

    /// Main application bundle
    static let bundle: String = Constants.bundle
    
    /// Helper bundle identifier
    static let helperBundle = "\(Constants.bundle).helper"
    
    #if DEBUG
    static let subjectCN = "Apple Development: mail@sakesalverda.nl (W43PXM289Q)"
    #endif
    static let subjectOU = "TBPWL3H93F"
}

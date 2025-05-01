//
//  Constants.swift
//  PowerMode
//
//  Created by Sake Salverda on 09/12/2023.
//

import Foundation

// extension to detect whether in XCode SwiftUI preview mode
fileprivate extension ProcessInfo {
    var isSwiftUIPreview: Bool {
        environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}

public enum Constants {
    static let isPreview = ProcessInfo.processInfo.isSwiftUIPreview
    
    /// Bundle identifier used by daemon to check for app activity
    static let bundle = "nl.sakesalverda.PowerMode"
    
    static let company = "Sake Salverda"
    
    static let menuWindowWidth: CGFloat = 300
    
    /// Variable representing the delay between an interaction in the app and an update to the widgets
    static let widgetRefreshTimeout: Double = 0.3
    
    /// Variable representing the interval for retrieving updates values that weren't initiated within the app
    static let retrieveInterval: Double = 30
}

public enum Links {
    static let mainText = "https://sakesalverda.nl/PowerMode/"
    static let main = "https://sakesalverda.nl/powermode/"
    
    static let donate = "https://sakesalverda.nl/PowerMode/donate"
    static let donateIntent = "https://sakesalverda.nl/PowerMode/donate?intent=%@&locale=%@"
    
    static let support = "https://sakesalverda.nl/PowerMode/support"
}

public extension UserDefaults {
    static let group = UserDefaults(suiteName: "TBPWL3H93F.nl.sakesalverda.PowerMode")!
}

//
//  Bundle+extensions.swift
//  PowerMode
//
//  Created by Sake Salverda on 21/02/2024.
//

import Foundation

extension Bundle {
    var name: String? { infoDictionary?["CFBundleName"] as? String }
    
    var displayName: String? { infoDictionary?["CFBundleDisplayName"] as? String }
    
    var identifier: String? { infoDictionary?["CFBundleIdentifier"] as? String }
    
    var copyright: String? { infoDictionary?["NSHumanReadableCopyright"] as? String }
    
    var version: String? { infoDictionary?["CFBundleShortVersionString"] as? String }
    
    var build: String? { infoDictionary?["CFBundleVersion"] as? String }
}

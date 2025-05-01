//
//  HelperError.swift
//  PowerMode
//
//  Created by Sake Salverda on 29/11/2023.
//

import Foundation

enum HelperToolError: Error, LocalizedError {
    // errors within the app
    case helperInstallation(String)
    case helperConnection(String)
    case notInstalled
    
    // errors within helper
    case processError(String)
    case invalidInput(String)
    
    // errors with SMC
    case openSMC
    case setSMC(key: String, value: UInt8)
    case getSMC(String)
    
    case noVersion
    
    case timeoutError
    
    // default unknown error
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .helperInstallation(let description): "Helper installation error. \(description)"
        case .helperConnection(let description): "Helper connection error. \(description)"
        case .notInstalled: "Helper is not installed"
            
        case .openSMC: "Helper cannot open SMC"
        case .setSMC(let key, let value): "Could not set \(key) to \(value)"
        case .getSMC(let key): "Could not obtain SMC value for \(key)"
            
        case .processError(let description): "Helper pmset set error. \(description)"
        case .invalidInput(let description): "Invalid input given to helper. \(description)"
            
        case .noVersion: "Helper bundle does not have version in bundle identifier"
            
        case .timeoutError: "Connection to helper timed out"
            
        case .unknown: "Unknown error"
        }
    }
}

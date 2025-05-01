//
//  DonationModel.swift
//  PowerMode
//
//  Created by Sake Salverda on 12/02/2024.
//

import Foundation

enum DonationError: Error, Equatable {
    case decoding
    case session
    case url
    case response(DonationErrorResponse.ErrorObject)
    
    var localizedDescription: String {
        switch self {
        case .response(let error):
            "Api returned with error, code: \(error.code), type: \(error.type)"
        case .session:
            "Could not initiate url session"
        case .url:
            "Could not convert input string to URL object"
        case .decoding:
            "Could not decode response to donation localization options"
        }
    }
}

struct DonationErrorResponse: Decodable {
    let success: Bool
    let error: ErrorObject
    
    struct ErrorObject: Decodable, Error, Equatable {
        let code: Int
        let type: String
        let message: String
    }
}

struct DonationOptions: Decodable {
    /// String indicaitng the currency locale of the options
    let locale: String
    
    /// A double indicating the suggested lower amount in the given locale
    let suggestedAmount: Double?
    
    let options: LocalizedDonationOptions?
    
    let links: [LocalizedDonationLink]?
}

struct LocalizedDonationOptions: Decodable {
    /// List of doubles with the respective default donation options for this currency
    let items: [Double]
    
    /// Whether for this locale, custom amounts are allowed
    let customAllowed: Bool
    
    /// The minimum amount for a custom tip
    /// Must be given when customAllowed is true
    let minimumAmount: Double?
}

struct LocalizedDonationLink: Decodable {
    let kind: String
    let title: String
    var message: String?
    let url: URL
    let background: String
    var color: String?
}

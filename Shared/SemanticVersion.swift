//
//  SemanticVersion.swift
//  PowerMode
//
//  Created by Sake Salverda on 15/12/2023.
//

import Foundation

extension SemanticVersion: NSSecureCoding {
    
}

@objc(SemanticVersion)
final class SemanticVersion: NSObject, Codable {
    static var supportsSecureCoding: Bool { true }
    
    func encode(with coder: NSCoder) {
        coder.encode(major, forKey: CodingKeys.major.stringValue)
        coder.encode(minor, forKey: CodingKeys.minor.stringValue)
        coder.encode(patch, forKey: CodingKeys.patch.stringValue)
    }
    
    init?(coder: NSCoder) {
        self.major = coder.decodeInteger(forKey: CodingKeys.major.stringValue)
        self.minor = coder.decodeInteger(forKey: CodingKeys.minor.stringValue)
        self.patch = coder.decodeInteger(forKey: CodingKeys.patch.stringValue)
    }
    
    public let major: Int
    public let minor : Int
    public let patch: Int
    
    public convenience init?(rawValue: String) {
        self.init(version: rawValue)
    }
    
    public convenience init?(version: String) {
        let components = version.split(separator: ".")
        
        guard components.count == 3 else { return nil }

        self.init(major: String(components[0]),
                  minor: String(components[1]),
                  patch: String(components[2]))
    }
    
    private convenience init?(major: String, minor: String, patch: String) {
            guard
                let majorAsInt = Int(major),
                let minorAsInt = Int(minor),
                let patchAsInt = Int(patch)
                else {
                    return nil
            }

            self.init(major: majorAsInt,
                      minor: minorAsInt,
                      patch: patchAsInt)
        }
    
    public init(major: Int, minor: Int, patch: Int) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }
    
    public override var description: String {
        return "\(major).\(minor).\(patch)"
    }
}

extension SemanticVersion: Comparable {
    public static func <(lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
        return (lhs.major < rhs.major)
            || (lhs.major == rhs.major && lhs.minor < rhs.minor)
            || (lhs.major == rhs.major && lhs.minor == rhs.minor && lhs.patch < rhs.patch)
    }
}

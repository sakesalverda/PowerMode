//
//  Helper+ConnectionVerifier.swift
//  nl.sakesalverda.PowerMode.helper
//
//  Created by Sake Salverda on 19/12/2023.
//

extension Helper {
    final class ConnectionVerifier {
        public static func getCodeSignRequirementString(bundle: String, subjectOU: String, subjectCN: String? = nil) -> String {
            var requirementString: String {
                #if DEBUG
                if let subjectCN {
                    let IssuerIsDevelopment = "certificate 1[field.1.2.840.113635.100.6.2.1]"
                    
                    // note that the quotes around subjectCN are only strictly required when it starts with a number
                    return #"identifier "\#(bundle)" and anchor apple generic and certificate leaf[subject.CN] = "\#(subjectCN)" and \#(IssuerIsDevelopment) /* exists */"#
                }
                #endif
                
                let LeafIsMacAppStore = "certificate leaf[field.1.2.840.113635.100.6.1.9]"
                let IssuerIsDeveloperID = "certificate 1[field.1.2.840.113635.100.6.2.6]"
                let LeafIsDeveloperIDApp = "certificate leaf[field.1.2.840.113635.100.6.1.13]"
                
                // note that the quotes around subjectOU are only strictly required when it starts with a number
                return #"anchor apple generic and identifier "\#(bundle)" and (\#(LeafIsMacAppStore) /* exists */ or \#(IssuerIsDeveloperID) /* exists */ and \#(LeafIsDeveloperIDApp) /* exists */ and certificate leaf[subject.OU] = "\#(subjectOU)")"#
            }
            
            var requirementEntitlementString: String {
                var problematicEntitlements = [
                    // do not remove entitlements when they are postfixed with a comment unless you know what you are doing
                    "com.apple.security.get-task-allow", // really highly recommended for RELEASE builds
                    "com.apple.security.cs.allow-jit",
                    "com.apple.security.cs.allow-unsigned-executable-memory",
                    "com.apple.security.cs.allow-dyld-environment-variables", // highly recommended
                    "com.apple.security.cs.disable-library-validation", // highly recommended
                    "com.apple.security.cs.disable-executable-page-protection",
                    "com.apple.security.cs.debugger"
                ]
                #if DEBUG
                // the "com.apple.security.get-task-allow" is added by Xcode in debug builds
                problematicEntitlements.remove(at: 0)
                #endif
                
                return problematicEntitlements.map { entitlement in
                    // the ! to check for the absence of the entitlement
                    // quotes around the entitlement are necessary as they contain dashes
                    #"!entitlement ["\#(entitlement)"] /* exists */"#
                }.joined(separator: " and ")
            }
            
            return "\(requirementString) and \(requirementEntitlementString)"
        }
    }
}

//
//  Helper.swift
//  nl.sakesalverda.PowerMode.helper
//
//  Created by Sake Salverda on 03/02/2024.
//

import AppKit
import OSLog

final class Helper: NSObject {
    let tool = Tool()
//    let periodicChecker = PeriodicChecker()
    
    // MARK: - Properties
    let listener: NSXPCListener
    
    // MARK: - Initialisation
    override init() {
        Logger.helper.notice("Setting up XPC listener")
        
        self.listener = NSXPCListener(machServiceName: HelperConstants.mach)
        
        super.init()
        
        self.listener.delegate = self
    }
}

// MARK: - Run
extension Helper {
    func run() {
//        periodicChecker.resume()
        
        // start listening on new connections
        listener.resume()
    }
}

// MARK: - NSXPCListenerDelegate
extension Helper: NSXPCListenerDelegate {
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        Logger.helper.notice("Received new connection request")
        
        newConnection.exportedInterface = NSXPCInterface(with: HelperProtocol.self)
//        newConnection.remoteObjectInterface = NSXPCInterface(with: RemoteApplicationProtocol.self)
        newConnection.exportedObject = self.tool
        
        #if DEBUG
        let requirement = ConnectionVerifier.getCodeSignRequirementString(
            bundle: Constants.bundle,
            subjectOU: HelperConstants.subjectOU,
            subjectCN: HelperConstants.subjectCN
        )
        #else
        let requirement = ConnectionVerifier.getCodeSignRequirementString(
            bundle: Constants.bundle,
            subjectOU: HelperConstants.subjectOU
        )
        #endif
        
        Logger.helper.trace("Verifying connection with string")
        Logger.helper.trace("\(requirement, privacy: .public)")
        
        newConnection.setCodeSigningRequirement(requirement)
        
        newConnection.resume()
        
//        Task.detached {
//            try await Task.sleep(for: .seconds(1))
//
//            exit(0)
//        }
        
        return true
    }
}

//
//  HelperModel.swift
//  PowerMode
//
//  Created by Sake Salverda on 25/01/2024.
//

import SwiftUI
import ServiceManagement

@Observable
class HelperModel {
    static func getService() -> SMAppService {
        SMAppService.daemon(plistName: HelperConstants.daemon)
    }
    
    /// Update the status of the service to the current
    func updateStatus() {
        status = service.status
    }
    
    /// The current energy mode key that should be send to the helper application
    var energyModeKey: EnergyModeKey? = nil
    
    @ObservationIgnored var service = HelperModel.getService()
    
    var version: SemanticVersion? = nil
    
    private(set) var status: SMAppService.Status
    
    init() {
        status = service.status
    }
    
    /// Boolean indicating whether the helper app is installed and enabled
    var isRunningWithHelper: Bool {
        status == .enabled
    }
}

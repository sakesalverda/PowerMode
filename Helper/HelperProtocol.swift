//
//  HelperProtocol.swift
//  PowerMode
//
//  Created by Sake Salverda on 26/11/2023.
//

import Foundation
import IOKit.pwr_mgt

@objc(MainApplicationProtocol)
protocol RemoteApplicationProtocol {
    
}

@objc(HelperProtocol)
protocol HelperProtocol {
    @objc func getVersion() async throws -> String
    
    @objc func getBuild() async throws -> (version: String, build: String)
    
    @objc func terminate() async
    
    @objc func setEnergyMode(for powerSource: XPCTransfer, to energyMode: XPCTransfer, withKey energyModeKey: XPCTransfer) async throws
    
    @available(*, deprecated, message: "The CHWA key has been removed by Apple")
    @objc func readChargeLimit() async throws -> Bool
    
    @available(*, deprecated, message: "The CHWA key has been removed by Apple")
    @objc func setChargeLimit(_ : Bool) async throws
}

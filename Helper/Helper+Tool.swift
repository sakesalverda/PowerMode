//
//  Helper+Tool.swift
//  nl.sakesalverda.PowerMode.Helper
//
//  Created by Sake Salverda on 01/12/2023.
//

import OSLog

extension Logger {
    static let helperTool = Self(.helper, "tool")
}

// MARK: RunPrivilegedCommand
extension Helper.Tool {
    private func runPrivilegedCommand(for powerSource: PowerSource, to energyModeValue: EnergyMode, key energyModeKey: EnergyModeKey) async throws -> String {
        let task = Process()
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        
        task.launchPath = "/usr/bin/pmset"
        
        Logger.helperTool.notice(#"Setting new energy mode value to "\#(energyModeValue.humanReadableValue, privacy: .public)" for power source "\#(powerSource.humanReadableValue, privacy: .public)" with key "\#(energyModeKey.humanReadableValue, privacy: .public)"#)
        
        let arguments = [powerSource.cmdKey, energyModeKey.cmdValue, energyModeValue.cmdValue(forKey: energyModeKey)]
        task.arguments = arguments
        
        // MARK: Whitelisting
        let kEnergyModeKeyWhiteList = ["powermode", "lowpowermode"]
        let kPowerSourceKeyWhiteList = ["-b", "-c", "-u", "-a"]
        let kEnergyModeValueWhiteList = ["0", "1", "2"]
        
        guard let arg0 = task.arguments?[0], kPowerSourceKeyWhiteList.contains(arg0) else {
            throw HelperToolError.invalidInput(#"Casted powerSourceKey "\#(arguments[0])" is not one of the whitelisted values"#)
        }
        
        guard let arg1 = task.arguments?[1], kEnergyModeKeyWhiteList.contains(arg1) else {
            throw HelperToolError.invalidInput(#"Casted energyModeKey "\#(arguments[1])" is not one of the whitelisted values"#)
        }
        
        guard let arg2 = task.arguments?[2],kEnergyModeValueWhiteList.contains(arg2) else {
            throw HelperToolError.invalidInput(#"Casted energyModeValue "\#(arguments[2])" is not one of the whitelisted values"#)
        }
        
        // MARK: Processing
        task.standardOutput = outputPipe
        task.standardError = errorPipe
        
        try? task.run()
        
        task.waitUntilExit()
        
        // MARK: Output handling
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        
        let output = String(data: outputData, encoding: .utf8)
        let error = String(data: errorData, encoding: .utf8)
        
        if let error, !error.isEmpty {
            throw HelperToolError.processError(error)
        } else {
            return output ?? ""
        }
    }
}

extension Helper {
    final class Tool: NSObject, HelperProtocol {
        static let instance = Helper.Tool()
        
        func getVersion() async throws -> String {
            Logger.helperTool.trace("Received request for helper version")
            
//            let defaults = UserDefaults(suiteName: "nl.sakesalverda.PowerMode.helper")
//            UserDefaults.standard.set(true, forKey: "test_key_123")
            
//            Logger.helperTool.trace("Haves set for user defaults \(UserDefaults.standard.bool(forKey: "test_key_123"), privacy: .public)")
            
            guard let version = Bundle.main.version else {
                // throw no version
                throw HelperToolError.noVersion
            }
            
            return version
        }
        
        func getBuild() async throws -> (version: String, build: String) {
            Logger.helperTool.trace("Received request for helper build and version")
            
//            UserDefaults.standard.set(true, forKey: "test_key_123")
            
//            Logger.helperTool.trace("Haves set for user defaults \(UserDefaults.standard.bool(forKey: "test_key_123"), privacy: .public)")
            
            guard let build = Bundle.main.build else {
                throw HelperToolError.noVersion
            }
            
            guard let version = Bundle.main.version else {
                throw HelperToolError.noVersion
            }
            
            return (version: version, build: build)
        }
        
        func terminate() async -> Void {
            Logger.helperTool.trace("Received request to terminate helper")
            
            Task {
                exit(0)
            }
        }
        
        // MARK: Charge limit
        
        @available(*, deprecated, message: "The CHWA key has been removed by Apple")
        let chwaKey = "CHWA"
        
        @available(*, deprecated, message: "The CHWA key has been removed by Apple")
        func setChargeLimit(_ newValue: Bool) async throws {
            // CHWA KEY HAS BEEN REMOVED
            let value: UInt8 = newValue ? 1 : 0
            
            let smcKey = SMCKit.getKey(chwaKey, type: DataTypes.UInt8)
            let bytes: SMCBytes = (value, UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
                    UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
                    UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
                    UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
                    UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
                    UInt8(0), UInt8(0))
            
            defer {
                SMCKit.close()
            }
            
            do {
                Logger.helperTool.trace("Attempting to open SMC connection to set charge limit")
                
                try SMCKit.open()
            } catch {
                Logger.helperTool.warning("SMC connection cannot be initiated. \(error, privacy: .public)")
                
                throw HelperToolError.openSMC
            }
            
            do {
                try SMCKit.writeData(smcKey, data: bytes)
            } catch {
                Logger.helperTool.warning("Could not set SMC value for key \"\(self.chwaKey, privacy: .public)\" to \(value, privacy: .public). \(error, privacy: .public)")
                
                throw HelperToolError.setSMC(key: chwaKey, value: value)
            }
        }
        
        @available(*, deprecated, message: "The CHWA key has been removed by Apple")
        func readChargeLimit() async throws -> Bool {
            defer {
                SMCKit.close()
            }
            
            do {
                Logger.helperTool.trace("Attempting to open SMC connection to get charge limit")
                
                try SMCKit.open()
            } catch {
                Logger.helperTool.warning("SMC connection cannot be initiated. \(error, privacy: .public)")
                
                throw HelperToolError.openSMC
            }
            
            let smcKey = SMCKit.getKey(chwaKey, type: DataTypes.UInt8)
            
            do {
                let status = try SMCKit.readData(smcKey).0
                
                return status == 1
            } catch {
                Logger.helperTool.warning("Could not get SMC value for key \"\(self.chwaKey, privacy: .public)\". \(error, privacy: .public)")
                
                throw HelperToolError.getSMC(chwaKey)
            }
        }
        
        // MARK: Energy Mode
        
        func setEnergyMode(for powerSource: XPCTransfer, to energyMode: XPCTransfer, withKey energyModeKey: XPCTransfer) async throws {
            Logger.helperTool.trace("Received request set new power mode")
            
            do {
                guard let powerSource = PowerSource(rawValue: powerSource) else {
                    Logger.helperTool.error("Invalid power source xpc value \(powerSource, privacy: .public)")
                    
                    throw HelperToolError.invalidInput("powerSource xpcvalue: \(powerSource)")
                }
                
                guard let energyMode = EnergyMode(rawValue: energyMode) else {
                    Logger.helperTool.error("Invalid energy mode xpc value \(energyMode, privacy: .public)")
                    
                    throw HelperToolError.invalidInput("energyMode xpcvalue: \(energyMode)")
                }
                
                guard let energyModeKey = EnergyModeKey(rawValue: energyModeKey) else {
                    Logger.helperTool.error("Invalid energy mode key xpc value \(energyModeKey, privacy: .public)")
                    
                    throw HelperToolError.invalidInput("energyModeKey xpcvalue: \(energyModeKey)")
                }
                
                let output = try await runPrivilegedCommand(for: powerSource, to: energyMode, key: energyModeKey)
                
                if !output.isEmpty {
                    Logger.helperTool.warning("Unexpect nonempty output returned by process execution: \(output, privacy: .public)")
                    
                    throw HelperToolError.processError("Unexpected nonempty output returned by process: \(output)")
                }
            } catch let error as HelperToolError {
                Logger.helperTool.error("Process execution error \(error.localizedDescription, privacy: .public)")
                
                let nsCasted = error as NSError
                
                let description = error.localizedDescription

                throw NSError(domain: nsCasted.domain, code: nsCasted.code, userInfo: [NSLocalizedDescriptionKey: description])
            }
        }
    }
}

//
//  serialNumber.swift
//  
//
//  Created by Sake Salverda on 29/02/2024.
//

import IOKit
import Foundation

enum SerialNumberError: Error {
    case missingExpert
    case missingSerial
}

extension ProcessInfo {
    /// Returns a `String` representing the machine hardware name or nil if there was an error invoking `uname(_:)` or decoding the response.
    ///
    /// Return value is the equivalent to running `$ uname -m` in shell.
    public var machineHardwareName: String? {
            var sysinfo = utsname()
            let result = uname(&sysinfo)
            guard result == EXIT_SUCCESS else { return nil }
            let data = Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN))
            guard let identifier = String(bytes: data, encoding: .ascii) else { return nil }
            return identifier.trimmingCharacters(in: .controlCharacters)
    }
    
    public var isARM: Bool {
        machineHardwareName?.contains("arm") ?? false
    }
}

#if os(macOS)
func getSerialNumber() throws -> String {
    let platformExpert = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("IOPlatformExpertDevice") )
    
    defer {
        IOObjectRelease(platformExpert)
    }
    
    guard platformExpert > 0 else {
        throw SerialNumberError.missingExpert
    }
    
    guard let serialNumber = (IORegistryEntryCreateCFProperty(platformExpert, kIOPlatformSerialNumberKey as CFString, kCFAllocatorDefault, 0).takeUnretainedValue() as? String)?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) else {
        throw SerialNumberError.missingSerial
    }

    return serialNumber
}
#endif

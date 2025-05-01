//
//  FileListener.swift
//  PowerMode
//
//  Created by Sake Salverda on 15/03/2024.
//

import Foundation
import OSLog
import Combine

extension Logger {
    fileprivate static let fileListener = Self(.main, "pmlistener")
}

class FileListener {
    private(set) var publisher: PassthroughSubject<Void, Never> = .init()
    
    enum FileError: LocalizedError {
        case fileNoneExisting(URL)
        case preferencesNotDirectory(URL)
        case noLocalizedManagementFile
        case openFileHandleFailed(URL, code: Int32)
    }
    
    private func getNewPreferenceFile() throws -> URL? {
        let libraryFolder = try FileManager.default.url(for: .libraryDirectory, in: .localDomainMask, appropriateFor: nil, create: false)
        let preferencesFolder = libraryFolder.appendingPathComponent("Preferences")
        
        var isDirectory: ObjCBool = false
        Logger.fileListener.trace("Assertings Preferences folder exists")
        guard FileManager.default.fileExists(atPath: preferencesFolder.path, isDirectory: &isDirectory) else {
            throw FileError.fileNoneExisting(preferencesFolder)
        }
        
        Logger.fileListener.trace("Asserting Preferences folder is a directory")
        guard isDirectory.boolValue else {
            Logger.fileListener.trace("Preferences path is not a folder")
            
            throw FileError.preferencesNotDirectory(preferencesFolder)
        }
        
        Logger.fileListener.trace("Creating Preferences folder enumerator")
        guard let enumerator = FileManager.default.enumerator(at: preferencesFolder, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants]) else {
            return nil
        }
        
        var match: URL? = nil
        
        Logger.fileListener.trace("Iterating over plist files to find pm plist")
        for case let fileURL as URL in enumerator {
            if fileURL.lastPathComponent.hasPrefix("com.apple.PowerManagement") &&
                fileURL.lastPathComponent != "com.apple.PowerManagement.plist" {
                match = fileURL
            }
        }
        
        guard let match else {
            throw FileError.noLocalizedManagementFile
        }
        
        return match
    }
    
    @available(*, deprecated, renamed: "getNewPreferenceFile", message: "This method has been replaced by getNewPreferenceFile")
    private func getPreferenceFile() throws -> URL? {
        let libraryFolder = try FileManager.default.url(for: .libraryDirectory, in: .localDomainMask, appropriateFor: nil, create: false)
        let preferencesFolder = libraryFolder.appendingPathComponent("Preferences")
        
        var isDirectory: ObjCBool = false
        Logger.fileListener.trace("Assertings Preferences folder exists")
        guard FileManager.default.fileExists(atPath: preferencesFolder.path, isDirectory: &isDirectory) else {
            throw FileError.fileNoneExisting(preferencesFolder)
        }
        
        Logger.fileListener.trace("Asserting Preferences folder is a directory")
        guard isDirectory.boolValue else {
            Logger.fileListener.trace("Preferences path is not a folder")
            
            throw FileError.preferencesNotDirectory(preferencesFolder)
        }
        
        Logger.fileListener.trace("Listing all files in Preferences folder")
        let preferenceFiles = try FileManager.default.contentsOfDirectory(at: preferencesFolder, includingPropertiesForKeys: nil)
        
        Logger.fileListener.trace("Identifying preference files for power management")
        let powerManagementFiles = preferenceFiles.filter { url in
            url.lastPathComponent.hasPrefix("com.apple.PowerManagement")
        }

        Logger.fileListener.trace("Filtering power management files for energy modes")
        guard let powerManagementFile = (powerManagementFiles.filter { url in
            url.lastPathComponent != "com.apple.PowerManagement.plist"
        }.first) else {
            throw FileError.noLocalizedManagementFile
        }
        
        return powerManagementFile
    }
    
    private(set) var descriptor: Int32?
    private(set) var source: DispatchSourceFileSystemObject?
    
    @available(*, deprecated)
    private func setupFileMontior() throws {
        self.source?.cancel()
        
        guard let powerManagementFile = try getNewPreferenceFile() else {
            Logger.fileListener.warning("Could not obtain power management preference file")
            
            return
        }
            
        self.descriptor = open(powerManagementFile.path, O_EVTONLY)
        
        guard let descriptor = self.descriptor, descriptor != -1 else {
            throw FileError.openFileHandleFailed(powerManagementFile, code: Darwin.errno)
        }
        
        self.source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: descriptor, eventMask: .delete, queue: .global())
        
        self.source?.setEventHandler {
            Logger.fileListener.trace("Received event on power management preference file")
            
            self.publisher.send()
            
            self.source?.cancel()
            
            do {
                Logger.fileListener.trace("Attempting to re-enable file listener on pm file")
                try self.setupFileMontior()
            } catch {
                Logger.fileListener.warning("Could not re-enable file listener on pm file \(error, privacy: .public)")
            }
        }
        
        Logger.fileListener.trace("Resuming power management source dispatcher")
        self.source?.resume()
    }
    
    
    private class Observer: NSObject {
        let passthrough: PassthroughSubject<PowerSource, Never> = .init()
        
        let userDefaults: UserDefaults
        
        init(_ userDefaults: UserDefaults) {
            self.userDefaults = userDefaults
            
            super.init()
            
            setupObservers()
        }
        
        func setupObservers() {
            userDefaults.addObserver(self, forKeyPath: kIOPSBatteryPowerValue, options: .new, context: nil)
            userDefaults.addObserver(self, forKeyPath: kIOPSACPowerValue, options: .new, context: nil)
        }
        
        func cancelObservsers() {
            // Remove observer when deinitialized
            userDefaults.removeObserver(self, forKeyPath: kIOPSBatteryPowerValue)
            userDefaults.removeObserver(self, forKeyPath: kIOPSACPowerValue)
        }
        
        // Called when there's a change in the observed key
        override func observeValue(forKeyPath keyPath: String?,
                                   of object: Any?,
                                   change: [NSKeyValueChangeKey : Any]?,
                                   context: UnsafeMutableRawPointer?) {
            // Ensure keyPath matches our expected key
            if keyPath == kIOPSBatteryPowerValue {
                // Notify the change handler
                passthrough.send(.battery)
            } else if keyPath == kIOPSACPowerValue {
                passthrough.send(.adapter)
            }
        }
        
        deinit {
            cancelObservsers()
        }
        
    }
    
    private var cancellable: AnyCancellable? = nil
    private var observer: Observer? = nil
    
    private func setupPreferenceMonitor() throws {
        guard let preferenceFile = try getNewPreferenceFile() else {
            Logger.fileListener.warning("Could not obtain power management preference file")
            
            return
        }
        
        let preference = preferenceFile.deletingPathExtension().lastPathComponent
        
        guard let defaults = UserDefaults(suiteName: preference) else {
            Logger.fileListener.error("Could not instantiate userdefaults for power management")
            
            return
        }
        
        self.observer = Observer(defaults)
        
//        observer?.passthrough.sink { [weak self] in self?.publisher.send() }
        self.cancellable = observer?.passthrough.sink { [weak self] _ in
            self?.publisher.send()
        }
    }
    
    init() {
        do {
            try setupPreferenceMonitor()
        } catch {
            Logger.fileListener.error("Could not initiate listener on pm file, \(error.localizedDescription, privacy: .public)")
        }
    }
}

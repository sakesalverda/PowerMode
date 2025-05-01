//
//  HelperRemote.swift
//  PowerMode
//
//  Created by Sake Salverda on 01/12/2023.
//

import Foundation
import XPC
import ServiceManagement
import OSLog

extension Logger {
    static let helperServiceManagement = Self(.main, "helper.servicem")
}

@MainActor
extension HelperModel: RemoteApplicationProtocol {
    func uninstallHelper() async -> Bool {
        defer {
            updateStatus()
        }
        
        var anyError: Bool = false
        
        do {
            Logger.helperConnection.trace("Terminating helper")
            try await terminateIfActive()
            Logger.helperServiceManagement.notice("Succesfully terminated helper")
            
        } catch {
            Logger.helperServiceManagement.warning("Unable to terminate helper before unregistering \(error, privacy: .public); \(error.localizedDescription, privacy: .public)")
            
            anyError = true
        }
        
        do {
            Logger.helperConnection.trace("Unregistering service")
            try await service.unregister()
            Logger.helperServiceManagement.notice("Succesfully unregistered service")
        } catch {
            Logger.helperServiceManagement.warning("Unable to unregister helper \(error, privacy: .public); \(error.localizedDescription, privacy: .public)")
            
            return false
        }
        
        // if returns kSMErrorJobNotFound, then service is already unregistered
        
        if anyError {
            return false
        } else {
            return true
        }
    }
    
    func reinstallHelper() async -> Bool {
        defer {
            updateStatus()
        }
        
        do {
            Logger.helperConnection.trace("Terminating helper service")
            try await withThrowingConnection { await $0.terminate() }
            Logger.helperServiceManagement.notice("Succesfully terminated service, new executable is in use")
        } catch {
            Logger.helperServiceManagement.warning("Unable to reinstall helper \(error, privacy: .public)")
            
            return false
        }
        
        return true
    }
    
    enum ManagementError: Error {
        case alreadyRegistered
        case launchDeniedByUser
        
        case jobNotFound
    }
    
    func installHelper() async -> Bool {
        defer {
            updateStatus()
        }
        
        do {
            try await withCheckedThrowingContinuation { continuation in
                Task.detached {
                    do {
                        Logger.helperServiceManagement.trace("Registering helper")
                        
                        try self.service.register()
                        
                        Logger.helperServiceManagement.notice("Succesfully registered helper")
                        
                        continuation.resume()
                    } catch {
                        let nsError = error as NSError
                        
                        // if returns kSMErrorAlreadyRegistered, service already registered
                        // if returns kSMErrorLaunchDeniedByUser, service not approved by user
                        let defaultMessage = "Could not register helper"
                        
                        switch nsError.code {
                        case kSMErrorAlreadyRegistered:
                            Logger.helperServiceManagement.warning("\(defaultMessage, privacy: .public). Helper already registered")
                        case kSMErrorLaunchDeniedByUser:
                            Logger.helperServiceManagement.warning("\(defaultMessage, privacy: .public). Helper launch denied by user")
                        default:
                            break
                        }
                        
                        continuation.resume(throwing: error)
                    }
                }
            }
        } catch {
            Logger.helperServiceManagement.error("Could not register helper \(error, privacy: .public)")
            
            return false
        }
        
        return true
    }
    
    private
    func createConnection() throws -> NSXPCConnection {
        if !isRunningWithHelper {
            throw HelperToolError.notInstalled
        }
        
        let connection = NSXPCConnection(machServiceName: HelperConstants.mach, options: .privileged)
        connection.remoteObjectInterface = NSXPCInterface(with: HelperProtocol.self)
        
        connection.invalidationHandler = {
            if self.isRunningWithHelper {
                Logger.helperConnection.warning("Unable to connect to helper although it is installed")
            } else {
                Logger.helperConnection.debug("Attempting to connect to helper while it is not installed")
            }
        }

        connection.resume()

        return connection
    }
    
    private
    func getRemote(onConnectionError: @escaping (Error) -> Void) async throws -> some HelperProtocol {
        let connection = try createConnection()
        
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<any HelperProtocol, Error>) in
            let continuationResume = ContinuationResume()
            
            let helper = connection.remoteObjectProxyWithErrorHandler { error in
                Logger.helperConnection.trace("Error occured while connecting to helper proxy \(error)")
                
                // 1st error to arrive, it will be the one thrown
                guard continuationResume.shouldResume() else {
                    onConnectionError(error)
                    
                    return
                }
                continuation.resume(throwing: error)
            }
            
            guard let unwrappedHelper = helper as? HelperProtocol else {
                let error = HelperToolError.helperConnection("Unable to get a valid 'HelperProtocol' object")
                
                // 1st error to arrive, it will be the one thrown
                guard continuationResume.shouldResume() else {
                    Logger.helperConnection.critical("Could not throw unwrapped error. No error should have occured on the proxy object yet")
                    
                    return
                }
                continuation.resume(throwing: error)
                
                return
            }
            
            guard continuationResume.shouldResume() else {
                Logger.helperConnection.critical("Could not resume with unwrapped helper. No error should have occured on the proxy object yet")
                return
            }
            continuation.resume(returning: unwrappedHelper)
        }
    }
    
    func withThrowingConnection<R>(timeout awaitTimeout: ContinuousClock.Duration = .seconds(1), _ closure: @escaping (HelperProtocol) async throws -> R) async throws -> R {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<R, Error>) in
            let continuationResume = ContinuationResume()
            
            Task {
                let timeoutConnection = Task.detached {
                    try await Task.sleep(for: awaitTimeout)
                    
                    Logger.helperConnection.warning("Connection to helper timed out")
                    
                    guard continuationResume.shouldResume() else { return }
                    continuation.resume(throwing: HelperToolError.timeoutError)
                }
                
                let connection = try await getRemote(onConnectionError: { [weak continuationResume] error in
                    guard let continuationResume else { return }
                    
                    timeoutConnection.cancel()
                    
                    guard continuationResume.shouldResume() else { return }
                    continuation.resume(throwing: error)
                })
                
                // this might throw an error
                let result = try await closure(connection)
                
                timeoutConnection.cancel()
                
                guard continuationResume.shouldResume() else { return }
                continuation.resume(returning: result)
            }
        }
    }
    
    func terminateIfActive() async throws {
        Logger.helperServiceManagement.trace("Attempting to terminate helper if it is active")
        guard checkForRunningApp(.helper) else {
            Logger.helperServiceManagement.trace("Helper already terminated")
            
            return
        }
        
        Logger.helperServiceManagement.trace("Helper is active. Attempting to terminate")
        
        try await withThrowingConnection { await $0.terminate() }
    }
}

extension HelperModel {
    /// Helper class to safely access a boolean when using a continuation to get the remote.
    private final class ContinuationResume: @unchecked Sendable {

        // MARK: Properties

        private let unfairLockPointer: UnsafeMutablePointer<os_unfair_lock_s>
        private var alreadyResumed = false

        // MARK: Computed

        /// Returns `true` if the continuation should resume.
        func shouldResume() -> Bool {
            os_unfair_lock_lock(unfairLockPointer)
            defer { os_unfair_lock_unlock(unfairLockPointer) }

            if alreadyResumed {
                return false
            } else {
                alreadyResumed = true
                return true
            }
        }

        // MARK: Init

        init() {
            unfairLockPointer = UnsafeMutablePointer<os_unfair_lock_s>.allocate(capacity: 1)
            unfairLockPointer.initialize(to: os_unfair_lock())
        }

        deinit {
            unfairLockPointer.deallocate()
        }
    }
}

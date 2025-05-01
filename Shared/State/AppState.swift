//
//  AppState.swift
//  PowerMode
//
//  Created by Sake Salverda on 25/12/2023.
//

import SwiftUI

import Combine
import ServiceManagement

import RegexBuilder
import OSLog

import UserNotifications
//import ObservableUserDefault

import Dispatch

import Walberg

enum DonationModalState: Codable, Equatable {
    case initial
    
    case dismissed
    case linkOpened
    
    var doesAllowFunctionality: Bool {
        self == .dismissed || self == .linkOpened
    }
    
//    enum CodingKeys: String, CodingKey {
//        case none = "none"
//        case dismissed = "dismissed"
//        case opened = "opened"
//    }
}

enum DonationState: Codable, Equatable {
    case initial
    
    /// State where user left the app and started a donation process
    case awaiting(String)
    
    /// State where the donation for a given ID, the associated value, has succesfully finished
    case success(String)
    
    /// Display state when some error has occured during the donation process
    case error(String)
}

struct DebugDescription {
    let batteryEnergyMode: EnergyMode?
    let adapterEnergyMode: EnergyMode?
    let isUsingBattery: Bool
    let isUsingAdapter: Bool
    let powerSource: PowerSourceIO?
    
    let terminalOutput: String?
    
    let helperVersion: SemanticVersion?
    
    let prefAutoLowPowerModeDischargeThreshold: Int
    let prefResetLowPowerModeChargeThreshold: Int
    
    let prefHideHighPowerModeOnBattery: Bool
    let prefEnableLowPowerModeOnLowBattery: Bool
}

extension Logger {
    /// main.energymode.retriever
    static let energyModeRetriever = Self(.main, "energymode.retriever")
    
    static let energyModeTerminalProcess = Self(.main, "energymode.terminal-process")
    
    /// main.energymode.terminal-output
    static let energyModeTerminal = Self(.main, "energymode.terminal-output")
    
    /// main.energymode.terminal-regex
    static let energyModeTerminalRegex = Self(.main, "energymode.terminal-regex")
    
    /// main.powersource
    static let powerSource = Self(.main, "powersource")
    
    /// main.batterywachter
    static let batteryMonitor = Self(.main, "batterywatcher.receivedupdate")
}


// MARK: Event handlers
extension AppState {
    @MainActor static let shared = AppState()
    
    /// The difference between <handlePowerStateUpdate> and <handleIntervalTimerUpdate> is that:
    /// <handlePowerStateUpdate> is called from a notification when the system switches between low and non-low power mode
    ///
    /// <handleIntervalTimerUpdate> is called every <X> seconds. If however, we have read the power state configuration in the last <Y> seconds (where < (Y < X) >) then there is no need to re-update the view
    ///
    /// this implies that any update to the powerstate made outside our app will be shown in at most X + Y seconds
    /// however, any switch between a low power and non low power mode, will be catched by the powerStateUpdate and, will be show instantly
    /// (there is no noficiation when switching from normal to high power mode, probably because apple wants it to be a hardware only
    
    // MARK: Energy Mode State Watcher
    // note that at moment of writing, only switching from and to low power mode yields the notitification which invokes this method
    @MainActor func handlePowerStateUpdate() async -> Void {
        // if a user updated the energy mode in our app in the last X seconds
        // don't re-read the configuration because of the published system notitifcation because it was
        // created by an interaction in our app and the energy modes are already re-read from terminal
        
        // if a notification would be fired for high power mode as well we could rely on this instead of on a click
        
        // NOTE: temporary disabled because we listen to the actual source file for changes
//        guard let lastSet else {
//            Task { await runPeriodic() }
//
//            return
//        }
//
//        let intervalSinceLastUpdate = Date.now.timeIntervalSince(lastSet)
//
//
//        // from testing it appears the system notification is send approximately 0.2 - 0.25 seconds after the interaction in the app for setting a new energy mode
//        // to prevent non-needed terminal reading, we check if this threshold has passed
//
//        // Threshold under which an energy mode change is assumed to be caused by user interaction in our app
//        let threshold: Double = 0.5
//
//        if intervalSinceLastUpdate > threshold {
//            await runPeriodic()
//        }
    }
    
    @MainActor func handlePMPreferenceUpdate() async -> Void {
        guard let lastSet else {
            Task { await runPeriodic() }
            
            return
        }
        
        let intervalSinceLastSet = Date.now.timeIntervalSince(lastSet)
        
        // it can take quite some time for the backing file to change after setting a new energy mode
        let threshold: Double = 5
        
        if intervalSinceLastSet > threshold {
            await runPeriodic()
        }
    }
    
    // MARK: Timer
    @MainActor func handleIntervalTimerUpdate() async -> Void {
        let intervalSinceLastRead = Date.now.timeIntervalSince(lastRead)
        
        let threshold: Double = 4
        
        helper.updateStatus()
        
        if intervalSinceLastRead > threshold {
            await runPeriodic()
        }
    }
    
    private func runPeriodic() async {
        await readTerminalConfiguration()
        
        try? await readChargeLimitEnabled()
        
        await performBatteryPercentageCheck()
    }
}

@Observable
final class AppState {
//    @available(*, deprecated, message: "Do not use in production environment")
    @MainActor static let preview = AppState()
    
    /// Time at which the energy mode configuration was last read from terminal
    private(set) var lastRead: Date = .now
    
    /// Time at which any energy mode has been changed by a user within this app
    private(set) var lastSet: Date? = nil
    
    private(set) var hasFirstRead: Bool = false
    
    static let refreshInterval: CGFloat = Constants.retrieveInterval
    
    let isRunningAsPreview: Bool = Constants.isPreview
    
    
    /// Boolean indicating whether there is a software update
//    @ObservableUserDefault(.init(key: DefaultsName.updateAvailable, defaultValue: Defaults.updateAvailable.defaultValue, store: .standard))
    @ObservationIgnored
    @MainActor
    var updateAvailable: Bool {
        get {
            access(keyPath: \.updateAvailable)
            return Defaults.updateAvailable.wrappedValue
        }
        
        set {
            withMutation(keyPath: \.updateAvailable) {
                Defaults.updateAvailable.wrappedValue = newValue
            }
        }
    }
    
    
    /// Boolean indicating whether the update notification is shown in the main
//    @ObservableUserDefault(.init(key: DefaultsName.updateAvailableNotification, defaultValue: Defaults.updateAvailableNotification.defaultValue, store: .standard))
    @ObservationIgnored
    @MainActor
    var updateNotificationAvailable: Bool {
        get {
            access(keyPath: \.updateNotificationAvailable)
            return Defaults.updateAvailableNotification.wrappedValue
        }
        
        set {
            withMutation(keyPath: \.updateNotificationAvailable) {
                Defaults.updateAvailableNotification.wrappedValue = newValue
            }
        }
    }
    
    
    
    var _internalSupportState = TypedUserDefaults<DonationState>("cache_didSupport", value: .initial)
    
    @ObservationIgnored
    var supportState: DonationState {
        get {
            _internalSupportState.wrappedValue
        }
        
        set {
            _internalSupportState.wrappedValue = newValue
        }
    }
    
    
    var _internalSupportModalState: TypedUserDefaults<DonationModalState> = .init("cache_dismissedSupportModal", value: .dismissed)
    
    @ObservationIgnored
    var supportModalState: DonationModalState {
        get {
            _internalSupportModalState.wrappedValue
        }
        
        set {
            _internalSupportModalState.wrappedValue = newValue
        }
    }
    
    var didEnableConsiderSupportingFunctionalities: Bool {
        supportState != .initial || supportModalState != .initial
    }
    
    
    // MARK: Power Source
    private let _powerSourceWatcher = PowerSourceWatcher()
    
    /// Boolean indicating whether the device is currently drawing power from battery
    var isUsingBattery: Bool {
        _powerSourceWatcher.isUsingBattery
    }
    
    var timeToFullyCharge: Int? {
        _powerSourceWatcher.timeToFullyCharge
    }
    
    var timeToEmpty: Int? {
        _powerSourceWatcher.timeToEmpty
    }
    
    var isCharging: Bool {
        _powerSourceWatcher.isCharging
    }
    
    var isFullyCharged: Bool {
        _powerSourceWatcher.isFullyCharged
    }
    
    var isUsingPowerAdapter: Bool {
        _powerSourceWatcher.isUsingPowerAdapter
    }
    
    /// Integer indicating the current battery charge percentage
    var batteryCurrentPercentage: Int? {
        _powerSourceWatcher.batteryCurrentPercentage
    }
    
    // MARK: Low Battery
    @ObservationIgnored
    @MainActor var _lowBatteryPreviousEnergyMode: EnergyMode? {
        get {
            access(keyPath: \._lowBatteryPreviousEnergyMode)
            return Defaults.lowBatteryPreviousEnergyMode.wrappedValue
        }
        
        set {
            print("Setting energy mode to \(newValue?.humanReadableValue ?? "nil")")
            
            withMutation(keyPath: \._lowBatteryPreviousEnergyMode) {
                Defaults.lowBatteryPreviousEnergyMode.wrappedValue = newValue
            }
        }
//        get {
//            access(keyPath: \._lowBatteryPreviousEnergyMode)
//
//            guard UserDefaults.standard.object(forKey: DefaultsName.lowBatteryPreviousEnergyMode) != nil else {
////                Logger.batteryMonitor.trace("No stored value found in userdefaults for previous energy mode")
//
//                return nil
//            }
//
//            let int = UserDefaults.standard.integer(forKey: DefaultsName.lowBatteryPreviousEnergyMode)
//
//            let int8 = UInt8(int)
//
//            guard let casted = EnergyMode(rawValue: int8) else {
//                Logger.batteryMonitor.warning("Could not convert stored previous energy mode (\(int, privacy: .public)) to EnergyMode")
//
//                return nil
//            }
//
//            return casted
//        }
//
//        set {
//            withMutation(keyPath: \._lowBatteryPreviousEnergyMode) {
//                UserDefaults.standard.set(newValue?.rawValue, forKey: DefaultsName.lowBatteryPreviousEnergyMode)
//            }
//        }
    }
    
//    @ObservableUserDefault(.init(key: Defaults.didCancelAutoLowPowerMode.key, defaultValue: Defaults.didCancelAutoLowPowerMode.defaultValue, store: .standard))
    @ObservationIgnored
    var _didCancelAutoLowEnergyMode: Bool {
        get {
            access(keyPath: \._didCancelAutoLowEnergyMode)
            return Defaults.didCancelAutoLowPowerMode.wrappedValue
        }
        
        set {
            withMutation(keyPath: \._didCancelAutoLowEnergyMode) {
                Defaults.didCancelAutoLowPowerMode.wrappedValue = newValue
            }
        }
    }
//    /*private(set) */var _didCancelAutoLowEnergyMode: Bool {
//        get {
//            access(keyPath: \._didCancelAutoLowEnergyMode)
//            return UserDefaults.standard.bool(forKey: DefaultsName.didCancelAutoLowPowerMode)
//        }
//
//        set {
//            withMutation(keyPath: \._didCancelAutoLowEnergyMode) {
//                UserDefaults.standard.set(newValue, forKey: DefaultsName.didCancelAutoLowPowerMode)
//            }
//        }
//    }
    
//    @ObservableUserDefault(.init(key: Defaults.didTriggerAutoLowPowerMode.key, defaultValue: false, store: .standard))
    @ObservationIgnored
    var _didSetAutoLowEnergyMode: Bool {
        get {
            access(keyPath: \._didSetAutoLowEnergyMode)
            return Defaults.didTriggerAutoLowPowerMode.wrappedValue
        }
        
        set {
            withMutation(keyPath: \._didSetAutoLowEnergyMode) {
                Defaults.didTriggerAutoLowPowerMode.wrappedValue = newValue
            }
        }
    }
    
    
//    @ObservationIgnored
//    @MainActor
//    var _chargeLimitEnabled: Bool {
//        get {
//            access(keyPath: \._chargeLimitEnabled)
//
//            return Defaults.chargeLimitEnabled.wrappedValue
//        }
//
//        set {
//            withMutation(keyPath: \._chargeLimitEnabled) {
//                Defaults.chargeLimitEnabled.wrappedValue = newValue
//            }
//        }
//    }
    
    var chargeLimitEnabled: Bool = false
    
    func readChargeLimitEnabled() async throws {
        Logger.helperConnection.trace("Attempting to read charge limit (DEPRECATED)")
        
//        try await helper.withThrowingConnection { [weak self] connection in
//            self?.chargeLimitEnabled = try await connection.readChargeLimit()
//            
//            Logger.helperConnection.trace("Succesfully read charge limit")
//        }
    }
    
    func setChargeLimitEnabled(_ enabled: Bool) async throws {
        // DEPRECATED
//        try await helper.withThrowingConnection { connection in
//            try await connection.setChargeLimit(enabled)
//        }
    }
    
    // MARK: Energy Modes
    var internalBatteryEnergyMode: EnergyMode? = nil
    var internalAdapterEnergyMode: EnergyMode? = nil
    
    var currentEnergyMode: EnergyMode? {
        if isUsingBattery {
            return internalBatteryEnergyMode
        } else if isUsingPowerAdapter {
            return internalAdapterEnergyMode
        }
        
        return nil
    }
    
    @MainActor func setBatteryEnergyMode(_ newEnergyMode: EnergyMode?, fromUserInteraction: Bool = true) async {
        guard newEnergyMode != batteryEnergyMode else { return}
        
        // if the helper is enabled, we assume the changing will not fail
        // by setting the mode imemdiately here, we create a smoother button click experience
//        if helper.isRunningWithHelper {
//            internalBatteryEnergyMode = newEnergyMode
//        }
        
        guard await sendNewEnergyModeToHelper(for: .battery, to: newEnergyMode) ?? false else {
            Logger.helperConnection.warning("Could not send new energy mode to helper")
            return
        }
        
        // if from a user interaction that means the auto low power mode must have been disabled
        if fromUserInteraction {
            defer {
                _lowBatteryPreviousEnergyMode = nil
                _didSetAutoLowEnergyMode = false
            }
            
            if newEnergyMode == .low {
                _didCancelAutoLowEnergyMode = false
            } else if _lowBatteryPreviousEnergyMode != nil{
                _didCancelAutoLowEnergyMode = true
            }
        }
    }
    
    var batteryEnergyMode: EnergyMode? {
        get {
            internalBatteryEnergyMode
        }
    }
    
    @MainActor var adapterEnergyMode: EnergyMode? {
        get {
            internalAdapterEnergyMode
        }
        
        set {
//            if helper.isRunningWithHelper {
//                internalAdapterEnergyMode = newValue
//            }
            
            Task {
                await sendNewEnergyModeToHelper(for: .adapter, to: newValue)
            }
        }
    }
    
    
    // MARK: Subclasses
    
    fileprivate(set) var device: DeviceCapabilitiesState = .init()
    
    // MARK: Notifications
    let notifications = NotificationManager()
    
    let helper: HelperModel = .init()

    // MARK: Publishers
    
    let timerIntervalPublisher = Timer.publish(every: Constants.retrieveInterval, tolerance: 2, on: .main, in: .common).autoconnect().receive(on: DispatchQueue.main)
    
    let powerStateUpdatePublisher = NotificationCenter.default.publisher(for: .NSProcessInfoPowerStateDidChange).receive(on: DispatchQueue.main)
    
    private var subscribers: Set<AnyCancellable>  = []
    
    @MainActor func restorePreviousBatteryMode(withCancel: Bool = false) {
        Logger.batteryMonitor.trace("Attempting to restore previous energy mode with cancel tracker: \(withCancel, privacy: .public)")
        
        if let previousEnergyMode = _lowBatteryPreviousEnergyMode {
            Logger.batteryMonitor.trace("There is a previous energy mode to restore")
            
            _lowBatteryPreviousEnergyMode = nil
            
            Task {
                await setBatteryEnergyMode(previousEnergyMode, fromUserInteraction: false)
            }
        } else {
            Logger.batteryMonitor.trace("No previous energy mode to restore")
//            _lowBatteryPreviousEnergyMode = nil
        }
        
        notifications.removeLowBatteryDeliveredNotifications()
        
        _didCancelAutoLowEnergyMode = withCancel
        _didSetAutoLowEnergyMode = false
    }
    
    @MainActor
    func performBatteryPercentageCheck() {
        @Preference(\.enableLowPowerModeOnLowBattery) var enableLowPowerModeOnLowBattery
        
        guard helper.isRunningWithHelper else {
            _lowBatteryPreviousEnergyMode = nil
            _didSetAutoLowEnergyMode = false
            _didCancelAutoLowEnergyMode = false
            
            return
        }
        
        guard let newPercentage = self.batteryCurrentPercentage else {
            Logger.batteryMonitor.warning("Battery change manager called while no battery percentage has been determined")
            
            // since there is no information, we reset all information
//            _lowBatteryPreviousEnergyMode = nil
//            _didSetAutoLowEnergyMode = false
//            _didCancelAutoLowEnergyMode = false
            
            return
        }
        
        guard enableLowPowerModeOnLowBattery else {
            Logger.batteryMonitor.notice("Auto low power mode on low battery is not enabled")
            
            restorePreviousBatteryMode()
            
            return
        }
        
        /// Battery percentage below which low power mode should be enabled
        @Preference(\.autoLowPowerModeDischargeThreshold) var dischargingThreshold
        
        Logger.batteryMonitor.debug("Checking low power mode auto enabling for battery percentage: \(newPercentage)")
        
        guard isUsingBattery else {
            Logger.batteryMonitor.trace("Cancelling check, running on power adapter")
            
            restorePreviousBatteryMode()
            
            return
        }
        Logger.batteryMonitor.trace("Continuing check, running on battery")
        
        guard let currentBatteryEnergyMode = batteryEnergyMode else {
            // since we only start observing AFTER al values have been loaded
            Logger.batteryMonitor.error("Battery energy mode has not been determined yet")
            return
        }
        Logger.batteryMonitor.trace("Contuniung checks with \(currentBatteryEnergyMode.humanReadableValue, privacy: .public) energy mode")
        
        if newPercentage <= dischargingThreshold {
            Logger.batteryMonitor.trace("Battery level is below threshold")
            
            // if it was already cancelled
            guard !_didCancelAutoLowEnergyMode else {
                // if cancelled and energy mode is low,
                
                // didCancel = false
                // lowBatteryPreviousEnergy must be nil
                // didSet must be set true
                
                // if cancelled and energy mode is not low, must be cancelled
                // didCancel = true
                // previous = nil
                // didSet = false
                if currentEnergyMode == .low {
                    _didCancelAutoLowEnergyMode = false
                    _lowBatteryPreviousEnergyMode = nil
                    _didSetAutoLowEnergyMode = true
                } else {
                    _didCancelAutoLowEnergyMode = true
                    _lowBatteryPreviousEnergyMode = nil
                    _didSetAutoLowEnergyMode = true
                }
                
                Logger.batteryMonitor.info("Automatic low power mode has been cancelled until plugged in")
                
                return
            }
            Logger.batteryMonitor.trace("Automatic low power mode has not been cancelled")
            
            guard !_didSetAutoLowEnergyMode else {
                Logger.batteryMonitor.trace("Automatic low power mode has already been set")
                // if was already set, we do some safety checks
                Logger.batteryMonitor.info("Low power was set mode has been changed externally while automatically enabled")

                if currentEnergyMode == .low {
                    _didCancelAutoLowEnergyMode = false
                    // _lowBatteryPreviousEnergyMode = nil (DO NOT RESET THIS)
                } else {
                    // if didset is true and energy mode is not 'low', it was changed externally
                    _didCancelAutoLowEnergyMode = true
                    _didSetAutoLowEnergyMode = false
                    _lowBatteryPreviousEnergyMode = nil
                }
                
                return
            }
            
            Logger.batteryMonitor.trace("Automatic low power mode was not triggered yet")
            
            // NOTE: although not strictily necessary for the current implementation,
            // we update the state even if the battery energy mode was already value .low,
            // that way the state is always representing the truth
            // this is useful in the following case
            // 1) battery energy mode is .low
            // 2) battery falls below 20%
            // 3) user changes to .automatic (if didSetAutoLowEnergyMode was not set to true, the cancelAutoLowEnergyMode would remain false, which results in 4 and 5)
            // 4) battery percentage drops by 1%
            // 5) automatic low power mode is enabled, as nothing was cancelled in 3)
            
            Logger.batteryMonitor.debug("Storing previous energy mode: \(currentBatteryEnergyMode.systemString, privacy: .public)")
            _lowBatteryPreviousEnergyMode = currentEnergyMode
            
            // settings state variable
            _didSetAutoLowEnergyMode = true
            //_didCancelAutoLowEnergyMode = false // is already false actually
            
            // only if it wasn't low already we send a notification to the user
            if currentBatteryEnergyMode != .low {
                Task {
                    // actualy set low power mode
                    await setBatteryEnergyMode(.low, fromUserInteraction: false)
                    
                    await notifications.sendAutoLowPowerEnabledModeNotification()
                }
            }
        } else {
            Logger.batteryMonitor.info("Battery level is above recharging threshold")
            
            restorePreviousBatteryMode()
        }
    }
    
    @MainActor func setupObservers() {
        // Subscribe to publishers
        timerIntervalPublisher.sink { [weak self] _ in
            Task {
                await self?.handleIntervalTimerUpdate()
            }
        }.store(in: &subscribers)
        
        powerStateUpdatePublisher.sink { [weak self] _ in
            Task {
                await self?.handlePowerStateUpdate()
            }
        }.store(in: &subscribers)
        
        _fileListener.publisher.sink { [weak self] _ in
            Task {
                await self?.handlePMPreferenceUpdate()
            }
        }.store(in: &subscribers)
        
        // AUTO LOW BATTERY
        // listen to changes in battery percentage, or in auto enable low power mode
        onChange(of: Preferences.instance.enableLowPowerModeOnLowBattery) { [weak self] in
            self?.performBatteryPercentageCheck()
        }
        
        // listen to changes in battery threshold
        onChange(of: Preferences.instance.autoLowPowerModeDischargeThreshold) { [weak self] in
            self?.performBatteryPercentageCheck()
        }
        
        onChange(of: self._didCancelAutoLowEnergyMode) { [weak self] oldValue, newValue in
            if newValue == true {
                // cancelled, so restore to previous::
            } else {
                // uncancelled, so check for battery
                self?.performBatteryPercentageCheck()
            }
        }
        
        // listen to change of current battery percentage
        onChange(of: self.batteryCurrentPercentage, initial: true) { [weak self] _, newValue in
            Logger.batteryMonitor.info("Received power state change to: \(self?.batteryCurrentPercentage ?? 0)%")
            
            guard newValue != nil else {
                Logger.batteryMonitor.warning("Received nil as new battery percentage")
                
                return
            }
            
            self?.performBatteryPercentageCheck()
        }
        
        // listen to power source change in general
        onChange(of: self.isUsingBattery) { [weak self] in
            self?.performBatteryPercentageCheck()
        }
        
        
        
        // listen to any changes in status bar image
        onChange(of: self.statusBarImage, initial: true) {
            NotificationCenter.default.post(name: .updateStatusImage, object: nil)
        }
        
        
        
        // listen to change in powersource to update widgets
        onChange(of: self._powerSourceWatcher.powerSource, initial: true) { _, newValue in
            let updatedPowerSource: PowerSource? = switch newValue {
            case .externalUPS:
                nil
            case .externalUnlimited:
                    .adapter
            case .internalBattery:
                    .battery
            case .none:
                    .none
            }
            
            WidgetStateCacheModel.instance.currentPowerSource = updatedPowerSource
        }
    }
    
    private var _fileListener = FileListener()
    
    @MainActor init() {
        Task {
            // Make sure that all state has been initalised before setting up the observers.
            // The observers need all state available and should execute the callback on initialisation if desired
            await readTerminalConfiguration()
            
            do {
                try await readChargeLimitEnabled()
            } catch {
                print(error)
            }
            
            hasFirstRead = true
            
            setupObservers()
        }
    }
}

//struct DeviceCapabilities: OptionSet {
//    static var shared = DeviceCapabilities()
//
//    let rawValue: Int
//
//    static let battery = Self(rawValue: 1 << 0)
//    static let adapter = Self(rawValue: 1 << 1)
//    static let anyEnergyMode = Self(rawValue: 1 << 2)
//    static let highEnergyMode = Self(rawValue: 1 << 3)
//
//    var isBatteryCapableDevice: Bool {
//        self.contains(.battery)
//    }
//
//    var isAdapterCapableDevice: Bool {
//        self.contains(.adapter)
//    }
//
//    var isAnyEnergyModeCapable: Bool {
//        self.contains(.anyEnergyMode)
//    }
//
//    var isHighEnergyModeCapable: Bool {
//        self.contains(.highEnergyMode)
//    }
//}






extension AppState {
    /*let old = Regex {
                "("
                AC Power|Battery Power
                ")"
                
                "(?:" // non capturing group
                "(?!" // negative lookahead
                AC Power|Battery Power
                ")"
                ".|\n" // any character/newline
                ")*?" // make it non gready
                "("
                "(?:low)?" // caputre lowpowermode or powermode
                "powermode"
                ")"
                "\\s*" // ignore any whitespaces between powermode and its value
                "(\\d+)" // capture the value
                }*/
    static let regex = Regex {
                           Capture {
                               ChoiceOf {
                                   kIOPSBatteryPowerValue
                                   kIOPSACPowerValue
                               }
                           }
                           ZeroOrMore(.reluctant) {
                               ChoiceOf {
                                   Regex {
                                       NegativeLookahead {
                                           ChoiceOf {
                                               kIOPSBatteryPowerValue
                                               kIOPSACPowerValue
                                           }
                                       }
                                       /./
                                   }
                                   "\u{A}"
                               }
                           }
                           Capture {
                               Regex {
                                   Optionally {
                                       "low"
                                   }
                                   "powermode"
                               }
                           }
                           ZeroOrMore(.whitespace)
                           Capture {
                               OneOrMore(.digit)
                           }
                       }
    
    private func parseResponse(string cmdResponse: String) -> [pmsetResponse]? {
        let matches = cmdResponse.matches(of: Self.regex)
        
        guard matches.count > 0 else {
            Logger.energyModeTerminalRegex.error("Could not match regex to terminal output")
            
            // throw error
            return nil
        }
        
        let parsed = matches.map { match in
            pmsetResponse(powerSource: match.1, energyModeKey: match.2, energyMode: match.3)
        }
        
        let filtered = parsed.filter { item in
            if item != nil {
                return true
            }
            
            return false
        }
        
        if filtered.count == 0 {
            Logger.energyModeTerminalRegex.error("No succesfull matches in terminal output")
            
            return nil
        }
        
        if let unwrapped = filtered as? [pmsetResponse] {
            return unwrapped
        } else {
            Logger.energyModeTerminalRegex.critical("Unwrapping result should always be succesfull")
            
            return nil
        }
    }
}

extension AppState {
    enum ProcessError: Error {
        case noOutput
        case process(String)
        case error(String)
        
        var localizedDescription: String {
            switch self {
            case .noOutput:
                "Unexpected nil for unwrapping output"
            case .process(let description):
                "Encountered an error while running the process. \(description)"
            case .error(let description):
                "Non empty error response. \(description)"
            }
        }
    }
    
    fileprivate func runCommand(with arguments: [String]) async throws -> String {
        Logger.energyModeTerminalProcess.notice("Initialising terminal process")
        
        let process = Process()
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        
        process.launchPath = "/usr/bin/pmset"
        process.arguments = arguments
        
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        do {
            Logger.energyModeTerminalProcess.notice("Running terminal proces")
            try process.run()
        } catch {
            Logger.energyModeTerminalProcess.warning("Encountered an error while running the process.")
            
            throw ProcessError.process(error.localizedDescription)
        }
        
        Logger.energyModeTerminalProcess.notice("Waiting to exit terminal proces")
            
        process.waitUntilExit()
        
        Logger.energyModeTerminalProcess.notice("Terminal process exited")
        
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        
        let output = String(data: outputData, encoding: .utf8)
        let error = String(data: errorData, encoding: .utf8)
        
        if let unwrappedError = error, !unwrappedError.isEmpty {
            Logger.energyModeTerminalProcess.warning("Encountered a non-empty error response")
            
            throw ProcessError.error(unwrappedError)
        }
        
        if let response = output {
            return response
        } else {
            throw ProcessError.noOutput
        }
    }
}

extension AppState {
    enum InitialiseDeviceCapacilitiesError: Error {
        case noEnergyModeKey
        
        var localizedDescription: String {
            switch self {
            case .noEnergyModeKey:
                "Response does not contain any \"powermode\" information"
            }
        }
    }
    
    @MainActor
    func intialiseDeviceConfiguration(_ response: String) throws {
//        // if already configured, we can just
//        guard !self.device.isConfigured else {
//            return
//        }
//
//        self.device.isConfigured = true
        
        guard response.contains("powermode") else {
            Logger.energyModeRetriever.warning("Device does not support any powermode configuration")
            
            throw InitialiseDeviceCapacilitiesError.noEnergyModeKey
        }
        
        Logger.energyModeRetriever.notice("Running energy mode capable device")
        
        self.device.isAnyPowerModeCapableDevice = true
        
        if response.contains("lowpowermode") == true {
            Logger.energyModeRetriever.notice("Running low power mode only device")
        } else {
            Logger.energyModeRetriever.notice("Running high power mode capable device")
            
            self.device.isHighPowerModeCapableDevice = true
        }
        
        if response.contains(kIOPSBatteryPowerValue) {
            Logger.energyModeRetriever.notice("Running battery energy mode capable device")
            self.device.isBatteryCapableDevice = true
        }
        
        if response.contains(kIOPSACPowerValue) {
            Logger.energyModeRetriever.notice("Running ac adapter energy mode capable device")
            self.device.isAdapterCapableDevice = true
        }
        
        if (self.device.isAdapterCapableDevice || self.device.isBatteryCapableDevice) && false == (self.device.isAdapterCapableDevice && self.device.isBatteryCapableDevice) {
            // any low/normal/high energy mode should have a battery and adapter mode by definition because they are only Mac laptops
            Logger.energyModeRetriever.warning("Unexpected combination of battery and adapter power modes")
        }
    }
    
    func getRawConfiguration() async throws -> String {
        try await runCommand(with: ["-g", "custom"])
    }
    
    @MainActor
    func readTerminalConfiguration() async {
        guard !isRunningAsPreview else {
            self.internalBatteryEnergyMode = .low
            self.adapterEnergyMode = .automatic
            
            return
        }
        
        Logger.energyModeRetriever.notice("Retrieving energy mode configuration from terminal")
        
        let response: String
        do {
           response = try await runCommand(with: ["-g", "custom"])
        } catch {
            // could not retrieve powermode information
            Logger.energyModeTerminal.error("Could not perform pmset get command. \(error.localizedDescription)")
            
            return
        }
        
        Logger.energyModeRetriever.info("Succesfully retrieved a terminal response")
        
        // only perform initial checks when no power mode key has been set yet
        if helper.energyModeKey == nil {
            do {
                try self.intialiseDeviceConfiguration(response)
            } catch {
                return
            }
        }
        
        Logger.energyModeRetriever.notice("Parsing terminal response")
        
        guard let parsedResponse = parseResponse(string: response) else {
            Logger.energyModeTerminal.warning("Could not obtained parsed pmset response")
            
            return
        }
        
        Logger.energyModeRetriever.info("Succesfully parsed and obtained values from terminal response")
        
        // now that all retrieving has been done
        lastRead = .now
        
        
        
        // set the power mode key if none was set yet
        if helper.energyModeKey == nil && parsedResponse.count > 0 {
            helper.energyModeKey = parsedResponse[0].energyModeKey
        }
        
        var newBatteryEnergyMode: EnergyMode? = nil
        var newAdapterEnergyMode: EnergyMode? = nil
        
        Logger.energyModeRetriever.notice("Converting values into state storable values")
        
        parsedResponse.forEach { configuration in
            switch configuration.powerSource {
            case .battery:
                newBatteryEnergyMode = configuration.energyMode
            case .adapter:
                newAdapterEnergyMode = configuration.energyMode
            }
        }
        
        Logger.energyModeRetriever.info("Succesfully converted values into state storable values")
        
//        guard batteryEnergyMode != newBatteryEnergyMode ||
//              adapterEnergyMode != newAdapterEnergyMode
//        else {
//            Logger.energyModeRetriever.info("Cancelling update. No updated values found")
//
//            return
//        }
        
        Logger.energyModeRetriever.notice("Pushing values to app state")
        
        Logger.energyModeRetriever.trace("New battery energy state is \(newBatteryEnergyMode.debugDescription, privacy: .public)")
        Logger.energyModeRetriever.trace("New adapter energy state is \(newAdapterEnergyMode.debugDescription, privacy: .public)")
        
        self.internalBatteryEnergyMode = newBatteryEnergyMode
        self.internalAdapterEnergyMode = newAdapterEnergyMode
        
        Task {
            WidgetStateCacheModel.instance.batteryEnergyMode = newBatteryEnergyMode
            WidgetStateCacheModel.instance.adapterEnergyMode = newAdapterEnergyMode
        }
    }
}

extension AppState {
    @discardableResult
    private func sendNewEnergyModeToHelper(for powerSource: PowerSource, to energyMode: EnergyMode?) async -> Bool? {
        if isRunningAsPreview {
            return false
        }
        
        guard let energyMode = energyMode else {
            return false
        }
        
        guard let energyModeKey = helper.energyModeKey else {
            Logger.energyModeRetriever.error("No energy mode key has been established")
            
            return false
        }
        
        lastSet = .now
        
        //        let cmdflag: String = powerSource.pmsetKey
        //        let cmdvalue: Int = energyMode.asInt(powerModeKey: powerModeKey)
        //        let cmdkey: String = powerModeKey.rawValue
        
        guard helper.isRunningWithHelper else {
            Logger.helperConnection.warning("Running without helper. This method should have not been reached")
            
            return false
        }
        
        defer {
            Task {
                await readTerminalConfiguration()
            }
        }
        
        do {
            Logger.helperConnection.trace("Starting sending new energy mode to helper")
            try await helper.withThrowingConnection { connection in
                try await connection.setEnergyMode(for: powerSource.rawValue, to: energyMode.rawValue, withKey: energyModeKey.rawValue)
            }
            Logger.helperConnection.trace("Succesfully sent new energy mode to helper")
            
            return true
        } catch {
            Logger.helperConnection.warning("Helper could not update energy mode with error: \(error.localizedDescription, privacy: .public)")
            
            return false
        }
    }
}

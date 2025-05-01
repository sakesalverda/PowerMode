//
//  AppState+sparkleUpdates.swift
//  PowerMode
//
//  Created by Sake Salverda on 04/02/2024.
//

import SwiftUI
import Sparkle

// Reminders:
// - An update reminder that shows in the main UI
// - An update reminder that shows in the settings view
// - The popup from Sparkle
//
// When a user SKIPS an update
// main = nil
// settings = keep
//
// When a user DISMISSES an update
// main = keep?
// settings = keep
//
// When a user INSTALLS an update
// main = keep
// settings = keep
// => as shouldPostponeRelaunchForUpdate will be called later anyway
extension AppDelegate: SPUUpdaterDelegate {
    @MainActor func feedURLString(for updater: SPUUpdater) -> String? {
        if let experimental = Preferences.instance.updateFeedString, experimental == true {
            return "https://sakesalverda.nl/powermode/appcast-debug.xml"
        }
        
        return nil
    }
    
    func updater(_ updater: SPUUpdater, didFindValidUpdate item: SUAppcastItem) {
        // set new update available
        Task { @MainActor in
            self.appState.updateAvailable = true
            self.appState.updateNotificationAvailable = true
        }
    }
    
    func updater(_ updater: SPUUpdater, didAbortWithError error: Error) {
        Task { @MainActor in
            self.appState.updateAvailable = false
            self.appState.updateNotificationAvailable = false
        }
    }
    
    func updater(_ updater: SPUUpdater, userDidMake choice: SPUUserUpdateChoice, forUpdate updateItem: SUAppcastItem, state: SPUUserUpdateState) {
        switch choice {
        case .skip:
            Task { @MainActor in
                self.appState.updateAvailable = false
            }
        case .dismiss: break
        case .install: break
        @unknown default: break
        }
    }
    
    func updaterShouldRelaunchApplication(_ updater: SPUUpdater) -> Bool {
        true
    }
    
    func updater(_ updater: SPUUpdater, shouldPostponeRelaunchForUpdate item: SUAppcastItem, untilInvokingBlock installHandler: @escaping () -> Void) -> Bool {
        Task { @MainActor in
            self.appState.updateAvailable = false
            self.appState.updateNotificationAvailable = false
            
            // TODO: Add a custom property that can be retrieved from SPUUpdater which indicates whether the helper executable received an update or if it is removed alltogether
            try await appState.helper.terminateIfActive()
            
            
            installHandler()
        }
        
        return true
    }
}

extension AppDelegate: SPUStandardUserDriverDelegate {
    var supportsGentleScheduledUpdateReminders: Bool {
        true
    }
    
    func standardUserDriverShouldShowVersionHistory(for item: SUAppcastItem) -> Bool {
        false
    }
    
    func standardUserDriverShouldHandleShowingScheduledUpdate(_ update: SUAppcastItem, andInImmediateFocus immediateFocus: Bool) -> Bool {
        // If the standard user driver will show the update in immediate focus (e.g. near app launch),
        // then let Sparkle take care of showing the update.
        // Otherwise we will handle showing any other scheduled updates
//        return immediateFocus
        
        // when the app is just launched, our implemtation is perfectly subtle
        return false
    }
    
    func standardUserDriverWillHandleShowingUpdate(_ handleShowingUpdate: Bool, forUpdate update: SUAppcastItem, state: SPUUserUpdateState) {
        // We will ignore updates that the user driver will handle showing
        // This includes user initiated (non-scheduled) updates
        guard !handleShowingUpdate else {
            return
        }
        
//        Task { @MainActor in
//            // the new version
//            let _ = update.displayVersionString
//
//            self.appState.updateAvailable = true
//            self.appState.updateNotificationAvailable = true
//        }
    }
    
    func standardUserDriverWillFinishUpdateSession() {
        // We will dismiss our gentle UI indicator if the user session for the update finishes
    }
}

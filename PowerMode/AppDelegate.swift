//
//  AppDelegate.swift
//  PowerMode
//
//  Created by Sake Salverda on 04/02/2024.
//

import SwiftUI
import OSLog
import Walberg

extension Logger {
    static let delegate = Self(.main, "delegate")
}

fileprivate struct StatusItemModifier: ViewModifier {
    var appState: AppState
    
    func body(content: Content) -> some View {
        content.environment(appState)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    @MainActor var appState: AppState = .shared
    
    internal struct ContentWrapper: View {
        var appState: AppState
        
        var body: some View {
            ContentView()
                .environment(appState)
        }
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // from https://stackoverflow.com/a/74733681
        var launchedAsLogInItem: Bool {
            let event = NSAppleEventManager.shared().currentAppleEvent
            
            return event?.eventID == kAEOpenApplication &&
                   event?.paramDescriptor(forKeyword: keyAEPropData)?.enumCodeValue == keyAELaunchedAsLogInItem
        }
        
        WidgetStateCacheModel.instance.isMainApplicationActive = true
        
//        if !appState.isRunningAsPreview && false {
//            menuState = ControlCenterStatusItem("PowerMode", image: .view) {
//                ContentWrapper(appState: self.appState)
//            }
//
//            self.statusItemManager = StatusItemViewManager(statusItem: self.menuState?.statusItem) {
//                MenuBarImage()
//                    .modifier(StatusItemModifier(appState: AppState.shared))
//            }
//
//            self.statusItemManager?.createStatusItem()
//        }
        
        
//        menuState?.statusItem.button?.image = nil
        
//        notifications.clearAllNotifications()
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//            Task {
//                await self.notifications.sendLowPowerModeNotification()
//            }
//        }
        
    }
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        WidgetStateCacheModel.instance.isMainApplicationActive = false
        
        // if helper is not running we can quit the app immediately
        
        Logger.delegate.trace("Attempting to terminate app")
        
        guard checkForRunningApp(.helper) else {
            Logger.delegate.trace("No helper is running, terminating immediately")
            
            return .terminateNow
        }
        Logger.delegate.trace("Helper is running, postponing termination till helper is closed")
        
        Task.detached {
            defer {
                Task { @MainActor in
                    Logger.delegate.trace("Sending final signal to terminate app")
                    sender.reply(toApplicationShouldTerminate: true)
                }
            }
            
            do {
                try await self.appState.helper.terminateIfActive()
                
                Logger.helperServiceManagement.trace("Succesfully terminated helper")
            } catch {
                Logger.helperServiceManagement.warning("Could not terminate active helper")
            }
        }
        
        return .terminateLater
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        
    }
}

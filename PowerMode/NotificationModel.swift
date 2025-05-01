//
//  NotificationModel.swift
//  PowerMode
//
//  Created by Sake Salverda on 20/01/2024.
//

import Foundation
import UserNotifications
import OSLog

extension Logger {
    static let notifications = Self(.main, "notification")
}

@Observable
class NotificationManager {
    let kLowPowerAutoEnabledNotification = "LOW_POWER_AUTO_ENABLED"
    
    var notificationCenter: UNUserNotificationCenter {
        UNUserNotificationCenter.current()
    }
    
    var lastNotificationTime: Date? = nil
    
//    func cleanupNotifications() {
//        removeAllDeliveredNotifications()
//    }
    
    func requestAuthorization() async {
        do {
            try await notificationCenter.requestAuthorization(options: [.badge, .alert, .sound])
        } catch {
            Logger.notifications.error("Could not request authorisation for notifications: \(error.localizedDescription)")
        }
    }
    
    func addNotification(_ request: UNNotificationRequest) async throws {
        try await notificationCenter.add(request)
        
        lastNotificationTime = .now
    }
    
    func removeAutoEnabledNotifications() {
        guard let lastNofication = lastNotificationTime else { return }
        
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [kLowPowerAutoEnabledNotification])
        
        lastNotificationTime = nil
    }
    
    func removeLowBatteryDeliveredNotifications() {
//        guard let lastNofication = lastNotificationTime else { return }
        
//        let removeNotificationsFromCenterAfter: TimeInterval = 5 * 60
        
//        if lastNofication.timeIntervalSinceNow.magnitude > removeNotificationsFromCenterAfter {
            notificationCenter.removeDeliveredNotifications(withIdentifiers: [kLowPowerAutoEnabledNotification])
//
//            lastNotificationTime = nil
//        }
    }
    
    
    func sendAutoLowPowerEnabledModeNotification() async {
        let settings = await notificationCenter.notificationSettings()
        
        guard (settings.authorizationStatus == .authorized) ||
                (settings.authorizationStatus == .provisional) else {
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Low Power Mode Enabled"
        content.body = "Low Power Mode has been enabled to conserve battery."
        
        let request = UNNotificationRequest(identifier: kLowPowerAutoEnabledNotification, content: content, trigger: nil)
        
        do {
            try await addNotification(request)
        } catch {
            Logger.notifications.error("Error sending Low Power Mode notification: \(error.localizedDescription)")
        }
    }
}

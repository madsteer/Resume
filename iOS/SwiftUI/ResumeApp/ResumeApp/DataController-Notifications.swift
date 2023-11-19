//
//  DataController-Notifications.swift
//  ResumeApp
//
//  Created by Cory Steers on 11/18/23.
//

import Foundation
import UserNotifications

extension DataController {
    /// Add a reminder for the given issue
    /// - Parameter issue: Issue that we want a reminder for
    /// - Returns: if successful returns true, otherwise returns false
    func addReminder(for issue: Issue) async -> Bool {
        do {
            let center = UNUserNotificationCenter.current()
            let settings = await center.notificationSettings()

            switch settings.authorizationStatus {
            case .notDetermined:
                let success = try await requestNotifications()

                if success {
                    try await placeReminders(for: issue)
                } else {
                    return false
                }

            case .authorized:
                try await placeReminders(for: issue)

            default:
                return false
            }

            return true
        } catch {
            return false
        }
    }

    /// Remove all reminders, if there are any, for the given issue
    /// - Parameter issue: The issue for which we want to remove reminders for
    func removeReminders(for issue: Issue) {
        let center = UNUserNotificationCenter.current()
        let id = issue.objectID.uriRepresentation().absoluteString
        center.removePendingNotificationRequests(withIdentifiers: [id])
    }

    /// Ask the user if we can have permission to send them notifications for this app
    /// - Returns: If yes we can, return true.  Otherwise return false
    private func requestNotifications() async throws -> Bool {
        let center = UNUserNotificationCenter.current()
        return try await center.requestAuthorization(options: [.alert, .sound])
    }

    /// The method where we actually build a reminder and add it to the device's local notification system
    /// - Parameter issue: The issue for which we want to set a notification for
    private func placeReminders(for issue: Issue) async throws {
        let content = UNMutableNotificationContent()
        content.title = issue.issueTitle
        content.sound = .default

        if let issueContent = issue.content {
            content.subtitle = issueContent
        }

        #if DEBUG
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        #else
            let components = Calendar.current.dateComponents([.hour, .minute], from: issue.issueReminderTime)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        #endif

        let id = issue.objectID.uriRepresentation().absoluteString
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        return try await UNUserNotificationCenter.current().add(request)
    }
}

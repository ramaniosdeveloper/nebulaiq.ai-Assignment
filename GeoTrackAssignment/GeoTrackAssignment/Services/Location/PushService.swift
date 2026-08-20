//
//  PushService.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//

import Foundation
import UserNotifications
import UIKit

/// Handles push notification permission and device registration.
///
/// `PushService` is responsible for requesting notification permission
/// from the user and registering the application for remote notifications
/// when permission is granted.
public final class PushService: NSObject, UNUserNotificationCenterDelegate {

    /// Requests permission to display push notifications.
    ///
    /// If permission is granted, the application is registered with APNs
    /// to receive remote notifications.
    ///
    /// - Throws: An error if the notification authorization request fails.
    public func requestAuthorization() async throws {
        let center = UNUserNotificationCenter.current()
        center.delegate = self

        let granted = try await center.requestAuthorization(
            options: [.alert, .sound, .badge]
        )

        guard granted else {
            return
        }
    }

    public func clearBadge() {
        Task { @MainActor in
            UNUserNotificationCenter.current().setBadgeCount(0)
        }
    }

    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {

        // Clear badge when notification is received while app is active.
        await MainActor.run {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }

        return [.banner, .sound]
    }

    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {

        // Clear badge when user taps the notification.
        await MainActor.run {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
}

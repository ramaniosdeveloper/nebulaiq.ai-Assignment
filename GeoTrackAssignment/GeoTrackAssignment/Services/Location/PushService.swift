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

        // Set this service as the notification center delegate
        // to handle notification-related events.
        center.delegate = self

        // Request permission for alerts, badges, and notification sounds.
        let granted = try await center.requestAuthorization(
            options: [
                .alert,
                .badge,
                .sound
            ]
        )

        // Register the application with Apple Push Notification service
        // only after the user grants notification permission.
        if granted {
            await MainActor.run {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
}

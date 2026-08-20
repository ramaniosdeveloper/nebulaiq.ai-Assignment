//
//  NotificationDelegate.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//


import Foundation
import UserNotifications
import UIKit

final class NotificationDelegate:
    NSObject,
    UNUserNotificationCenterDelegate {

    static let shared =
        NotificationDelegate()

    private override init() {
        super.init()
    }

    // MARK: - Foreground Notification

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {

        print(
            "Notification received while app is in foreground"
        )

        return [
            .banner,
            .sound,
            .badge
        ]
    }

    // MARK: - Notification Tapped

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {

        print(
            "User tapped notification"
        )

        await clearBadge()
    }

    // MARK: - Clear Badge

    private func clearBadge() async {

        await MainActor.run {

            UIApplication.shared
                .applicationIconBadgeNumber = 0
        }

        print(
            "Notification badge cleared"
        )
    }
}

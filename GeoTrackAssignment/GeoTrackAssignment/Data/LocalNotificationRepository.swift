//
//  LocalNotificationRepository.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//


import Foundation
import UserNotifications
import UIKit

public final class LocalNotificationRepository:
    NotificationRepository {

    public init() {
    }

    public func notifyMembers(
        groupID: GroupID,
        excluding: UserID,
        title: String,
        body: String
    ) async throws {

        let center =
            UNUserNotificationCenter.current()

        let settings =
            await center.notificationSettings()

        guard settings.authorizationStatus == .authorized else {

            print(
                "Notification permission is not granted."
            )

            return
        }

        let content =
            UNMutableNotificationContent()

        content.title = title
        content.body = body
        content.sound = .default

        let currentBadge =
            await MainActor.run {

                UIApplication.shared
                    .applicationIconBadgeNumber
            }

        content.badge =
            NSNumber(
                value: currentBadge + 1
            )

        let request =
            UNNotificationRequest(
                identifier:
                    UUID().uuidString,
                content: content,
                trigger: nil
            )

        try await center.add(request)

        print(
            "Local notification scheduled successfully."
        )
    }
}

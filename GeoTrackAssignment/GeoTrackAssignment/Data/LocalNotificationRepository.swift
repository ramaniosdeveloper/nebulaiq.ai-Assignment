//
//  LocalNotificationRepository.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//


import Foundation
import UserNotifications
import UIKit

/// Local notification implementation of `NotificationRepository`.
///
/// This repository uses `UNUserNotificationCenter` to deliver
/// notifications directly on the device.
///
/// This implementation is intended for the current assignment where
/// notifications are generated locally. In a production application,
/// notifications to other group members would normally be delivered
/// through a backend service and APNs.
///
/// - Important:
///   The `groupID` and `excluding` parameters are required by
///   `NotificationRepository`. A local notification is displayed only
///   on the current device, so those parameters are currently used
///   for logging/debugging rather than remote recipient filtering.
@MainActor
public final class LocalNotificationRepository: NotificationRepository {

    // MARK: - Constants

    /// Prefix used for locally generated notification identifiers.
    private static let notificationIdentifierPrefix = "GeoTrack.Local"

    // MARK: - Initialization

    /// Creates a local notification repository.
    public init() {}

    // MARK: - NotificationRepository

    /// Delivers a local notification to the current device.
    ///
    /// The notification is delivered immediately because the request
    /// does not contain a trigger.
    ///
    /// Before scheduling the notification, the repository verifies that
    /// the user has granted notification permission.
    ///
    /// The application badge number is incremented when the notification
    /// is created.
    ///
    /// - Parameters:
    ///   - groupID: Identifier of the tracking group associated with
    ///              the notification.
    ///   - excluding: User identifier that should be excluded from
    ///                notification delivery. This is relevant for
    ///                remote notifications but has no effect on a
    ///                local notification.
    ///   - title: Title displayed in the notification.
    ///   - body: Message displayed in the notification.
    ///
    /// - Throws:
    ///   An error if the system fails to add the notification request.
    public func notifyMembers(
        groupID: GroupID,
        excluding: UserID,
        title: String,
        body: String
    ) async throws {

        let center = UNUserNotificationCenter.current()

        guard await hasNotificationPermission(using: center) else {
            print(
                """
                [LocalNotification]
                Permission not granted.
                group=\(groupID.rawValue)
                """
            )

            return
        }

        let content = makeNotificationContent(
            title: title,
            body: body
        )

        let request = makeNotificationRequest(
            content: content
        )

        try await center.add(request)

        print(
            """
            [LocalNotification]
            Scheduled successfully.
            group=\(groupID.rawValue)
            excludedUser=\(excluding.rawValue)
            """
        )
    }

    // MARK: - Permission

    /// Checks whether local notifications are authorized.
    ///
    /// - Parameter center: Notification center used to retrieve
    ///                     authorization settings.
    /// - Returns: `true` when notifications are authorized.
    private func hasNotificationPermission(
        using center: UNUserNotificationCenter
    ) async -> Bool {

        let settings = await center.notificationSettings()

        return settings.authorizationStatus == .authorized
    }

    // MARK: - Content

    /// Creates notification content with the supplied title and body.
    ///
    /// - Parameters:
    ///   - title: Notification title.
    ///   - body: Notification message.
    ///
    /// - Returns: Configured notification content.
    private func makeNotificationContent(
        title: String,
        body: String
    ) -> UNMutableNotificationContent {

        let content = UNMutableNotificationContent()

        content.title = title
        content.body = body
        content.sound = .default
        content.badge = NSNumber(
            value: nextBadgeNumber()
        )

        return content
    }

    // MARK: - Request

    /// Creates a notification request for immediate delivery.
    ///
    /// A `nil` trigger causes the notification to be delivered
    /// immediately according to the system's notification rules.
    ///
    /// - Parameter content: Notification content.
    /// - Returns: Configured notification request.
    private func makeNotificationRequest(
        content: UNMutableNotificationContent
    ) -> UNNotificationRequest {

        let identifier = [
            Self.notificationIdentifierPrefix,
            UUID().uuidString
        ].joined(separator: ".")

        return UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: nil
        )
    }

    // MARK: - Badge

    /// Returns the next application badge number.
    ///
    /// `UIApplication` is accessed from the main actor.
    ///
    /// - Returns: Current badge number plus one.
    private func nextBadgeNumber() -> Int {
        UIApplication.shared.applicationIconBadgeNumber + 1
    }
}

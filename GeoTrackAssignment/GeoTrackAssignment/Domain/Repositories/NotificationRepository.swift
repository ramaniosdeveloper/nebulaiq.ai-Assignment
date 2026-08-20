//
//  NotificationRepository.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//

// MARK: - Notification Repository

/// Defines the contract for notifying members of a tracking group.
///
/// Implementations may use local notifications, APNs, or a backend
/// notification service. The business layer remains independent of
/// the actual notification mechanism.
public protocol NotificationRepository {

    /// Notifies group members about a tracking event.
    ///
    /// - Parameters:
    ///   - groupID: Identifier of the group whose members should be notified.
    ///   - excluding: User who should not receive the notification.
    ///   - title: Notification title.
    ///   - body: Notification message.
    /// - Throws: An error if the notification cannot be delivered.
    func notifyMembers(
        groupID: GroupID,
        excluding: UserID,
        title: String,
        body: String
    ) async throws
}

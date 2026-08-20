//
//  Repositories.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//

import Foundation

// MARK: - Group Repository

/// Defines the data-access contract for tracking groups.
///
/// The domain/use-case layer depends on this protocol instead of
/// depending on a specific storage implementation.
///
/// Concrete implementations can use:
/// - In-memory storage for testing/demo purposes.
/// - Local persistence such as Core Data or Realm.
/// - A remote REST/GraphQL API.
///
/// This keeps the business logic independent of the data source.
public protocol GroupRepository {

    /// Creates a new tracking group.
    ///
    /// - Parameters:
    ///   - name: Name of the group.
    ///   - geoFence: Geographical boundary associated with the group.
    ///   - owner: User who owns and creates the group.
    /// - Returns: The newly created group.
    /// - Throws: An error if the group cannot be created.
    func createGroup(
        name: String,
        geoFence: GeoFence,
        owner: UserID
    ) async throws -> Group

    /// Adds a user to an existing tracking group.
    ///
    /// - Parameters:
    ///   - user: User to add to the group.
    ///   - group: Identifier of the group.
    /// - Returns: The updated group.
    /// - Throws: An error if the group does not exist or the member
    ///   cannot be added.
    func addMember(
        _ user: UserID,
        to group: GroupID
    ) async throws -> Group

    /// Retrieves a tracking group by its identifier.
    ///
    /// - Parameter id: Identifier of the group.
    /// - Returns: The requested group.
    /// - Throws: An error if the group cannot be found or retrieved.
    func getGroup(
        by id: GroupID
    ) async throws -> Group

    /// Updates the geofence associated with a tracking group.
    ///
    /// - Parameters:
    ///   - groupID: Identifier of the group.
    ///   - geoFence: New geographical boundary.
    /// - Returns: The updated group.
    /// - Throws: An error if the group cannot be updated.
    func updateGeoFence(
        groupID: GroupID,
        geoFence: GeoFence
    ) async throws -> Group

    /// Returns all groups associated with a user.
    ///
    /// - Parameter user: Identifier of the user.
    /// - Returns: Groups in which the user is a member.
    /// - Throws: An error if the groups cannot be retrieved.
    func listGroups(
        for user: UserID
    ) async throws -> [Group]
}


// MARK: - Location Repository

/// Defines the data-access contract for user location information.
///
/// Implementations can store location snapshots locally or remotely.
/// The domain layer does not need to know where the location data
/// is persisted.
public protocol LocationRepository {

    /// Stores a location snapshot for a tracking group.
    ///
    /// - Parameters:
    ///   - snapshot: Location information reported by a user.
    ///   - group: Identifier of the tracking group.
    /// - Throws: An error if the location cannot be stored.
    func postLocation(
        _ snapshot: LocationSnapshot,
        for group: GroupID
    ) async throws
}


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


// MARK: - Authentication Repository

/// Defines the authentication data-access contract.
///
/// The domain layer uses this protocol to obtain information about
/// the currently authenticated user without depending on a specific
/// authentication provider.
public protocol AuthRepository {

    /// Returns the currently authenticated user.
    ///
    /// - Returns: The current authenticated user.
    /// - Throws: An error if the current user cannot be retrieved
    ///   or if authentication is unavailable.
    func currentUser() async throws -> User
}

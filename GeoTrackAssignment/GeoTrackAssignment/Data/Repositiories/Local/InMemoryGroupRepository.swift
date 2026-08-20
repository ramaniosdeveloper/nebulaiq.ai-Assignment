//
//  InMemoryGroupRepository.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//

//
//  InMemoryRepositories.swift
//  GeoTrackAssignment
//
//  Created by Raman Kumar on 20/08/26.
//

import Foundation

// MARK: - Repository Errors

/// Errors produced by the in-memory repositories.
public enum InMemoryRepositoryError: LocalizedError {

    /// The requested group could not be found.
    case groupNotFound(GroupID)

    /// Provides a user-friendly description for the repository error.
    public var errorDescription: String? {
        switch self {
        case .groupNotFound(let groupID):
            return "Group not found: \(groupID.rawValue)"
        }
    }
}

// MARK: - In-Memory Group Repository

/// In-memory implementation of `GroupRepository`.
///
/// This repository stores tracking groups in memory and is intended
/// primarily for local development, demos, and testing.
///
/// Data is not persisted between application launches.
public final class InMemoryGroupRepository: GroupRepository {

    // MARK: - Properties

    /// Groups indexed by their unique identifier.
    private var groups: [GroupID: Group] = [:]

    // MARK: - Initialization

    /// Creates an empty in-memory group repository.
    public init() {}

    // MARK: - Create

    /// Creates and stores a new tracking group.
    ///
    /// - Parameters:
    ///   - name: Name of the group.
    ///   - geoFence: Geofence associated with the group.
    ///   - owner: User who owns the group.
    ///
    /// - Returns: The newly created group.
    /// - Throws: An error if group creation fails.
    public func createGroup(
        name: String,
        geoFence: GeoFence,
        owner: UserID
    ) async throws -> Group {

        let groupID = GroupID(
            rawValue: UUID().uuidString
        )

        let group = Group(
            id: groupID,
            name: name,
            members: [owner],
            geoFence: geoFence
        )

        groups[groupID] = group

        return group
    }

    // MARK: - Members

    /// Adds a user to an existing group.
    ///
    /// If the user is already a member, the existing group is returned
    /// without creating a duplicate membership.
    ///
    /// - Parameters:
    ///   - user: User to add.
    ///   - group: Identifier of the group.
    ///
    /// - Returns: The updated group.
    /// - Throws: `InMemoryRepositoryError.groupNotFound` if the group
    ///           does not exist.
    public func addMember(
        _ user: UserID,
        to group: GroupID
    ) async throws -> Group {

        let existingGroup = try groupOrThrow(group)

        guard !existingGroup.members.contains(user) else {
            return existingGroup
        }

        let updatedGroup = Group(
            id: existingGroup.id,
            name: existingGroup.name,
            members: existingGroup.members + [user],
            geoFence: existingGroup.geoFence
        )

        groups[group] = updatedGroup

        return updatedGroup
    }

    // MARK: - Fetch

    /// Returns a group using its identifier.
    ///
    /// - Parameter id: Group identifier.
    /// - Returns: The requested group.
    /// - Throws: `InMemoryRepositoryError.groupNotFound` when the
    ///           group does not exist.
    public func getGroup(
        by id: GroupID
    ) async throws -> Group {

        try groupOrThrow(id)
    }

    // MARK: - Geofence

    /// Updates the geofence associated with a group.
    ///
    /// - Parameters:
    ///   - groupID: Identifier of the group.
    ///   - geoFence: New geofence configuration.
    ///
    /// - Returns: The updated group.
    /// - Throws: `InMemoryRepositoryError.groupNotFound` when the
    ///           group does not exist.
    public func updateGeoFence(
        groupID: GroupID,
        geoFence: GeoFence
    ) async throws -> Group {

        let existingGroup = try groupOrThrow(groupID)

        let updatedGroup = Group(
            id: existingGroup.id,
            name: existingGroup.name,
            members: existingGroup.members,
            geoFence: geoFence
        )

        groups[groupID] = updatedGroup

        return updatedGroup
    }

    // MARK: - Listing

    /// Returns all groups containing the specified user.
    ///
    /// - Parameter user: User identifier.
    /// - Returns: Groups in which the user is a member.
    public func listGroups(
        for user: UserID
    ) async throws -> [Group] {

        groups.values.filter { group in
            group.members.contains(user)
        }
    }

    // MARK: - Private Helpers

    /// Returns a group or throws when it does not exist.
    ///
    /// - Parameter groupID: Identifier of the requested group.
    /// - Returns: Existing group.
    /// - Throws: `InMemoryRepositoryError.groupNotFound`.
    private func groupOrThrow(
        _ groupID: GroupID
    ) throws -> Group {

        guard let group = groups[groupID] else {
            throw InMemoryRepositoryError.groupNotFound(groupID)
        }

        return group
    }
}

// MARK: - In-Memory Location Repository

/// In-memory implementation of `LocationRepository`.
///
/// Stores location snapshots grouped by tracking-group identifier.
///
/// This implementation is useful for development and testing when
/// a real backend is not available.
public final class InMemoryLocationRepository: LocationRepository {

    // MARK: - Properties

    /// Location snapshots indexed by group identifier.
    ///
    /// The property is publicly readable for testing/debugging but
    /// can only be modified internally by the repository.
    public private(set) var snapshots: [
        GroupID: [LocationSnapshot]
    ] = [:]

    // MARK: - Initialization

    /// Creates an empty location repository.
    public init() {}

    // MARK: - Location

    /// Stores a location snapshot for a group.
    ///
    /// - Parameters:
    ///   - snapshot: Location information to store.
    ///   - group: Identifier of the tracking group.
    ///
    /// - Throws: No error for the in-memory implementation.
    public func postLocation(
        _ snapshot: LocationSnapshot,
        for group: GroupID
    ) async throws {

        snapshots[group, default: []].append(snapshot)
    }
}

// MARK: - No-Op Notification Repository

/// Notification repository that performs no real notification delivery.
///
/// This implementation is useful when APNs or a backend notification
/// service is not available yet.
///
/// In a production implementation, this repository can be replaced
/// with an APNs/backend-backed notification repository without changing
/// the calling use cases.
public final class NoOpNotificationRepository: NotificationRepository {

    // MARK: - Initialization

    /// Creates a no-op notification repository.
    public init() {}

    // MARK: - Notifications

    /// Simulates sending a notification to group members.
    ///
    /// Instead of sending a real push notification, the notification
    /// information is printed to the console.
    ///
    /// - Parameters:
    ///   - groupID: Group whose members should receive the notification.
    ///   - excluding: User who should not receive the notification.
    ///   - title: Notification title.
    ///   - body: Notification body.
    ///
    /// - Throws: No error for the no-op implementation.
    public func notifyMembers(
        groupID: GroupID,
        excluding: UserID,
        title: String,
        body: String
    ) async throws {

        print(
            """
            [NoOpNotification]
            group=\(groupID.rawValue)
            exclude=\(excluding.rawValue)
            title=\(title)
            body=\(body)
            """
        )
    }
}

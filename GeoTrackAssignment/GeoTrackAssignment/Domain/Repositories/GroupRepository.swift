//
//  GroupRepository.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//

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

//
//  GroupRepositoryRemote.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//

import Foundation

// MARK: - Remote Group Repository

/// Remote implementation of `GroupRepository`.
///
/// `GroupRepositoryRemote` communicates with the backend through
/// `HTTPClient` and converts API DTOs into domain models.
///
/// This repository is responsible only for data access. Business
/// rules remain inside the appropriate use cases.
public final class GroupRepositoryRemote: GroupRepository {

    // MARK: - Properties

    /// HTTP client used to communicate with the backend API.
    private let client: HTTPClient

    // MARK: - Initialization

    /// Creates a remote group repository.
    ///
    /// - Parameter client: HTTP client used for API requests.
    public init(client: HTTPClient) {
        self.client = client
    }

    // MARK: - Create Group

    /// Creates a new tracking group on the remote server.
    ///
    /// - Parameters:
    ///   - name: Name of the tracking group.
    ///   - geoFence: Geofence associated with the group.
    ///   - owner: User who owns the group.
    ///
    /// - Returns: The newly created domain `Group`.
    /// - Throws: Network, server, serialization, or decoding errors.
    public func createGroup(
        name: String,
        geoFence: GeoFence,
        owner: UserID
    ) async throws -> Group {

        let body: [String: Any] = [
            "name": name,
            "owner": owner.rawValue,
            "geo": [
                "lat": geoFence.centerLat,
                "lon": geoFence.centerLon,
                "radius": geoFence.radiusMeters
            ]
        ]

        let dto: GroupDTO = try await client.post(
            "/groups",
            json: body
        )

        return dto.toDomain()
    }

    // MARK: - Add Member

    /// Adds a user to an existing remote tracking group.
    ///
    /// - Parameters:
    ///   - user: User to add to the group.
    ///   - group: Identifier of the target group.
    ///
    /// - Returns: Updated domain `Group`.
    /// - Throws: Network, server, serialization, or decoding errors.
    public func addMember(
        _ user: UserID,
        to group: GroupID
    ) async throws -> Group {

        let body: [String: Any] = [
            "userId": user.rawValue
        ]

        let dto: GroupDTO = try await client.post(
            "/groups/\(group.rawValue)/members",
            json: body
        )

        return dto.toDomain()
    }

    // MARK: - Get Group

    /// Retrieves a tracking group from the remote server.
    ///
    /// - Parameter id: Identifier of the group.
    /// - Returns: Domain `Group` corresponding to the API response.
    /// - Throws: Network, server, or decoding errors.
    public func getGroup(
        by id: GroupID
    ) async throws -> Group {

        let dto: GroupDTO = try await client.get(
            "/groups/\(id.rawValue)"
        )

        return dto.toDomain()
    }

    // MARK: - Update Geofence

    /// Updates the geofence associated with a remote group.
    ///
    /// - Parameters:
    ///   - groupID: Identifier of the group.
    ///   - geoFence: New geofence configuration.
    ///
    /// - Returns: Updated domain `Group`.
    /// - Throws: Network, server, serialization, or decoding errors.
    public func updateGeoFence(
        groupID: GroupID,
        geoFence: GeoFence
    ) async throws -> Group {

        let body: [String: Any] = [
            "lat": geoFence.centerLat,
            "lon": geoFence.centerLon,
            "radius": geoFence.radiusMeters
        ]

        let dto: GroupDTO = try await client.put(
            "/groups/\(groupID.rawValue)/geofence",
            json: body
        )

        return dto.toDomain()
    }

    // MARK: - List Groups

    /// Retrieves all groups associated with a user.
    ///
    /// - Parameter user: User whose groups should be retrieved.
    /// - Returns: Array of domain `Group` objects.
    /// - Throws: Network, server, or decoding errors.
    public func listGroups(
        for user: UserID
    ) async throws -> [Group] {

        let dtos: [GroupDTO] = try await client.get(
            "/users/\(user.rawValue)/groups"
        )

        return dtos.map { $0.toDomain() }
    }
}

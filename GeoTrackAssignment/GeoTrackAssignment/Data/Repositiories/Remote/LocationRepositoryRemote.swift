//
//  LocationRepositoryRemote.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//

import Foundation

// MARK: - Remote Location Repository

/// Remote implementation of `LocationRepository`.
///
/// Sends location snapshots to the backend for a specific tracking group.
///
/// The repository converts the domain `LocationSnapshot` into the
/// JSON representation expected by the API.
public final class LocationRepositoryRemote: LocationRepository {

    // MARK: - Properties

    /// HTTP client used to communicate with the backend API.
    private let client: HTTPClient

    // MARK: - Initialization

    /// Creates a remote location repository.
    ///
    /// - Parameter client: HTTP client used for API requests.
    public init(client: HTTPClient) {
        self.client = client
    }

    // MARK: - Location

    /// Sends a user's location snapshot to the remote server.
    ///
    /// - Parameters:
    ///   - snapshot: Location information reported by the user.
    ///   - group: Tracking group associated with the location.
    ///
    /// - Throws: Network, server, or request serialization errors.
    public func postLocation(
        _ snapshot: LocationSnapshot,
        for group: GroupID
    ) async throws {

        let json: [String: Any] = [
            "userId": snapshot.userID.rawValue,
            "timestamp": ISO8601DateFormatter().string(
                from: snapshot.timestamp
            ),
            "lat": snapshot.latitude,
            "lon": snapshot.longitude
        ]

        try await client.post(
            "/groups/\(group.rawValue)/locations",
            json: json
        )
    }
}

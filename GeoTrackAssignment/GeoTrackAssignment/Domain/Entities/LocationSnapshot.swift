//
//  LocationSnapshot.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//

import Foundation

// MARK: - Location Snapshot

/// Represents a user's location at a specific point in time.
///
/// `LocationSnapshot` is a domain model used to record location
/// information independently of Core Location or any persistence layer.
public struct LocationSnapshot: Equatable, Codable {

    /// Identifier of the user associated with this location.
    public let userID: UserID

    /// Time at which the location was recorded.
    public let timestamp: Date

    /// Latitude of the recorded location.
    public let latitude: Double

    /// Longitude of the recorded location.
    public let longitude: Double

    /// Creates a location snapshot.
    ///
    /// - Parameters:
    ///   - userID: User associated with the location.
    ///   - timestamp: Time when the location was recorded.
    ///   - latitude: Latitude of the location.
    ///   - longitude: Longitude of the location.
    public init(
        userID: UserID,
        timestamp: Date,
        latitude: Double,
        longitude: Double
    ) {
        self.userID = userID
        self.timestamp = timestamp
        self.latitude = latitude
        self.longitude = longitude
    }
}

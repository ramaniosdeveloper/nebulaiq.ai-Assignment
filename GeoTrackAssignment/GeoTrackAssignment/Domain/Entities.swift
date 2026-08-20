//
//  Entities.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//

import Foundation

// MARK: - User ID

/// Unique identifier for a user.
///
/// The identifier is kept as a value type so it can safely be used
/// throughout the domain layer without depending on a specific
/// authentication or database implementation.
public struct UserID: Hashable, Codable {

    /// Raw string representation of the user identifier.
    public let rawValue: String
}


// MARK: - Group ID

/// Unique identifier for a tracking group.
public struct GroupID: Hashable, Codable {

    /// Raw string representation of the group identifier.
    public let rawValue: String
}


// MARK: - User

/// Represents a user participating in a tracking group.
///
/// This is a domain model and is independent of authentication,
/// networking, or persistence frameworks.
public struct User: Equatable, Codable {

    /// Unique identifier of the user.
    public let id: UserID

    /// Name displayed to other group members.
    public let displayName: String

    /// Optional push notification token associated with the user.
    ///
    /// This can be used by a notification layer to deliver
    /// notifications to the user's device.
    public let deviceToken: String?

    /// Creates a user domain model.
    ///
    /// - Parameters:
    ///   - id: Unique user identifier.
    ///   - displayName: Name displayed in the application.
    ///   - deviceToken: Optional push notification token.
    public init(
        id: UserID,
        displayName: String,
        deviceToken: String?
    ) {
        self.id = id
        self.displayName = displayName
        self.deviceToken = deviceToken
    }
}


// MARK: - Geofence

/// Defines the geographical boundary associated with a tracking group.
///
/// A geofence is represented by a center coordinate and a radius.
/// When a tracked user moves outside this boundary, the application
/// can trigger the required tracking and notification flow.
public struct GeoFence: Equatable, Codable {

    /// Latitude of the geofence center.
    public let centerLat: Double

    /// Longitude of the geofence center.
    public let centerLon: Double

    /// Radius of the geofence in meters.
    public let radiusMeters: Double

    /// Creates a geofence.
    ///
    /// - Parameters:
    ///   - centerLat: Latitude of the geofence center.
    ///   - centerLon: Longitude of the geofence center.
    ///   - radiusMeters: Geofence radius in meters.
    public init(
        centerLat: Double,
        centerLon: Double,
        radiusMeters: Double
    ) {
        self.centerLat = centerLat
        self.centerLon = centerLon
        self.radiusMeters = radiusMeters
    }
}


// MARK: - Group

/// Represents a tracking group.
///
/// A group contains its members and the geofence that defines
/// the geographical area being monitored.
public struct Group: Equatable, Codable {

    /// Unique identifier of the group.
    public let id: GroupID

    /// Display name of the tracking group.
    public let name: String

    /// Identifiers of users belonging to the group.
    public let members: [UserID]

    /// Geographical boundary associated with the group.
    public let geoFence: GeoFence

    /// Creates a tracking group.
    ///
    /// - Parameters:
    ///   - id: Unique group identifier.
    ///   - name: Display name of the group.
    ///   - members: Users who belong to the group.
    ///   - geoFence: Geographical boundary monitored by the group.
    public init(
        id: GroupID,
        name: String,
        members: [UserID],
        geoFence: GeoFence
    ) {
        self.id = id
        self.name = name
        self.members = members
        self.geoFence = geoFence
    }
}


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

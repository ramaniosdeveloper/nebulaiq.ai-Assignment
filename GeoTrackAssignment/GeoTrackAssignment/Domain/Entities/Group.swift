//
//  Group.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//

import Foundation

// MARK: - Group ID

/// Unique identifier for a tracking group.
public struct GroupID: Hashable, Codable {

    /// Raw string representation of the group identifier.
    public let rawValue: String
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

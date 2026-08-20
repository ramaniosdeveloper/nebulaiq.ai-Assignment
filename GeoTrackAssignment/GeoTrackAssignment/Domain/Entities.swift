//
//  Entities.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//

import Foundation

public struct UserID: Hashable, Codable { public let rawValue: String }
public struct GroupID: Hashable, Codable { public let rawValue: String }

public struct User: Equatable, Codable {
    public let id: UserID
    public let displayName: String
    public let deviceToken: String?
    public init(id: UserID, displayName: String, deviceToken: String?) {
        self.id = id
        self.displayName = displayName
        self.deviceToken = deviceToken
    }
}

public struct GeoFence: Equatable, Codable {
    public let centerLat: Double
    public let centerLon: Double
    public let radiusMeters: Double
    public init(centerLat: Double, centerLon: Double, radiusMeters: Double) {
        self.centerLat = centerLat
        self.centerLon = centerLon
        self.radiusMeters = radiusMeters
    }
}

public struct Group: Equatable, Codable {
    public let id: GroupID
    public let name: String
    public let members: [UserID]
    public let geoFence: GeoFence
    public init(id: GroupID, name: String, members: [UserID], geoFence: GeoFence) {
        self.id = id
        self.name = name
        self.members = members
        self.geoFence = geoFence
    }
}

public struct LocationSnapshot: Equatable, Codable {
    public let userID: UserID
    public let timestamp: Date
    public let latitude: Double
    public let longitude: Double
    public init(userID: UserID, timestamp: Date, latitude: Double, longitude: Double) {
        self.userID = userID
        self.timestamp = timestamp
        self.latitude = latitude
        self.longitude = longitude
    }
}

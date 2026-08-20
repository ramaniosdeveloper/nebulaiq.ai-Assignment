//
//  TestDataFactory.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//

import Foundation
@testable import GeoTrackAssignment

enum TestDataFactory {

    static let userID = UserID(
        rawValue: "user-1"
    )

    static let anotherUserID = UserID(
        rawValue: "user-2"
    )

    static let groupID = GroupID(
        rawValue: "group-1"
    )

    static let user = User(
        id: userID,
        displayName: "Raman",
        deviceToken: nil
    )

    static let geoFence = GeoFence(
        centerLat: 30.7046,
        centerLon: 76.7179,
        radiusMeters: 100
    )

    static let group = Group(
        id: groupID,
        name: "Family",
        members: [
            userID,
            anotherUserID
        ],
        geoFence: geoFence
    )

    static func locationSnapshot(
        latitude: Double = 30.7046,
        longitude: Double = 76.7179
    ) -> LocationSnapshot {

        LocationSnapshot(
            userID: userID,
            timestamp: Date(),
            latitude: latitude,
            longitude: longitude
        )
    }
}

//
//  UseCases.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//

import Foundation

// MARK: - Create Group

public struct CreateGroupUseCase {

    private let groupRepo: GroupRepository
    private let authRepo: AuthRepository

    public init(
        groupRepo: GroupRepository,
        authRepo: AuthRepository
    ) {
        self.groupRepo = groupRepo
        self.authRepo = authRepo
    }

    public func execute(
        name: String,
        geoFence: GeoFence
    ) async throws -> Group {

        let user = try await authRepo.currentUser()

        return try await groupRepo.createGroup(
            name: name,
            geoFence: geoFence,
            owner: user.id
        )
    }
}


// MARK: - Join Group

public struct JoinGroupUseCase {

    private let groupRepo: GroupRepository
    private let authRepo: AuthRepository

    public init(
        groupRepo: GroupRepository,
        authRepo: AuthRepository
    ) {
        self.groupRepo = groupRepo
        self.authRepo = authRepo
    }

    public func execute(
        groupID: GroupID
    ) async throws -> Group {

        let user = try await authRepo.currentUser()

        return try await groupRepo.addMember(
            user.id,
            to: groupID
        )
    }
}


// MARK: - Report Location

public struct ReportLocationUseCase {

    private let locationRepo: LocationRepository
    private let groupRepo: GroupRepository
    private let notificationRepo: NotificationRepository
    private let authRepo: AuthRepository

    public init(
        locationRepo: LocationRepository,
        groupRepo: GroupRepository,
        notificationRepo: NotificationRepository,
        authRepo: AuthRepository
    ) {
        self.locationRepo = locationRepo
        self.groupRepo = groupRepo
        self.notificationRepo = notificationRepo
        self.authRepo = authRepo
    }

    public func execute(
        groupID: GroupID,
        latitude: Double,
        longitude: Double
    ) async throws {

        // 1. Get current user
        let user = try await authRepo.currentUser()

        // 2. Create location snapshot
        let snapshot = LocationSnapshot(
            userID: user.id,
            timestamp: Date(),
            latitude: latitude,
            longitude: longitude
        )

        // 3. Save/report location
        try await locationRepo.postLocation(
            snapshot,
            for: groupID
        )

        // 4. Get tracking group
        let group = try await groupRepo.getGroup(
            by: groupID
        )

        // 5. Check whether user is inside geofence
        let isInside = GeoFenceEvaluator.isInside(
            geoFence: group.geoFence,
            lat: latitude,
            lon: longitude
        )

        print("--------------------------------")
        print("Location Check")
        print("User: \(user.displayName)")
        print("Latitude: \(latitude)")
        print("Longitude: \(longitude)")
        print("Inside Geofence: \(isInside)")
        print("--------------------------------")

        // 6. User is outside the geofence
        if !isInside {

            print("⚠️ USER LEFT GEOFENCE")

            try await notificationRepo.notifyMembers(
                groupID: groupID,
                excluding: user.id,
                title: "Member left geofence",
                body: "\(user.displayName) moved out of the region."
            )

            print("🔔 Notification sent")
        }
    }
}


// MARK: - Geofence Evaluator

enum GeoFenceEvaluator {

    static func isInside(
        geoFence: GeoFence,
        lat: Double,
        lon: Double
    ) -> Bool {

        let distance = haversine(
            lat1: geoFence.centerLat,
            lon1: geoFence.centerLon,
            lat2: lat,
            lon2: lon
        )

        print("Distance from geofence center: \(distance)m")
        print("Allowed radius: \(geoFence.radiusMeters)m")

        return distance <= geoFence.radiusMeters
    }

    private static func haversine(
        lat1: Double,
        lon1: Double,
        lat2: Double,
        lon2: Double
    ) -> Double {

        let earthRadius = 6_371_000.0

        let dLat =
            (lat2 - lat1) * .pi / 180

        let dLon =
            (lon2 - lon1) * .pi / 180

        let latitude1 =
            lat1 * .pi / 180

        let latitude2 =
            lat2 * .pi / 180

        let a =
            sin(dLat / 2) * sin(dLat / 2)
            +
            cos(latitude1)
            * cos(latitude2)
            * sin(dLon / 2)
            * sin(dLon / 2)

        let c =
            2 * atan2(
                sqrt(a),
                sqrt(1 - a)
            )

        return earthRadius * c
    }
}

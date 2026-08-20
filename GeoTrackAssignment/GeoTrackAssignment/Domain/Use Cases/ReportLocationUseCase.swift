//
//  ReportLocationUseCase.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//

import Foundation

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

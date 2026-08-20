//
//  Dependencies.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//

import Foundation

// MARK: - Dependency Container

/// Central dependency container for the application.
///
/// `Dependencies` acts as the composition root of the application.
/// It creates and wires together repository implementations, use cases,
/// and application services.
///
/// The rest of the application depends on protocols and use cases rather
/// than creating concrete data-layer objects directly.
///
/// This approach keeps dependency creation in one place and makes it
/// easier to replace implementations for testing or future production
/// integrations.
public enum Dependencies {

    // MARK: - Repositories

    /// Repository responsible for creating, retrieving, and updating groups.
    ///
    /// The current implementation uses in-memory storage.
    public static let groupRepo: GroupRepository =
        InMemoryGroupRepository()

    /// Repository responsible for storing location snapshots.
    ///
    /// The current implementation uses in-memory storage.
    public static let locationRepo: LocationRepository =
        InMemoryLocationRepository()

    /// Repository responsible for notifying group members.
    ///
    /// The current implementation uses local notifications.
    public static let notificationRepo: NotificationRepository =
        LocalNotificationRepository()

    /// Repository responsible for providing the currently authenticated user.
    ///
    /// The current implementation uses `DummyAuthRepo` for the assignment.
    public static let authRepo: AuthRepository =
        DummyAuthRepo()


    // MARK: - Use Cases

    /// Use case responsible for creating a new tracking group.
    public static let createGroupUseCase =
        CreateGroupUseCase(
            groupRepo: groupRepo,
            authRepo: authRepo
        )

    /// Use case responsible for adding the current user to a tracking group.
    public static let joinGroupUseCase =
        JoinGroupUseCase(
            groupRepo: groupRepo,
            authRepo: authRepo
        )

    /// Use case responsible for reporting the user's location,
    /// evaluating the geofence, and notifying group members when required.
    public static let reportLocationUseCase =
        ReportLocationUseCase(
            locationRepo: locationRepo,
            groupRepo: groupRepo,
            notificationRepo: notificationRepo,
            authRepo: authRepo
        )


    // MARK: - Services

    /// Core Location service responsible for requesting permissions
    /// and monitoring the user's geofence.
    public static let locationService =
        LocationService()
}


// MARK: - Dummy Authentication

/// Development authentication repository used for the assignment.
///
/// This implementation does not perform real authentication.
/// It always returns a fixed user and can later be replaced with
/// a real authentication implementation without changing the
/// presentation or domain layers.
final class DummyAuthRepo: AuthRepository {

    /// Returns the currently simulated authenticated user.
    ///
    /// - Returns: A fixed development user.
    /// - Throws: Never throws in the current implementation.
    func currentUser() async throws -> User {

        User(
            id: UserID(rawValue: "me"),
            displayName: "Me",
            deviceToken: nil
        )
    }
}

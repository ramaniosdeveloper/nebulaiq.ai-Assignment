//
//  Dependencies.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//

import Foundation

/// Central dependency container for the application.
///
/// `Dependencies` provides shared instances of repositories, use cases,
/// and services used throughout the application.
///
/// This approach keeps dependency creation in one place and makes it easier
/// to replace implementations later, for example with:
/// - API-backed repositories
/// - Mock repositories for unit testing
/// - Production authentication services
public enum Dependencies {

    // MARK: - Repositories

    /// Repository responsible for creating, joining, and managing groups.
    ///
    /// Currently uses an in-memory implementation.
    /// This can later be replaced with a remote/API-backed repository.
    public static let groupRepo: GroupRepository =
        InMemoryGroupRepository()

    /// Repository responsible for storing and retrieving location data.
    ///
    /// Currently uses an in-memory implementation.
    public static let locationRepo: LocationRepository =
        InMemoryLocationRepository()

    /// Repository responsible for handling local notifications.
    ///
    /// Currently uses the local notification implementation.
    public static let notificationRepo: NotificationRepository =
        LocalNotificationRepository()

    /// Repository responsible for authentication and retrieving
    /// information about the currently logged-in user.
    ///
    /// Currently uses a dummy authentication implementation.
    /// This can later be replaced with a real authentication provider.
    public static let authRepo: AuthRepository =
        DummyAuthRepo()


    // MARK: - Use Cases

    /// Creates a new tracking group.
    ///
    /// This use case depends on:
    /// - `GroupRepository` for group persistence
    /// - `AuthRepository` for the current user
    public static let createGroupUseCase =
        CreateGroupUseCase(
            groupRepo: groupRepo,
            authRepo: authRepo
        )

    /// Allows the current user to join an existing tracking group.
    ///
    /// This use case uses the authenticated user and group repository
    /// to validate and perform the join operation.
    public static let joinGroupUseCase =
        JoinGroupUseCase(
            groupRepo: groupRepo,
            authRepo: authRepo
        )

    /// Reports the current user's location.
    ///
    /// This use case coordinates:
    /// - Location persistence
    /// - Group membership information
    /// - Authentication
    /// - Notification handling
    ///
    /// It is responsible for processing location updates and triggering
    /// notifications when required by the application's geofencing rules.
    public static let reportLocationUseCase =
        ReportLocationUseCase(
            locationRepo: locationRepo,
            groupRepo: groupRepo,
            notificationRepo: notificationRepo,
            authRepo: authRepo
        )


    // MARK: - Location

    /// Service responsible for accessing the device's location.
    ///
    /// The service encapsulates location-related functionality and keeps
    /// platform-specific location handling separate from business logic.
    public static let locationService =
        LocationService()
}


// MARK: - Dummy Authentication

/// Simple authentication repository used for development and testing.
///
/// `DummyAuthRepo` provides a fixed user instead of communicating with
/// a real authentication server.
///
/// This implementation can be replaced with a production authentication
/// repository such as Firebase Auth, Auth0, or a custom backend service.
final class DummyAuthRepo: AuthRepository {

    /// Returns the currently authenticated user.
    ///
    /// - Returns: A dummy `User` representing the current device/user.
    /// - Throws: An authentication error if retrieving the user fails.
    func currentUser() async throws -> User {
        return User(
            id: UserID(rawValue: "me"),
            displayName: "Me",
            deviceToken: nil
        )
    }
}

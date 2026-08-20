//
//  Dependencies.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//

import Foundation

public enum Dependencies {

    // MARK: - Repositories

    public static let groupRepo:
        GroupRepository =
        InMemoryGroupRepository()

    public static let locationRepo:
        LocationRepository =
        InMemoryLocationRepository()

    public static let notificationRepo:
        NotificationRepository =
        LocalNotificationRepository()

    public static let authRepo:
        AuthRepository =
        DummyAuthRepo()


    // MARK: - Use Cases

    public static let createGroupUseCase =
        CreateGroupUseCase(
            groupRepo: groupRepo,
            authRepo: authRepo
        )

    public static let joinGroupUseCase =
        JoinGroupUseCase(
            groupRepo: groupRepo,
            authRepo: authRepo
        )

    public static let reportLocationUseCase =
        ReportLocationUseCase(
            locationRepo: locationRepo,
            groupRepo: groupRepo,
            notificationRepo: notificationRepo,
            authRepo: authRepo
        )


    // MARK: - Location

    public static let locationService =
        LocationService()
}


// MARK: - Dummy Authentication

final class DummyAuthRepo: AuthRepository {

    func currentUser() async throws -> User {

        return User(
            id: UserID(rawValue: "me"),
            displayName: "Me",
            deviceToken: nil
        )
    }
}

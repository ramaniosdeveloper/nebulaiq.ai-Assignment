//
//  ReportLocationUseCase.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//

import Foundation

// MARK: - Report Location Use Case

/// Reports the current user's location for a tracking group.
///
/// This use case is responsible for:
/// - Getting the currently authenticated user.
/// - Creating a location snapshot.
/// - Reporting the snapshot to the location repository.
/// - Retrieving the group's geo-fence.
/// - Determining whether the user is inside the geo-fenced region.
/// - Notifying other group members when the user moves outside the region.
///
/// The use case coordinates the required repositories while keeping
/// the business logic independent from the UI layer.
public struct ReportLocationUseCase {

    // MARK: - Dependencies

    /// Repository responsible for storing/reporting location snapshots.
    private let locationRepository: LocationRepository

    /// Repository responsible for retrieving tracking groups.
    private let groupRepository: GroupRepository

    /// Repository responsible for sending group notifications.
    private let notificationRepository: NotificationRepository

    /// Repository responsible for retrieving the authenticated user.
    private let authRepository: AuthRepository

    // MARK: - Initialization

    /// Creates a report-location use case.
    ///
    /// - Parameters:
    ///   - locationRepo: Repository used to report user locations.
    ///   - groupRepo: Repository used to retrieve tracking groups.
    ///   - notificationRepo: Repository used to notify group members.
    ///   - authRepo: Repository used to retrieve the current user.
    public init(
        locationRepo: LocationRepository,
        groupRepo: GroupRepository,
        notificationRepo: NotificationRepository,
        authRepo: AuthRepository
    ) {
        self.locationRepository = locationRepo
        self.groupRepository = groupRepo
        self.notificationRepository = notificationRepo
        self.authRepository = authRepo
    }

    // MARK: - Execute

    /// Reports the user's current location for a tracking group.
    ///
    /// The location is first persisted/reported and then evaluated
    /// against the group's geo-fence.
    ///
    /// If the user is outside the geo-fenced region, the other
    /// members of the group are notified.
    ///
    /// - Parameters:
    ///   - groupID: Identifier of the tracking group.
    ///   - latitude: Current latitude of the user.
    ///   - longitude: Current longitude of the user.
    ///
    /// - Throws: An error if authentication, location reporting,
    ///   group retrieval, or notification delivery fails.
    public func execute(
        groupID: GroupID,
        latitude: Double,
        longitude: Double
    ) async throws {

        let user = try await authRepository.currentUser()

        let snapshot = makeLocationSnapshot(
            userID: user.id,
            latitude: latitude,
            longitude: longitude
        )

        try await reportLocation(
            snapshot,
            for: groupID
        )

        let group = try await groupRepository.getGroup(
            by: groupID
        )

        let isInside = GeoFenceEvaluator.isInside(
            geoFence: group.geoFence,
            lat: latitude,
            lon: longitude
        )

        guard !isInside else {
            return
        }

        try await notifyMembers(
            groupID: groupID,
            user: user
        )
    }
}

// MARK: - Private Helpers

private extension ReportLocationUseCase {

    /// Creates a location snapshot for the specified user.
    ///
    /// - Parameters:
    ///   - userID: Identifier of the user reporting the location.
    ///   - latitude: Current latitude.
    ///   - longitude: Current longitude.
    ///
    /// - Returns: A new `LocationSnapshot`.
    func makeLocationSnapshot(
        userID: UserID,
        latitude: Double,
        longitude: Double
    ) -> LocationSnapshot {
        LocationSnapshot(
            userID: userID,
            timestamp: Date(),
            latitude: latitude,
            longitude: longitude
        )
    }

    /// Reports a location snapshot for a tracking group.
    ///
    /// - Parameters:
    ///   - snapshot: Location snapshot to report.
    ///   - groupID: Tracking group associated with the location.
    ///
    /// - Throws: An error if the location repository fails.
    func reportLocation(
        _ snapshot: LocationSnapshot,
        for groupID: GroupID
    ) async throws {
        try await locationRepository.postLocation(
            snapshot,
            for: groupID
        )
    }

    /// Notifies the members of a tracking group that a user has
    /// moved outside the group's geo-fenced region.
    ///
    /// The user who moved outside the region is excluded from
    /// receiving the notification.
    ///
    /// - Parameters:
    ///   - groupID: Tracking group associated with the event.
    ///   - user: User who moved outside the geo-fence.
    ///
    /// - Throws: An error if notification delivery fails.
    func notifyMembers(
        groupID: GroupID,
        user: User
    ) async throws {
        try await notificationRepository.notifyMembers(
            groupID: groupID,
            excluding: user.id,
            title: "Member left geofence",
            body: "\(user.displayName) moved out of the region."
        )
    }
}

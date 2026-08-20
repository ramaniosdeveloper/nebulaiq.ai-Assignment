//
//  GroupViewModel.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//

import Foundation
import Combine

/// View model responsible for managing tracking groups.
///
/// `GroupViewModel` coordinates between the UI and the application's
/// use cases, repositories, and location service.
///
/// Responsibilities:
/// - Load groups for the current user.
/// - Create new tracking groups.
/// - Join existing tracking groups.
/// - Select the active tracking group.
/// - Start geo-fence monitoring for the selected group.
/// - Expose operation errors to the UI.
///
/// The view model is isolated to the main actor because it owns
/// observable UI state.
@MainActor
public final class GroupViewModel: ObservableObject {

    // MARK: - Published Properties

    /// Groups available to the current user.
    @Published
    public private(set) var groups: [Group] = []

    /// Currently selected tracking group.
    @Published
    public private(set) var selectedGroup: Group?

    /// Error or status message displayed by the UI.
    ///
    /// A `nil` value indicates that there is no message to display.
    @Published
    public var statusMessage: String?

    // MARK: - Dependencies

    /// Use case responsible for creating a tracking group.
    private let createGroupUseCase: CreateGroupUseCase

    /// Use case responsible for joining an existing tracking group.
    private let joinGroupUseCase: JoinGroupUseCase

    /// Use case responsible for reporting the user's location.
    private let reportLocationUseCase: ReportLocationUseCase

    /// Repository used to retrieve tracking groups.
    private let groupRepository: GroupRepository

    /// Repository used to retrieve the currently authenticated user.
    private let authRepository: AuthRepository

    /// Service responsible for geo-fence and location monitoring.
    private let locationService: LocationService

    // MARK: - Initialization

    /// Creates a group view model.
    ///
    /// - Parameters:
    ///   - createGroup: Use case used to create a new tracking group.
    ///   - joinGroup: Use case used to join an existing tracking group.
    ///   - reportLocation: Use case used to report the user's location.
    ///   - groupRepo: Repository used to access tracking groups.
    ///   - authRepo: Repository used to access the current user.
    ///   - locationService: Service responsible for location monitoring.
    public init(
        createGroup: CreateGroupUseCase,
        joinGroup: JoinGroupUseCase,
        reportLocation: ReportLocationUseCase,
        groupRepo: GroupRepository,
        authRepo: AuthRepository,
        locationService: LocationService
    ) {
        self.createGroupUseCase = createGroup
        self.joinGroupUseCase = joinGroup
        self.reportLocationUseCase = reportLocation
        self.groupRepository = groupRepo
        self.authRepository = authRepo
        self.locationService = locationService
    }

    // MARK: - Load Groups

    /// Loads all tracking groups belonging to the current user.
    ///
    /// After successfully loading the groups, the first group is
    /// automatically selected and geo-fence monitoring is started.
    ///
    /// If loading fails, `statusMessage` is populated with an
    /// appropriate error message.
    public func loadGroups() async {
        do {
            let currentUser = try await authRepository.currentUser()

            let loadedGroups = try await groupRepository.listGroups(
                for: currentUser.id
            )

            groups = loadedGroups

            if let firstGroup = loadedGroups.first {
                select(group: firstGroup)
            }
        } catch {
            statusMessage = "Failed to load groups: \(error.localizedDescription)"
        }
    }

    // MARK: - Create Group

    /// Creates a new tracking group.
    ///
    /// The supplied coordinates and radius are converted into a
    /// `GeoFence` before the create-group use case is executed.
    ///
    /// After successful creation:
    /// - The new group is added to `groups`.
    /// - The new group becomes the selected group.
    /// - Geo-fence monitoring starts for the new group.
    ///
    /// - Parameters:
    ///   - name: Name of the tracking group.
    ///   - center: Latitude and longitude of the geo-fence center.
    ///   - radius: Geo-fence radius in meters.
    public func create(
        name: String,
        center: (latitude: Double, longitude: Double),
        radius: Double
    ) async {
        do {
            let geoFence = GeoFence(
                centerLat: center.latitude,
                centerLon: center.longitude,
                radiusMeters: radius
            )

            let group = try await createGroupUseCase.execute(
                name: name,
                geoFence: geoFence
            )

            groups.append(group)
            select(group: group)
        } catch {
            statusMessage = "Create failed: \(error.localizedDescription)"
        }
    }

    // MARK: - Join Group

    /// Joins an existing tracking group.
    ///
    /// The group is added to the user's group list if it is not
    /// already present. The joined group is then selected and
    /// geo-fence monitoring is started.
    ///
    /// - Parameter groupID: Identifier of the group to join.
    public func join(groupID: GroupID) async {
        do {
            let group = try await joinGroupUseCase.execute(
                groupID: groupID
            )

            addGroupIfNeeded(group)
            select(group: group)
        } catch {
            statusMessage = "Join failed: \(error.localizedDescription)"
        }
    }

    // MARK: - Select Group

    /// Selects a tracking group and starts geo-fence monitoring.
    ///
    /// - Parameter group: Group that should become the active group.
    public func select(group: Group) {
        selectedGroup = group

        locationService.startMonitoring(
            for: group
        )
    }
}

// MARK: - Private Helpers

private extension GroupViewModel {

    /// Adds a group to the local collection if it does not already exist.
    ///
    /// - Parameter group: Group to add.
    func addGroupIfNeeded(_ group: Group) {
        guard !groups.contains(where: { $0.id == group.id }) else {
            return
        }

        groups.append(group)
    }
}

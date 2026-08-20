//
//  GroupListView.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//

import SwiftUI

/// Displays all tracking groups available to the current user.
///
/// Responsibilities:
/// - Loads the user's tracking groups.
/// - Displays groups in a list.
/// - Allows the user to select a group.
/// - Navigates to group creation.
/// - Displays errors reported by the view model.
public struct GroupListView: View {

    // MARK: - Properties

    @StateObject private var viewModel: GroupViewModel

    // MARK: - Initialization

    /// Creates a group list view.
    ///
    /// - Parameter viewModel: The view model responsible for
    ///   managing tracking groups.
    public init(viewModel: GroupViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - Body

    public var body: some View {
        NavigationStack {
            groupList
                .navigationTitle("My Groups")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink("Create") {
                            CreateGroupView(vm: viewModel)
                        }
                    }
                }
                .task {
                    await viewModel.loadGroups()
                }
                .alert(
                    "Error",
                    isPresented: errorAlertBinding
                ) {
                    Button("OK") {
                        viewModel.statusMessage = nil
                    }
                } message: {
                    Text(viewModel.statusMessage ?? "")
                }
        }
    }
}

// MARK: - View Components

private extension GroupListView {

    /// Displays all tracking groups available to the current user.
    var groupList: some View {
        List(viewModel.groups, id: \.id.rawValue) { group in
            Button {
                viewModel.select(group: group)
            } label: {
                Text(group.name)
            }
        }
    }

    /// Binding used to present and dismiss the error alert.
    ///
    /// The alert is displayed whenever `statusMessage`
    /// contains an error message.
    var errorAlertBinding: Binding<Bool> {
        Binding(
            get: {
                viewModel.statusMessage != nil
            },
            set: { isPresented in
                if !isPresented {
                    viewModel.statusMessage = nil
                }
            }
        )
    }
}

// MARK: - Preview

#Preview("Group List") {

    let groupRepository = PreviewGroupRepository()
    let authRepository = PreviewAuthRepository()

    let createGroupUseCase = CreateGroupUseCase(
        groupRepo: groupRepository,
        authRepo: authRepository
    )

    let joinGroupUseCase = JoinGroupUseCase(
        groupRepo: groupRepository,
        authRepo: authRepository
    )

    let reportLocationUseCase = ReportLocationUseCase(
        locationRepo: PreviewLocationRepository(),
        groupRepo: groupRepository,
        notificationRepo: PreviewNotificationRepository(),
        authRepo: authRepository
    )

    let viewModel = GroupViewModel(
        createGroup: createGroupUseCase,
        joinGroup: joinGroupUseCase,
        reportLocation: reportLocationUseCase,
        groupRepo: groupRepository,
        authRepo: authRepository,
        locationService: LocationService()
    )

    GroupListView(viewModel: viewModel)
}

// MARK: - Preview Group Repository

/// In-memory group repository used only by SwiftUI previews.
private final class PreviewGroupRepository: GroupRepository {

    func createGroup(
        name: String,
        geoFence: GeoFence,
        owner: UserID
    ) async throws -> Group {

        Group(
            id: GroupID(
                rawValue: UUID().uuidString
            ),
            name: name,
            members: [owner],
            geoFence: geoFence
        )
    }

    func addMember(
        _ user: UserID,
        to group: GroupID
    ) async throws -> Group {

        try await getGroup(by: group)
    }

    func getGroup(
        by id: GroupID
    ) async throws -> Group {

        Group(
            id: id,
            name: "Test Group",
            members: [
                UserID(rawValue: "u1")
            ],
            geoFence: GeoFence(
                centerLat: 37.3317,
                centerLon: -122.0307,
                radiusMeters: 100
            )
        )
    }

    func updateGeoFence(
        groupID: GroupID,
        geoFence: GeoFence
    ) async throws -> Group {

        try await getGroup(by: groupID)
    }

    func listGroups(
        for user: UserID
    ) async throws -> [Group] {

        [
            try await getGroup(
                by: GroupID(
                    rawValue: "g1"
                )
            )
        ]
    }
}

// MARK: - Preview Auth Repository

/// Authentication repository used only by SwiftUI previews.
private final class PreviewAuthRepository: AuthRepository {

    func currentUser() async throws -> User {

        User(
            id: UserID(
                rawValue: "u1"
            ),
            displayName: "You",
            deviceToken: nil
        )
    }
}

// MARK: - Preview Location Repository

/// Location repository used only by SwiftUI previews.
private final class PreviewLocationRepository: LocationRepository {

    func postLocation(
        _ snapshot: LocationSnapshot,
        for group: GroupID
    ) async throws {

        // Preview only.
    }
}

// MARK: - Preview Notification Repository

/// Notification repository used only by SwiftUI previews.
private final class PreviewNotificationRepository: NotificationRepository {

    func notifyMembers(
        groupID: GroupID,
        excluding: UserID,
        title: String,
        body: String
    ) async throws {

        // Preview only.
    }
}

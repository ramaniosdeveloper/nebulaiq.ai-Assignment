//
//  GroupListView.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//

import SwiftUI

public struct GroupListView: View {

    @StateObject private var vm: GroupViewModel

    public init(viewModel: GroupViewModel) {
        _vm = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            List(vm.groups, id: \.id.rawValue) { group in
                Button {
                    vm.select(group: group)
                } label: {
                    Text(group.name)
                }
            }
            .navigationTitle("My Groups")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink("Create") {
                        CreateGroupView(vm: vm)
                    }
                }
            }
            .task {
                await vm.loadGroups()
            }
            .alert(
                "Error",
                isPresented: Binding(
                    get: {
                        vm.statusMessage != nil
                    },
                    set: { newValue in
                        if !newValue {
                            vm.statusMessage = nil
                        }
                    }
                )
            ) {
                Button("OK") {
                    vm.statusMessage = nil
                }
            } message: {
                Text(vm.statusMessage ?? "")
            }
        }
    }
}


// MARK: - Preview

#Preview {

    let groupRepo = PreviewGroupRepo()
    let authRepo = PreviewAuthRepo()

    let createGroupUseCase = CreateGroupUseCase(
        groupRepo: groupRepo,
        authRepo: authRepo
    )

    let joinGroupUseCase = JoinGroupUseCase(
        groupRepo: groupRepo,
        authRepo: authRepo
    )

    let reportLocationUseCase = ReportLocationUseCase(
        locationRepo: PreviewLocationRepo(),
        groupRepo: groupRepo,
        notificationRepo: PreviewNotificationRepo(),
        authRepo: authRepo
    )

    let viewModel = GroupViewModel(
        createGroup: createGroupUseCase,
        joinGroup: joinGroupUseCase,
        reportLocation: reportLocationUseCase,
        groupRepo: groupRepo,
        authRepo: authRepo,
        locationService: LocationService()
    )

    GroupListView(viewModel: viewModel)
}


// MARK: - Preview Group Repository

private final class PreviewGroupRepo: GroupRepository {

    func createGroup(
        name: String,
        geoFence: GeoFence,
        owner: UserID
    ) async throws -> Group {

        return Group(
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

        return try await getGroup(
            by: group
        )
    }

    func getGroup(
        by id: GroupID
    ) async throws -> Group {

        return Group(
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

        return try await getGroup(
            by: groupID
        )
    }

    func listGroups(
        for user: UserID
    ) async throws -> [Group] {

        return [
            try await getGroup(
                by: GroupID(
                    rawValue: "g1"
                )
            )
        ]
    }
}


// MARK: - Preview Auth Repository

private final class PreviewAuthRepo: AuthRepository {

    func currentUser() async throws -> User {

        return User(
            id: UserID(
                rawValue: "u1"
            ),
            displayName: "You",
            deviceToken: nil
        )
    }
}


// MARK: - Preview Location Repository

private final class PreviewLocationRepo: LocationRepository {

    func postLocation(
        _ snapshot: LocationSnapshot,
        for group: GroupID
    ) async throws {

        // Preview only
    }
}


// MARK: - Preview Notification Repository

private final class PreviewNotificationRepo: NotificationRepository {

    func notifyMembers(
        groupID: GroupID,
        excluding: UserID,
        title: String,
        body: String
    ) async throws {

        // Preview only
    }
}

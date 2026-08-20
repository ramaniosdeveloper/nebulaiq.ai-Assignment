//
//  GroupViewModel.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//

import Foundation
import Combine

@MainActor
public final class GroupViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published
    public var groups: [Group] = []

    @Published
    public var selectedGroup: Group?

    @Published
    public var statusMessage: String?


    // MARK: - Dependencies

    private let createGroup: CreateGroupUseCase
    private let joinGroup: JoinGroupUseCase
    private let reportLocation: ReportLocationUseCase

    private let groupRepo: GroupRepository
    private let authRepo: AuthRepository

    private let locationService: LocationService


    // MARK: - Init

    public init(
        createGroup: CreateGroupUseCase,
        joinGroup: JoinGroupUseCase,
        reportLocation: ReportLocationUseCase,
        groupRepo: GroupRepository,
        authRepo: AuthRepository,
        locationService: LocationService
    ) {
        self.createGroup = createGroup
        self.joinGroup = joinGroup
        self.reportLocation = reportLocation
        self.groupRepo = groupRepo
        self.authRepo = authRepo
        self.locationService = locationService
    }


    // MARK: - Load Groups

    public func loadGroups() async {

        do {

            let me =
                try await authRepo.currentUser()

            groups =
                try await groupRepo.listGroups(
                    for: me.id
                )

            // If there is an existing group,
            // select it and start monitoring.
            if let firstGroup = groups.first {

                select(group: firstGroup)
            }

        } catch {

            statusMessage =
                "Failed to load groups: \(error.localizedDescription)"
        }
    }


    // MARK: - Create Group

    public func create(
        name: String,
        center: (Double, Double),
        radius: Double
    ) async {

        do {

            // Create geofence
            let geoFence = GeoFence(
                centerLat: center.0,
                centerLon: center.1,
                radiusMeters: radius
            )

            // Create group
            let group =
                try await createGroup.execute(
                    name: name,
                    geoFence: geoFence
                )

            // Add to UI
            groups.append(group)

            // Select group and start monitoring
            select(group: group)

        } catch {

            statusMessage =
                "Create failed: \(error.localizedDescription)"
        }
    }


    // MARK: - Join Group

    public func join(
        groupID: GroupID
    ) async {

        do {

            let group =
                try await joinGroup.execute(
                    groupID: groupID
                )

            // Avoid duplicate group
            if !groups.contains(where: {
                $0.id == group.id
            }) {

                groups.append(group)
            }

            // Start monitoring
            select(group: group)

        } catch {

            statusMessage =
                "Join failed: \(error.localizedDescription)"
        }
    }


    // MARK: - Select Group

    public func select(
        group: Group
    ) {

        selectedGroup = group

        // Start geofence monitoring
        locationService.startMonitoring(
            for: group
        )
    }
}

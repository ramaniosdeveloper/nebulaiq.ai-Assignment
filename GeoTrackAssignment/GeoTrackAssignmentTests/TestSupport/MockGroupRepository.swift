//
//  MockGroupRepository.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//

import Foundation
@testable import GeoTrackAssignment

final class MockGroupRepository: GroupRepository {

    var createdGroup: Group?
    var groupToReturn: Group?
    var groupsToReturn: [Group] = []

    var createError: Error?
    var addMemberError: Error?
    var getGroupError: Error?
    var listGroupsError: Error?

    private(set) var createGroupCallCount = 0
    private(set) var addMemberCallCount = 0
    private(set) var getGroupCallCount = 0
    private(set) var updateGeoFenceCallCount = 0
    private(set) var listGroupsCallCount = 0

    private(set) var lastCreatedName: String?
    private(set) var lastCreatedGeoFence: GeoFence?
    private(set) var lastCreatedOwner: UserID?

    private(set) var lastAddedUser: UserID?
    private(set) var lastAddedGroup: GroupID?

    private(set) var lastRequestedGroupID: GroupID?
    private(set) var lastListUserID: UserID?

    func createGroup(
        name: String,
        geoFence: GeoFence,
        owner: UserID
    ) async throws -> Group {

        createGroupCallCount += 1

        lastCreatedName = name
        lastCreatedGeoFence = geoFence
        lastCreatedOwner = owner

        if let createError {
            throw createError
        }

        if let createdGroup {
            return createdGroup
        }

        return Group(
            id: TestDataFactory.groupID,
            name: name,
            members: [owner],
            geoFence: geoFence
        )
    }

    func addMember(
        _ user: UserID,
        to group: GroupID
    ) async throws -> Group {

        addMemberCallCount += 1

        lastAddedUser = user
        lastAddedGroup = group

        if let addMemberError {
            throw addMemberError
        }

        guard let groupToReturn else {
            throw MockError.groupNotConfigured
        }

        return groupToReturn
    }

    func getGroup(
        by id: GroupID
    ) async throws -> Group {

        getGroupCallCount += 1
        lastRequestedGroupID = id

        if let getGroupError {
            throw getGroupError
        }

        guard let groupToReturn else {
            throw MockError.groupNotConfigured
        }

        return groupToReturn
    }

    func updateGeoFence(
        groupID: GroupID,
        geoFence: GeoFence
    ) async throws -> Group {

        updateGeoFenceCallCount += 1

        guard let groupToReturn else {
            throw MockError.groupNotConfigured
        }

        return groupToReturn
    }

    func listGroups(
        for user: UserID
    ) async throws -> [Group] {

        listGroupsCallCount += 1
        lastListUserID = user

        if let listGroupsError {
            throw listGroupsError
        }

        return groupsToReturn
    }
}

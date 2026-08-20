//
//  Repositories.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//

import Foundation

public protocol GroupRepository {
    func createGroup(name: String, geoFence: GeoFence, owner: UserID) async throws -> Group
    func addMember(_ user: UserID, to group: GroupID) async throws -> Group
    func getGroup(by id: GroupID) async throws -> Group
    func updateGeoFence(groupID: GroupID, geoFence: GeoFence) async throws -> Group
    func listGroups(for user: UserID) async throws -> [Group]
}

public protocol LocationRepository {
    func postLocation(_ snapshot: LocationSnapshot, for group: GroupID) async throws
}

public protocol NotificationRepository {
    func notifyMembers(groupID: GroupID, excluding: UserID, title: String, body: String) async throws
}

public protocol AuthRepository {
    func currentUser() async throws -> User
}

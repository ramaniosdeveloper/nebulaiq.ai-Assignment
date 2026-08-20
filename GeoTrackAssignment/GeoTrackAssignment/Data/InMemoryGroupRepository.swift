//
//  InMemoryGroupRepository.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//

import Foundation

public final class InMemoryGroupRepository: GroupRepository {
    private var groups: [GroupID: Group] = [:]

    public init() {}

    public func createGroup(name: String, geoFence: GeoFence, owner: UserID) async throws -> Group {
        let id = GroupID(rawValue: UUID().uuidString)
        let group = Group(id: id, name: name, members: [owner], geoFence: geoFence)
        groups[id] = group
        return group
    }

    public func addMember(_ user: UserID, to group: GroupID) async throws -> Group {
        guard var g = groups[group] else { throw NSError(domain: "InMemory", code: 404) }
        if !g.members.contains(user) { g = Group(id: g.id, name: g.name, members: g.members + [user], geoFence: g.geoFence) }
        groups[group] = g
        return g
    }

    public func getGroup(by id: GroupID) async throws -> Group {
        guard let g = groups[id] else { throw NSError(domain: "InMemory", code: 404) }
        return g
    }

    public func updateGeoFence(groupID: GroupID, geoFence: GeoFence) async throws -> Group {
        guard var g = groups[groupID] else { throw NSError(domain: "InMemory", code: 404) }
        g = Group(id: g.id, name: g.name, members: g.members, geoFence: geoFence)
        groups[groupID] = g
        return g
    }

    public func listGroups(for user: UserID) async throws -> [Group] {
        return groups.values.filter { $0.members.contains(user) }
    }
}

public final class InMemoryLocationRepository: LocationRepository {
    public private(set) var snapshots: [GroupID: [LocationSnapshot]] = [:]
    public init() {}
    public func postLocation(_ snapshot: LocationSnapshot, for group: GroupID) async throws {
        snapshots[group, default: []].append(snapshot)
    }
}

public final class NoOpNotificationRepository: NotificationRepository {
    public init() {}
    public func notifyMembers(groupID: GroupID, excluding: UserID, title: String, body: String) async throws {
        // No-op: no APNs/backend.
        print("[NoOpNotification] group=\(groupID.rawValue) exclude=\(excluding.rawValue) title=\(title) body=\(body)")
    }
}

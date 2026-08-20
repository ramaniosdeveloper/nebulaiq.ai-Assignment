//
//  RepositoriesRemote.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//

import Foundation
import UserNotifications

struct GroupDTO: Codable {
    let id: String
    let name: String
    let members: [String]
    let geo: GeoDTO
}
struct GeoDTO: Codable { let lat: Double; let lon: Double; let radius: Double }

extension GroupDTO {
    func toDomain() -> Group {
        Group(id: GroupID(rawValue: id),
              name: name,
              members: members.map { UserID(rawValue: $0) },
              geoFence: GeoFence(centerLat: geo.lat, centerLon: geo.lon, radiusMeters: geo.radius))
    }
}

public final class GroupRepositoryRemote: GroupRepository {
    private let client: HTTPClient
    public init(client: HTTPClient) { self.client = client }

    public func createGroup(name: String, geoFence: GeoFence, owner: UserID) async throws -> Group {
        let body: [String: Any] = [
            "name": name,
            "owner": owner.rawValue,
            "geo": ["lat": geoFence.centerLat, "lon": geoFence.centerLon, "radius": geoFence.radiusMeters]
        ]
        let dto: GroupDTO = try await client.post("/groups", json: body)
        return dto.toDomain()
    }

    public func addMember(_ user: UserID, to group: GroupID) async throws -> Group {
        let dto: GroupDTO = try await client.post("/groups/\(group.rawValue)/members", json: ["userId": user.rawValue])
        return dto.toDomain()
    }

    public func getGroup(by id: GroupID) async throws -> Group {
        let dto: GroupDTO = try await client.get("/groups/\(id.rawValue)")
        return dto.toDomain()
    }

    public func updateGeoFence(groupID: GroupID, geoFence: GeoFence) async throws -> Group {
        let dto: GroupDTO = try await client.put("/groups/\(groupID.rawValue)/geofence",
                                                 json: ["lat": geoFence.centerLat, "lon": geoFence.centerLon, "radius": geoFence.radiusMeters])
        return dto.toDomain()
    }

    public func listGroups(for user: UserID) async throws -> [Group] {
        let dtos: [GroupDTO] = try await client.get("/users/\(user.rawValue)/groups")
        return dtos.map { $0.toDomain() }
    }
}

public final class LocationRepositoryRemote: LocationRepository {
    private let client: HTTPClient
    public init(client: HTTPClient) { self.client = client }

    public func postLocation(_ snapshot: LocationSnapshot, for group: GroupID) async throws {
        let json: [String: Any] = [
            "userId": snapshot.userID.rawValue,
            "timestamp": ISO8601DateFormatter().string(from: snapshot.timestamp),
            "lat": snapshot.latitude,
            "lon": snapshot.longitude
        ]
        try await client.post("/groups/\(group.rawValue)/locations", json: json)
    }
}

/*
public final class LocalNotificationRepository: NotificationRepository {

    public init() {}

    public func notifyMembers(
        groupID: GroupID,
        excluding: UserID,
        title: String,
        body: String
    ) async throws {

        let center = UNUserNotificationCenter.current()

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        try await center.add(request)

        print("Local notification scheduled")
        print("Title: \(title)")
        print("Body: \(body)")
    }
}
*/

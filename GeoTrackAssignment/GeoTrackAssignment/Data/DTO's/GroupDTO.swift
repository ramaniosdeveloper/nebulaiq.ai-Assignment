//
//  GroupDTO.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//

// MARK: - Group DTO

/// Data-transfer object representing a tracking group returned by
/// the remote API.
///
/// `GroupDTO` belongs to the data layer and is converted into the
/// domain `Group` model using `toDomain()`.
struct GroupDTO: Codable {

    /// Unique identifier of the group.
    let id: String

    /// Display name of the group.
    let name: String

    /// User identifiers belonging to the group.
    let members: [String]

    /// Geofence configuration associated with the group.
    let geo: GeoDTO
}

// MARK: - Group DTO Mapping

extension GroupDTO {

    /// Converts the API representation into the domain model.
    ///
    /// This keeps API-specific DTO types isolated from the
    /// application's domain layer.
    ///
    /// - Returns: A domain `Group` instance.
    func toDomain() -> Group {
        Group(
            id: GroupID(rawValue: id),
            name: name,
            members: members.map {
                UserID(rawValue: $0)
            },
            geoFence: GeoFence(
                centerLat: geo.lat,
                centerLon: geo.lon,
                radiusMeters: geo.radius
            )
        )
    }
}

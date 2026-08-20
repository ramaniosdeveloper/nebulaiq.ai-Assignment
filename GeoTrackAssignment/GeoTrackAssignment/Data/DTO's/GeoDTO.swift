//
//  GeoDTO.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//

// MARK: - Geo DTO

/// Data-transfer object representing geofence information
/// received from the remote API.
struct GeoDTO: Codable {

    /// Latitude of the geofence center.
    let lat: Double

    /// Longitude of the geofence center.
    let lon: Double

    /// Geofence radius in meters.
    let radius: Double
}

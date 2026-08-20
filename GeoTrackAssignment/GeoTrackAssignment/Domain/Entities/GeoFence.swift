//
//  GeoFence.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//

import Foundation

// MARK: - Geofence

/// Defines the geographical boundary associated with a tracking group.
///
/// A geofence is represented by a center coordinate and a radius.
/// When a tracked user moves outside this boundary, the application
/// can trigger the required tracking and notification flow.
public struct GeoFence: Equatable, Codable {

    /// Latitude of the geofence center.
    public let centerLat: Double

    /// Longitude of the geofence center.
    public let centerLon: Double

    /// Radius of the geofence in meters.
    public let radiusMeters: Double

    /// Creates a geofence.
    ///
    /// - Parameters:
    ///   - centerLat: Latitude of the geofence center.
    ///   - centerLon: Longitude of the geofence center.
    ///   - radiusMeters: Geofence radius in meters.
    public init(
        centerLat: Double,
        centerLon: Double,
        radiusMeters: Double
    ) {
        self.centerLat = centerLat
        self.centerLon = centerLon
        self.radiusMeters = radiusMeters
    }
}

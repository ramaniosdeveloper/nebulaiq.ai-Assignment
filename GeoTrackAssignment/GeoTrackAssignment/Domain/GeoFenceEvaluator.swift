//
//  GeoFenceEvaluator.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//

import Foundation

// MARK: - Geofence Evaluator

/// Provides geofence-related calculations for the domain layer.
///
/// `GeoFenceEvaluator` determines whether a given latitude and longitude
/// are inside the configured `GeoFence`.
///
/// The evaluator contains only business logic and does not depend on
/// Core Location, SwiftUI, UIKit, repositories, or other data sources.
public enum GeoFenceEvaluator {

    // MARK: - Geofence Check

    /// Determines whether a location is inside the specified geofence.
    ///
    /// The distance between the geofence center and the provided
    /// coordinates is calculated using the Haversine formula.
    ///
    /// - Parameters:
    ///   - geoFence: Geofence containing the center coordinate and
    ///     allowed radius.
    ///   - lat: Latitude of the location being evaluated.
    ///   - lon: Longitude of the location being evaluated.
    ///
    /// - Returns:
    ///   `true` when the location is inside or exactly on the
    ///   geofence boundary; otherwise `false`.
    public static func isInside(
        geoFence: GeoFence,
        lat: Double,
        lon: Double
    ) -> Bool {

        let distance = haversine(
            lat1: geoFence.centerLat,
            lon1: geoFence.centerLon,
            lat2: lat,
            lon2: lon
        )

        print(
            "Distance from geofence center: \(distance)m"
        )

        print(
            "Allowed radius: \(geoFence.radiusMeters)m"
        )

        return distance <= geoFence.radiusMeters
    }


    // MARK: - Haversine Calculation

    /// Calculates the distance between two geographic coordinates
    /// using the Haversine formula.
    ///
    /// The Haversine formula calculates the great-circle distance
    /// between two points on the Earth's surface.
    ///
    /// - Parameters:
    ///   - lat1: Latitude of the first coordinate.
    ///   - lon1: Longitude of the first coordinate.
    ///   - lat2: Latitude of the second coordinate.
    ///   - lon2: Longitude of the second coordinate.
    ///
    /// - Returns:
    ///   Distance between the two coordinates in meters.
    private static func haversine(
        lat1: Double,
        lon1: Double,
        lat2: Double,
        lon2: Double
    ) -> Double {

        let earthRadius = 6_371_000.0

        let dLat =
            (lat2 - lat1) * .pi / 180

        let dLon =
            (lon2 - lon1) * .pi / 180

        let latitude1 =
            lat1 * .pi / 180

        let latitude2 =
            lat2 * .pi / 180

        let a =
            sin(dLat / 2)
            * sin(dLat / 2)
            +
            cos(latitude1)
            * cos(latitude2)
            * sin(dLon / 2)
            * sin(dLon / 2)

        let c =
            2 * atan2(
                sqrt(a),
                sqrt(1 - a)
            )

        return earthRadius * c
    }
}

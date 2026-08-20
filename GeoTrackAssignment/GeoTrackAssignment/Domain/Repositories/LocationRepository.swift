//
//  LocationRepository.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//

// MARK: - Location Repository

/// Defines the data-access contract for user location information.
///
/// Implementations can store location snapshots locally or remotely.
/// The domain layer does not need to know where the location data
/// is persisted.
public protocol LocationRepository {

    /// Stores a location snapshot for a tracking group.
    ///
    /// - Parameters:
    ///   - snapshot: Location information reported by a user.
    ///   - group: Identifier of the tracking group.
    /// - Throws: An error if the location cannot be stored.
    func postLocation(
        _ snapshot: LocationSnapshot,
        for group: GroupID
    ) async throws
}

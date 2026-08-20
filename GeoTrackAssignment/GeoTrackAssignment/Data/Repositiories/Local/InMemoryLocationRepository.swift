//
//  InMemoryLocationRepository.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//

// MARK: - In-Memory Location Repository

/// In-memory implementation of `LocationRepository`.
///
/// Stores location snapshots grouped by tracking-group identifier.
///
/// This implementation is useful for development and testing when
/// a real backend is not available.
public final class InMemoryLocationRepository: LocationRepository {

    // MARK: - Properties

    /// Location snapshots indexed by group identifier.
    ///
    /// The property is publicly readable for testing/debugging but
    /// can only be modified internally by the repository.
    public private(set) var snapshots: [
        GroupID: [LocationSnapshot]
    ] = [:]

    // MARK: - Initialization

    /// Creates an empty location repository.
    public init() {}

    // MARK: - Location

    /// Stores a location snapshot for a group.
    ///
    /// - Parameters:
    ///   - snapshot: Location information to store.
    ///   - group: Identifier of the tracking group.
    ///
    /// - Throws: No error for the in-memory implementation.
    public func postLocation(
        _ snapshot: LocationSnapshot,
        for group: GroupID
    ) async throws {

        snapshots[group, default: []].append(snapshot)
    }
}


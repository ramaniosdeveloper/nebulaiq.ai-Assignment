//
//  MockLocationRepository.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//

import Foundation
@testable import GeoTrackAssignment

final class MockLocationRepository: LocationRepository {

    private(set) var postLocationCallCount = 0

    private(set) var lastSnapshot: LocationSnapshot?
    private(set) var lastGroupID: GroupID?

    var error: Error?

    func postLocation(
        _ snapshot: LocationSnapshot,
        for group: GroupID
    ) async throws {

        postLocationCallCount += 1

        lastSnapshot = snapshot
        lastGroupID = group

        if let error {
            throw error
        }
    }
}

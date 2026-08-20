//
//  MockLocationMonitoringService.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//

import Foundation
import CoreLocation
@testable import GeoTrackAssignment

final class MockLocationMonitoringService: LocationMonitoringService {

    private(set) var startMonitoringCallCount = 0
    private(set) var stopMonitoringCallCount = 0

    private(set) var lastMonitoredGroup: Group?

    var currentLocation: CLLocation?

    var getCurrentLocationError: Error?

    func requestPermissions() {
    }

    func requestAlwaysPermission() {
    }

    func startMonitoring(for group: Group) {

        startMonitoringCallCount += 1

        lastMonitoredGroup = group
    }

    func stopMonitoring() {

        stopMonitoringCallCount += 1
    }

    func getCurrentLocation() async throws -> CLLocation {

        if let getCurrentLocationError {
            throw getCurrentLocationError
        }

        guard let currentLocation else {
            throw MockError.forcedFailure
        }

        return currentLocation
    }
}

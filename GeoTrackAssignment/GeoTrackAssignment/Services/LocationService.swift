//
//  LocationService.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//

//
//  LocationService.swift
//  GeoTrackAssignment
//

import Foundation
import CoreLocation
import Combine

public final class LocationService: NSObject, ObservableObject {

    private let manager = CLLocationManager()

    private var currentGroup: Group?

    @Published public private(set) var currentLocation: CLLocation?

    private var locationContinuation:
        CheckedContinuation<CLLocation, Error>?

    public override init() {
        super.init()

        manager.delegate = self

        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 10

        // IMPORTANT:
        // Do NOT use allowsBackgroundLocationUpdates = true here.
        // It was causing your previous Simulator crash.
    }

    // MARK: - Permission

    public func requestPermissions() {

        manager.requestWhenInUseAuthorization()
    }

    public func requestAlwaysPermission() {

        manager.requestAlwaysAuthorization()
    }

    // MARK: - Get Current Location

    public func getCurrentLocation() async throws -> CLLocation {

        if let location = manager.location {
            await MainActor.run {
                self.currentLocation = location
            }

            return location
        }

        return try await withCheckedThrowingContinuation {
            continuation in

            self.locationContinuation = continuation

            manager.requestLocation()
        }
    }

    // MARK: - Start Geofence Monitoring

    public func startMonitoring(for group: Group) {

        // Remove old regions
        for region in manager.monitoredRegions {
            manager.stopMonitoring(for: region)
        }

        currentGroup = group

        let center = CLLocationCoordinate2D(
            latitude: group.geoFence.centerLat,
            longitude: group.geoFence.centerLon
        )

        let radius = group.geoFence.radiusMeters

        print("========== GEOFENCE ==========")
        print("Group: \(group.name)")
        print("Latitude: \(center.latitude)")
        print("Longitude: \(center.longitude)")
        print("Radius: \(radius) meters")
        print("==============================")

        let region = CLCircularRegion(
            center: center,
            radius: radius,
            identifier: group.id.rawValue
        )

        region.notifyOnEntry = false
        region.notifyOnExit = true

        manager.startMonitoring(for: region)
    }

    // MARK: - Stop Monitoring

    public func stopMonitoring() {

        for region in manager.monitoredRegions {
            manager.stopMonitoring(for: region)
        }

        currentGroup = nil
    }
}


// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {

    public func locationManagerDidChangeAuthorization(
        _ manager: CLLocationManager
    ) {
        switch manager.authorizationStatus {

        case .notDetermined:
            print("Location: NOT DETERMINED")

        case .authorizedWhenInUse:
            print("Location: WHEN IN USE")

            // Ask for Always after When In Use has been granted.
            manager.requestAlwaysAuthorization()

        case .authorizedAlways:
            print("Location: ALWAYS")

        case .denied:
            print("Location: DENIED")

        case .restricted:
            print("Location: RESTRICTED")

        @unknown default:
            print("Location: UNKNOWN")
        }
    }
    
    public func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {

        guard let location = locations.last else {
            return
        }

        print("========== LOCATION ==========")
            print("Lat: \(location.coordinate.latitude)")
            print("Lon: \(location.coordinate.longitude)")
            print("Accuracy: \(location.horizontalAccuracy)m")
            print("==============================")
        
        DispatchQueue.main.async {
            self.currentLocation = location
        }

        // Complete getCurrentLocation()
        if let continuation = locationContinuation {

            self.locationContinuation = nil

            continuation.resume(
                returning: location
            )
        }

        // If this update came because the user
        // exited the monitored region, report it.
        guard let group = currentGroup else {
            return
        }

        Task {

            do {

                try await Dependencies.reportLocationUseCase.execute(
                    groupID: group.id,
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )

            } catch {

                print(
                    "Report location error: \(error.localizedDescription)"
                )
            }
        }
    }

    public func locationManager(
        _ manager: CLLocationManager,
        didExitRegion region: CLRegion
    ) {

        guard region is CLCircularRegion else {
            return
        }

        print("USER EXITED GEOFENCE")

        // Get the latest GPS location
        manager.requestLocation()
    }

    public func locationManager(
        _ manager: CLLocationManager,
        didEnterRegion region: CLRegion
    ) {

        print("USER ENTERED GEOFENCE")
    }

    public func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {

        print(
            "Location error: \(error.localizedDescription)"
        )

        if let continuation = locationContinuation {

            locationContinuation = nil

            continuation.resume(
                throwing: error
            )
        }
    }
}

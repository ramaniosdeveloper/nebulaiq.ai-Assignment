//
//  LocationService.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//


import Foundation
import CoreLocation
import Combine

/// Provides location services and geofence monitoring for tracking groups.
///
/// `LocationService` is responsible for:
/// - Requesting location permissions.
/// - Fetching the user's current location.
/// - Monitoring a group's geofence.
/// - Publishing the latest location to SwiftUI.
/// - Reporting location updates when a geofence event occurs.
///
/// The service uses `CLLocationManager` for all Core Location operations.
public final class LocationService: NSObject, ObservableObject {

    // MARK: - Properties

    /// Core Location manager responsible for permissions,
    /// location updates, and geofence monitoring.
    private let manager = CLLocationManager()

    /// The group whose geofence is currently being monitored.
    private var currentGroup: Group?

    /// The latest known device location.
    ///
    /// The setter is private so that location updates can only be
    /// modified by `LocationService`.
    @Published
    public private(set) var currentLocation: CLLocation?

    /// Continuation used to bridge `CLLocationManager.requestLocation()`
    /// with Swift Concurrency.
    private var locationContinuation:
        CheckedContinuation<CLLocation, Error>?


    // MARK: - Initialization

    /// Creates and configures the location service.
    ///
    /// The location manager is configured with:
    /// - Best available location accuracy.
    /// - A 10-meter distance filter.
    ///
    /// Background location updates are intentionally not enabled here.
    /// Geofence monitoring is used instead of continuous background
    /// location tracking.
    public override init() {
        super.init()

        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 10
    }


    // MARK: - Permission

    /// Requests permission to access the user's location while
    /// the application is in use.
    public func requestPermissions() {
        manager.requestWhenInUseAuthorization()
    }

    /// Requests permission for continuous location access.
    ///
    /// This permission is required when the application needs to
    /// monitor geofences while it is not actively being used.
    public func requestAlwaysPermission() {
        manager.requestAlwaysAuthorization()
    }


    // MARK: - Current Location

    /// Returns the user's most recently available location.
    ///
    /// If Core Location already has a location, it is returned immediately.
    /// Otherwise, a one-time location request is started and the method
    /// waits asynchronously for the location manager callback.
    ///
    /// - Returns: The current `CLLocation`.
    /// - Throws: A location error if the location request fails.
    public func getCurrentLocation() async throws -> CLLocation {

        // Return the cached location when available.
        if let location = manager.location {
            updatePublishedLocation(location)
            return location
        }

        // Request a fresh location when no cached location exists.
        return try await withCheckedThrowingContinuation { continuation in

            self.locationContinuation = continuation

            manager.requestLocation()
        }
    }


    // MARK: - Geofence Monitoring

    /// Starts monitoring the geofence associated with a tracking group.
    ///
    /// Any previously monitored regions are removed before the new
    /// group's geofence is registered.
    ///
    /// - Parameter group: Tracking group whose geofence should be monitored.
    public func startMonitoring(for group: Group) {

        stopMonitoredRegions()

        currentGroup = group

        let center = CLLocationCoordinate2D(
            latitude: group.geoFence.centerLat,
            longitude: group.geoFence.centerLon
        )

        let radius = group.geoFence.radiusMeters

        logGeofence(
            group: group,
            center: center,
            radius: radius
        )

        let region = CLCircularRegion(
            center: center,
            radius: radius,
            identifier: group.id.rawValue
        )

        // We only need to react when the user leaves the
        // configured geofence.
        region.notifyOnEntry = false
        region.notifyOnExit = true

        manager.startMonitoring(for: region)
    }


    /// Stops monitoring all currently registered geofences.
    ///
    /// Also clears the currently monitored tracking group.
    public func stopMonitoring() {

        stopMonitoredRegions()

        currentGroup = nil
    }


    // MARK: - Private Helpers

    /// Stops all regions currently monitored by Core Location.
    private func stopMonitoredRegions() {

        for region in manager.monitoredRegions {
            manager.stopMonitoring(for: region)
        }
    }

    /// Updates the published location on the main thread.
    ///
    /// - Parameter location: Latest device location.
    private func updatePublishedLocation(_ location: CLLocation) {

        DispatchQueue.main.async { [weak self] in
            self?.currentLocation = location
        }
    }

    /// Completes a pending `getCurrentLocation()` request.
    ///
    /// - Parameter location: Location returned by Core Location.
    private func completeLocationRequest(
        with location: CLLocation
    ) {

        guard let continuation = locationContinuation else {
            return
        }

        locationContinuation = nil

        continuation.resume(returning: location)
    }

    /// Fails a pending `getCurrentLocation()` request.
    ///
    /// - Parameter error: Error returned by Core Location.
    private func failLocationRequest(
        with error: Error
    ) {

        guard let continuation = locationContinuation else {
            return
        }

        locationContinuation = nil

        continuation.resume(throwing: error)
    }

    /// Reports a location update to the application's business layer.
    ///
    /// - Parameters:
    ///   - location: Latest device location.
    ///   - group: Currently monitored tracking group.
    private func reportLocation(
        _ location: CLLocation,
        for group: Group
    ) {

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

    /// Prints geofence configuration information for debugging.
    ///
    /// - Parameters:
    ///   - group: Tracking group being monitored.
    ///   - center: Geofence center coordinate.
    ///   - radius: Geofence radius in meters.
    private func logGeofence(
        group: Group,
        center: CLLocationCoordinate2D,
        radius: CLLocationDistance
    ) {

        print("========== GEOFENCE ==========")
        print("Group: \(group.name)")
        print("Latitude: \(center.latitude)")
        print("Longitude: \(center.longitude)")
        print("Radius: \(radius) meters")
        print("==============================")
    }

    /// Prints the latest location information for debugging.
    ///
    /// - Parameter location: Latest device location.
    private func logLocation(_ location: CLLocation) {

        print("========== LOCATION ==========")
        print("Lat: \(location.coordinate.latitude)")
        print("Lon: \(location.coordinate.longitude)")
        print("Accuracy: \(location.horizontalAccuracy)m")
        print("==============================")
    }
}


// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {

    /// Called when the application's location authorization status changes.
    ///
    /// When When-In-Use permission is granted, the service requests
    /// Always permission so that geofence monitoring can continue
    /// when the application is not in the foreground.
    public func locationManagerDidChangeAuthorization(
        _ manager: CLLocationManager
    ) {

        switch manager.authorizationStatus {

        case .notDetermined:
            print("Location: NOT DETERMINED")

        case .authorizedWhenInUse:
            print("Location: WHEN IN USE")

            // Request Always permission for geofence monitoring.
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


    /// Called when Core Location provides a new location.
    ///
    /// The latest location is:
    /// 1. Published to the UI.
    /// 2. Returned to any pending `getCurrentLocation()` request.
    /// 3. Reported to the business layer when a tracking group is active.
    public func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {

        guard let location = locations.last else {
            return
        }

        logLocation(location)

        // Publish location for SwiftUI observers.
        updatePublishedLocation(location)

        // Complete any pending async location request.
        completeLocationRequest(with: location)

        // Report the location for the active tracking group.
        guard let group = currentGroup else {
            return
        }

        reportLocation(
            location,
            for: group
        )
    }


    /// Called when the user exits a monitored geofence.
    ///
    /// A fresh location is requested so that the application can
    /// report the user's latest coordinates.
    public func locationManager(
        _ manager: CLLocationManager,
        didExitRegion region: CLRegion
    ) {

        guard region is CLCircularRegion else {
            return
        }

        print("USER EXITED GEOFENCE")

        // Request the latest GPS location.
        manager.requestLocation()
    }


    /// Called when the user enters a monitored geofence.
    ///
    /// Entry notifications are currently disabled for the monitored
    /// region, but this delegate method is kept available for future
    /// entry-related functionality.
    public func locationManager(
        _ manager: CLLocationManager,
        didEnterRegion region: CLRegion
    ) {

        print("USER ENTERED GEOFENCE")
    }


    /// Called when Core Location encounters an error.
    ///
    /// If a `getCurrentLocation()` request is waiting for a result,
    /// the pending continuation is completed with the received error.
    public func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {

        print(
            "Location error: \(error.localizedDescription)"
        )

        failLocationRequest(with: error)
    }
}

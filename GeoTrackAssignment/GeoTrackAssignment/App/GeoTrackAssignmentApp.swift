//
//  GeoTrackAssignmentApp.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//


import SwiftUI
import UserNotifications

/// The main entry point of the GeoTrackAssignment application.
///
/// This SwiftUI `App` is responsible for:
/// - Initializing application-level services.
/// - Registering the notification delegate.
/// - Requesting notification permissions.
/// - Requesting location permissions.
/// - Creating the root view and injecting its dependencies.
///
/// Dependency injection is performed using the shared `Dependencies`
/// container so that the UI layer does not need to create repositories
/// or use cases directly.
@main
struct GeoTrackAssignmentApp: App {

    // MARK: - App Initialization

    /// Initializes the application.
    ///
    /// During application startup, this method:
    /// 1. Registers the notification delegate.
    /// 2. Requests permission to display local notifications.
    /// 3. Requests the required location permissions for geofencing
    ///    and location tracking.
    init() {

        // Register the application's notification delegate.
        //
        // The delegate is responsible for handling notification
        // presentation and user interactions.
        UNUserNotificationCenter.current().delegate =
            NotificationDelegate.shared

        // Request permission to display notifications.
        requestNotificationPermission()

        // Request the location permissions required by the application.
        //
        // Location permission is required for tracking users and
        // determining whether a user has moved outside the configured
        // geofenced region.
        Dependencies.locationService
            .requestPermissions()
    }


    // MARK: - App Scene

    /// Defines the application's main scene.
    ///
    /// `GroupListView` is the initial/root screen of the application.
    ///
    /// The required use cases, repositories, authentication service,
    /// and location service are injected into the `GroupViewModel`
    /// through the central `Dependencies` container.
    var body: some Scene {

        WindowGroup {

            GroupListView(
                viewModel: GroupViewModel(
                    createGroup:
                        Dependencies.createGroupUseCase,

                    joinGroup:
                        Dependencies.joinGroupUseCase,

                    reportLocation:
                        Dependencies.reportLocationUseCase,

                    groupRepo:
                        Dependencies.groupRepo,

                    authRepo:
                        Dependencies.authRepo,

                    locationService:
                        Dependencies.locationService
                )
            )
        }
    }


    // MARK: - Notification Permission

    /// Requests permission from the user to display notifications.
    ///
    /// The application requests permission for:
    /// - Alerts
    /// - Sounds
    /// - Badges
    ///
    /// After the permission request completes, the current notification
    /// authorization settings are also retrieved for debugging and
    /// verification purposes.
    ///
    /// - Note: The user can deny notification permission. The application
    ///   should continue to function even when notification permission
    ///   is not granted.
    private func requestNotificationPermission() {

        let center =
            UNUserNotificationCenter.current()

        // Request authorization for the notification types required
        // by the application.
        center.requestAuthorization(
            options: [
                .alert,
                .sound,
                .badge
            ]
        ) { granted, error in

            // Handle any error returned while requesting permission.
            if let error = error {

                print(
                    "Notification permission error: \(error.localizedDescription)"
                )

                return
            }

            // Log whether the user granted notification permission.
            print(
                "Notification permission: \(granted)"
            )

            // Verify the current notification settings after the
            // authorization request has completed.
            center.getNotificationSettings { settings in

                print(
                    "Notification authorization status: \(settings.authorizationStatus.rawValue)"
                )

                print(
                    "Alert setting: \(settings.alertSetting.rawValue)"
                )

                print(
                    "Sound setting: \(settings.soundSetting.rawValue)"
                )

                print(
                    "Badge setting: \(settings.badgeSetting.rawValue)"
                )
            }
        }
    }
}

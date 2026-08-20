//
//  GeoTrackAssignmentApp.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//


import SwiftUI
import UserNotifications

@main
struct GeoTrackAssignmentApp: App {

    // MARK: - App Initialization

    init() {

        // Register notification delegate
        UNUserNotificationCenter.current().delegate =
            NotificationDelegate.shared

        // Ask notification permission
        requestNotificationPermission()

        // Ask location permission
        Dependencies.locationService
            .requestPermissions()
    }

    // MARK: - App Scene

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

    private func requestNotificationPermission() {

        let center =
            UNUserNotificationCenter.current()

        center.requestAuthorization(
            options: [
                .alert,
                .sound,
                .badge
            ]
        ) { granted, error in

            if let error = error {

                print(
                    "Notification permission error: \(error.localizedDescription)"
                )

                return
            }

            print(
                "Notification permission: \(granted)"
            )

            // Optional: verify current settings
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

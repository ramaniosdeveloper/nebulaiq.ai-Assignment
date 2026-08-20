//
//  CreateGroupView.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//


import SwiftUI
import CoreLocation

/// A SwiftUI view used to create a new tracking group.
///
/// The user can:
/// - Enter a group name.
/// - Specify a geo-fence radius in meters.
/// - Use the device's current location as the geo-fence center.
/// - Create the tracking group using `GroupViewModel`.
///
/// The current location is retrieved through `Dependencies.locationService`.
struct CreateGroupView: View {

    // MARK: - Dependencies

    /// View model responsible for creating and managing groups.
    @ObservedObject var vm: GroupViewModel

    /// Dismisses the current presentation/navigation destination.
    @Environment(\.dismiss) private var dismiss

    // MARK: - Form State

    /// Name entered by the user for the tracking group.
    @State private var name = ""

    /// Geo-fence radius entered by the user in meters.
    @State private var radius = "100"

    // MARK: - Location State

    /// The current device location used as the geo-fence center.
    @State private var currentLocation: CLLocation?

    /// Indicates whether a location request is currently in progress.
    @State private var isLoadingLocation = false

    /// Error message displayed when the current location cannot be retrieved.
    @State private var locationError: String?

    // MARK: - Body

    var body: some View {
        Form {
            groupInformationSection
            locationSection
            createSection
            errorSection
        }
        .navigationTitle("Create Group")
        .task {
            await loadCurrentLocation()
        }
    }
}

// MARK: - View Sections

private extension CreateGroupView {

    /// Section containing the group name and geo-fence radius inputs.
    @ViewBuilder
    var groupInformationSection: some View {
        Section("Group Information") {
            TextField(
                "Group Name",
                text: $name
            )

            TextField(
                "Radius (meters)",
                text: $radius
            )
            .keyboardType(.numberPad)
        }
    }

    /// Section displaying the current location and allowing the user
    /// to refresh the location.
    @ViewBuilder
    var locationSection: some View {
        Section("Location") {
            if let location = currentLocation {
                locationDetails(for: location)
            } else {
                Text("Current location not available")
                    .foregroundStyle(.secondary)
            }

            Button {
                Task {
                    await loadCurrentLocation()
                }
            } label: {
                if isLoadingLocation {
                    ProgressView()
                } else {
                    Label(
                        "Use Current Location",
                        systemImage: "location.fill"
                    )
                }
            }
            .disabled(isLoadingLocation)
        }
    }

    /// Section containing the create group action.
    @ViewBuilder
    var createSection: some View {
        Section {
            Button("Create Group") {
                Task {
                    await createGroup()
                }
            }
            .disabled(!canCreateGroup)
        }
    }

    /// Displays a location error when one occurs.
    @ViewBuilder
    var errorSection: some View {
        if let locationError {
            Section {
                Text(locationError)
                    .foregroundStyle(.red)
            }
        }
    }

    /// Displays latitude, longitude and horizontal accuracy
    /// for the supplied location.
    ///
    /// - Parameter location: The current device location.
    @ViewBuilder
    func locationDetails(for location: CLLocation) -> some View {
        Text(
            "Latitude: \(location.coordinate.latitude)"
        )

        Text(
            "Longitude: \(location.coordinate.longitude)"
        )

        Text(
            "Accuracy: \(Int(location.horizontalAccuracy)) meters"
        )
    }
}

// MARK: - Validation

private extension CreateGroupView {

    /// Indicates whether the group can currently be created.
    ///
    /// A valid group requires:
    /// - A non-empty group name.
    /// - A valid positive radius.
    /// - A valid current location.
    var canCreateGroup: Bool {
        guard currentLocation != nil else {
            return false
        }

        guard !trimmedGroupName.isEmpty else {
            return false
        }

        guard let radiusValue = Double(radius) else {
            return false
        }

        return radiusValue > 0
    }

    /// Returns the group name after removing leading and trailing whitespace.
    var trimmedGroupName: String {
        name.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
    }

    /// Returns the entered radius as a positive `Double`.
    var radiusValue: Double? {
        guard let value = Double(radius),
              value > 0 else {
            return nil
        }

        return value
    }
}

// MARK: - Actions

private extension CreateGroupView {

    /// Retrieves the device's current location.
    ///
    /// The location service is resolved through the application's
    /// dependency container.
    ///
    /// Any error returned by the location service is displayed
    /// to the user.
    @MainActor
    func loadCurrentLocation() async {
        guard !isLoadingLocation else {
            return
        }

        isLoadingLocation = true
        locationError = nil

        defer {
            isLoadingLocation = false
        }

        do {
            let location = try await Dependencies.locationService
                .getCurrentLocation()

            currentLocation = location
        } catch {
            locationError = error.localizedDescription
        }
    }

    /// Creates a new tracking group using the entered form values.
    ///
    /// The current device location is used as the center of the
    /// geo-fence.
    ///
    /// If the form contains invalid data, the method exits without
    /// creating the group.
    @MainActor
    func createGroup() async {
        guard let location = currentLocation else {
            return
        }

        guard let radiusValue else {
            return
        }

        guard !trimmedGroupName.isEmpty else {
            return
        }

        await vm.create(
            name: trimmedGroupName,
            center: (
                location.coordinate.latitude,
                location.coordinate.longitude
            ),
            radius: radiusValue
        )

        dismiss()
    }
}

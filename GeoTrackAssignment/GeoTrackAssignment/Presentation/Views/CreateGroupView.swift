//
//  CreateGroupView.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//


import SwiftUI
import CoreLocation

struct CreateGroupView: View {

    @ObservedObject var vm: GroupViewModel

    @Environment(\.dismiss)
    private var dismiss

    @State private var name = ""

    @State private var radius = "100"

    @State private var currentLocation:
        CLLocation?

    @State private var isLoadingLocation = false

    @State private var locationError:
        String?

    var body: some View {

        Form {

            // MARK: Group Information

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


            // MARK: Current Location

            Section("Location") {

                if let location = currentLocation {

                    Text(
                        "Latitude: \(location.coordinate.latitude)"
                    )

                    Text(
                        "Longitude: \(location.coordinate.longitude)"
                    )

                    Text(
                        "Accuracy: \(Int(location.horizontalAccuracy)) meters"
                    )

                } else {

                    Text(
                        "Current location not available"
                    )
                    .foregroundStyle(.secondary)
                }


                Button {

                    getCurrentLocation()

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


            // MARK: Create

            Section {

                Button("Create Group") {

                    createGroup()
                }
                .disabled(
                    currentLocation == nil ||
                    name.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    ).isEmpty
                )
            }


            // MARK: Error

            if let locationError {

                Section {

                    Text(locationError)
                        .foregroundStyle(.red)
                }
            }
        }

        .navigationTitle("Create Group")

        .task {

            getCurrentLocation()
        }
    }


    // MARK: - Get Current Location

    private func getCurrentLocation() {

        isLoadingLocation = true
        locationError = nil

        Task {

            do {

                let location =
                    try await Dependencies.locationService
                        .getCurrentLocation()

                await MainActor.run {

                    currentLocation = location

                    isLoadingLocation = false
                }

            } catch {

                await MainActor.run {

                    isLoadingLocation = false

                    locationError =
                        error.localizedDescription
                }
            }
        }
    }


    // MARK: - Create Group

    private func createGroup() {

        guard let location = currentLocation else {
            return
        }

        guard let radiusValue = Double(radius) else {
            return
        }

        let groupName =
            name.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        guard !groupName.isEmpty else {
            return
        }

        Task {

            await vm.create(
                name: groupName,

                center: (
                    location.coordinate.latitude,
                    location.coordinate.longitude
                ),

                radius: radiusValue
            )

            await MainActor.run {

                dismiss()
            }
        }
    }
}

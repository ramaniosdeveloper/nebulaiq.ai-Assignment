//
//  CreateGroupUseCase.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//

import Foundation

// MARK: - Create Group Use Case

/// Use case responsible for creating a new tracking group.
///
/// The use case:
/// - Retrieves the currently authenticated user.
/// - Uses the current user as the owner of the new group.
/// - Creates the group through the group repository.
///
/// This keeps group-creation business logic independent from
/// the UI and concrete repository implementations.
public struct CreateGroupUseCase {

    // MARK: - Dependencies

    /// Repository responsible for group-related operations.
    private let groupRepository: GroupRepository

    /// Repository responsible for retrieving the authenticated user.
    private let authRepository: AuthRepository

    // MARK: - Initialization

    /// Creates a create-group use case.
    ///
    /// - Parameters:
    ///   - groupRepo: Repository used to create and manage groups.
    ///   - authRepo: Repository used to retrieve the current user.
    public init(
        groupRepo: GroupRepository,
        authRepo: AuthRepository
    ) {
        self.groupRepository = groupRepo
        self.authRepository = authRepo
    }

    // MARK: - Execute

    /// Creates a new tracking group owned by the current user.
    ///
    /// - Parameters:
    ///   - name: Name of the tracking group.
    ///   - geoFence: Geo-fence configuration associated with the group.
    ///
    /// - Returns: The newly created tracking group.
    ///
    /// - Throws: An error if the current user cannot be retrieved
    ///   or if group creation fails.
    public func execute(
        name: String,
        geoFence: GeoFence
    ) async throws -> Group {

        let currentUser = try await authRepository.currentUser()

        return try await groupRepository.createGroup(
            name: name,
            geoFence: geoFence,
            owner: currentUser.id
        )
    }
}

//
//  JoinGroupUseCase.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//

import Foundation

// MARK: - Join Group Use Case

/// Use case responsible for allowing the current user to join
/// an existing tracking group.
///
/// The use case:
/// - Retrieves the currently authenticated user.
/// - Adds that user as a member of the specified group.
/// - Returns the updated group.
///
/// This keeps the group-joining business logic independent from
/// the UI and concrete repository implementations.
public struct JoinGroupUseCase {

    // MARK: - Dependencies

    /// Repository responsible for group-related operations.
    private let groupRepository: GroupRepository

    /// Repository responsible for retrieving the authenticated user.
    private let authRepository: AuthRepository

    // MARK: - Initialization

    /// Creates a join-group use case.
    ///
    /// - Parameters:
    ///   - groupRepo: Repository used to manage group membership.
    ///   - authRepo: Repository used to retrieve the current user.
    public init(
        groupRepo: GroupRepository,
        authRepo: AuthRepository
    ) {
        self.groupRepository = groupRepo
        self.authRepository = authRepo
    }

    // MARK: - Execute

    /// Adds the current user to the specified tracking group.
    ///
    /// - Parameter groupID: Identifier of the group to join.
    ///
    /// - Returns: The updated tracking group after the user
    ///   has been added.
    ///
    /// - Throws: An error if the current user cannot be retrieved
    ///   or if the user cannot be added to the group.
    public func execute(
        groupID: GroupID
    ) async throws -> Group {

        let currentUser = try await authRepository.currentUser()

        return try await groupRepository.addMember(
            currentUser.id,
            to: groupID
        )
    }
}

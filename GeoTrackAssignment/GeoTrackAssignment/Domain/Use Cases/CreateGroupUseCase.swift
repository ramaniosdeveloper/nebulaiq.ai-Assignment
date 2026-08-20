//
//  CreateGroupUseCase.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//

// MARK: - Create Group

public struct CreateGroupUseCase {

    private let groupRepo: GroupRepository
    private let authRepo: AuthRepository

    public init(
        groupRepo: GroupRepository,
        authRepo: AuthRepository
    ) {
        self.groupRepo = groupRepo
        self.authRepo = authRepo
    }

    public func execute(
        name: String,
        geoFence: GeoFence
    ) async throws -> Group {

        let user = try await authRepo.currentUser()

        return try await groupRepo.createGroup(
            name: name,
            geoFence: geoFence,
            owner: user.id
        )
    }
}

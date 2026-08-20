//
//  JoinGroupUseCase.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//

// MARK: - Join Group

public struct JoinGroupUseCase {

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
        groupID: GroupID
    ) async throws -> Group {

        let user = try await authRepo.currentUser()

        return try await groupRepo.addMember(
            user.id,
            to: groupID
        )
    }
}

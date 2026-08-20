//
//  MockAuthRepository.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//

import Foundation
@testable import GeoTrackAssignment

final class MockAuthRepository: AuthRepository {

    var user: User?
    var error: Error?

    private(set) var currentUserCallCount = 0

    init(
        user: User? = TestDataFactory.user,
        error: Error? = nil
    ) {
        self.user = user
        self.error = error
    }

    func currentUser() async throws -> User {

        currentUserCallCount += 1

        if let error {
            throw error
        }

        guard let user else {
            throw MockError.userNotConfigured
        }

        return user
    }
}

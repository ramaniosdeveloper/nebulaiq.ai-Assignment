//
//  JoinGroupUseCaseTests.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//

import XCTest
@testable import GeoTrackAssignment

final class JoinGroupUseCaseTests: XCTestCase {

    func test_execute_addsCurrentUserToGroup() async throws {

        let authRepository = MockAuthRepository()

        let groupRepository = MockGroupRepository()

        groupRepository.groupToReturn =
            TestDataFactory.group

        let useCase = JoinGroupUseCase(
            groupRepo: groupRepository,
            authRepo: authRepository
        )

        let result = try await useCase.execute(
            groupID: TestDataFactory.groupID
        )

        XCTAssertEqual(
            result,
            TestDataFactory.group
        )

        XCTAssertEqual(
            groupRepository.addMemberCallCount,
            1
        )

        XCTAssertEqual(
            groupRepository.lastAddedUser,
            TestDataFactory.userID
        )

        XCTAssertEqual(
            groupRepository.lastAddedGroup,
            TestDataFactory.groupID
        )
    }

    func test_execute_doesNotCallRepository_whenAuthenticationFails()
        async {

        let authRepository = MockAuthRepository(
            error: MockError.forcedFailure
        )

        let groupRepository = MockGroupRepository()

        let useCase = JoinGroupUseCase(
            groupRepo: groupRepository,
            authRepo: authRepository
        )

        do {
            _ = try await useCase.execute(
                groupID: TestDataFactory.groupID
            )

            XCTFail("Expected authentication error")

        } catch {

            XCTAssertEqual(
                groupRepository.addMemberCallCount,
                0
            )
        }
    }

}

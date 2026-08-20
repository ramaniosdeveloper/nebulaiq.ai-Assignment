//
//  CreateGroupUseCaseTests.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//

import XCTest
@testable import GeoTrackAssignment

final class CreateGroupUseCaseTests: XCTestCase {

    func test_execute_createsGroupUsingCurrentUserAsOwner() async throws {

        let authRepository = MockAuthRepository()

        let groupRepository = MockGroupRepository()

        let useCase = CreateGroupUseCase(
            groupRepo: groupRepository,
            authRepo: authRepository
        )

        let geoFence = GeoFence(
            centerLat: 30.7046,
            centerLon: 76.7179,
            radiusMeters: 250
        )

        let result = try await useCase.execute(
            name: "Family",
            geoFence: geoFence
        )

        XCTAssertEqual(result.name, "Family")

        XCTAssertEqual(
            groupRepository.createGroupCallCount,
            1
        )

        XCTAssertEqual(
            groupRepository.lastCreatedOwner,
            TestDataFactory.userID
        )

        XCTAssertEqual(
            groupRepository.lastCreatedName,
            "Family"
        )

        XCTAssertEqual(
            groupRepository.lastCreatedGeoFence,
            geoFence
        )
    }

    func test_execute_throws_whenAuthenticationFails() async {

        let authRepository = MockAuthRepository(
            error: MockError.forcedFailure
        )

        let groupRepository = MockGroupRepository()

        let useCase = CreateGroupUseCase(
            groupRepo: groupRepository,
            authRepo: authRepository
        )

        do {
            _ = try await useCase.execute(
                name: "Family",
                geoFence: TestDataFactory.geoFence
            )

            XCTFail("Expected authentication error")

        } catch {

            XCTAssertEqual(
                error.localizedDescription,
                MockError.forcedFailure.localizedDescription
            )

            XCTAssertEqual(
                groupRepository.createGroupCallCount,
                0
            )
        }
    }

}

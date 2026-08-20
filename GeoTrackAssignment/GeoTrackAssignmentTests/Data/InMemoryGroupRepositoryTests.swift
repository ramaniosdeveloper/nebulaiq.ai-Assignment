//
//  InMemoryGroupRepositoryTests.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//

import XCTest
@testable import GeoTrackAssignment

final class InMemoryGroupRepositoryTests: XCTestCase {

    func test_createGroup_createsGroupWithOwner()
        async throws {

        let repository =
            InMemoryGroupRepository()

        let group = try await repository.createGroup(
            name: "Family",
            geoFence: TestDataFactory.geoFence,
            owner: TestDataFactory.userID
        )

        XCTAssertEqual(
            group.name,
            "Family"
        )

        XCTAssertEqual(
            group.members,
            [TestDataFactory.userID]
        )

        XCTAssertEqual(
            group.geoFence,
            TestDataFactory.geoFence
        )
    }

    func test_createGroup_generatesUniqueIDs()
        async throws {

        let repository =
            InMemoryGroupRepository()

        let first = try await repository.createGroup(
            name: "First",
            geoFence: TestDataFactory.geoFence,
            owner: TestDataFactory.userID
        )

        let second = try await repository.createGroup(
            name: "Second",
            geoFence: TestDataFactory.geoFence,
            owner: TestDataFactory.userID
        )

        XCTAssertNotEqual(
            first.id,
            second.id
        )
    }

    func test_getGroup_returnsCreatedGroup()
        async throws {

        let repository =
            InMemoryGroupRepository()

        let created = try await repository.createGroup(
            name: "Family",
            geoFence: TestDataFactory.geoFence,
            owner: TestDataFactory.userID
        )

        let result = try await repository.getGroup(
            by: created.id
        )

        XCTAssertEqual(
            result,
            created
        )
    }

    func test_getGroup_throwsForUnknownGroup()
        async {

        let repository =
            InMemoryGroupRepository()

        let unknownID =
            GroupID(rawValue: "unknown")

        do {

            _ = try await repository.getGroup(
                by: unknownID
            )

            XCTFail("Expected groupNotFound")

        } catch let error as InMemoryRepositoryError {

            switch error {

            case .groupNotFound(let groupID):

                XCTAssertEqual(
                    groupID,
                    unknownID
                )
            }

        } catch {

            XCTFail(
                "Unexpected error: \(error)"
            )
        }
    }

    func test_addMember_addsUserToGroup()
        async throws {

        let repository =
            InMemoryGroupRepository()

        let group = try await repository.createGroup(
            name: "Family",
            geoFence: TestDataFactory.geoFence,
            owner: TestDataFactory.userID
        )

        let result = try await repository.addMember(
            TestDataFactory.anotherUserID,
            to: group.id
        )

        XCTAssertTrue(
            result.members.contains(
                TestDataFactory.anotherUserID
            )
        )
    }
}

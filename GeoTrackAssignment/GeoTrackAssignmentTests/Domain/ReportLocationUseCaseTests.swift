//
//  ReportLocationUseCaseTests.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//

import XCTest
@testable import GeoTrackAssignment

final class ReportLocationUseCaseTests: XCTestCase {

    func test_execute_reportsLocation_whenUserIsInsideGeofence()
        async throws {

        let authRepository = MockAuthRepository()

        let locationRepository =
            MockLocationRepository()

        let groupRepository =
            MockGroupRepository()

        groupRepository.groupToReturn =
            TestDataFactory.group

        let notificationRepository =
            MockNotificationRepository()

        let useCase = ReportLocationUseCase(
            locationRepo: locationRepository,
            groupRepo: groupRepository,
            notificationRepo: notificationRepository,
            authRepo: authRepository
        )

        try await useCase.execute(
            groupID: TestDataFactory.groupID,
            latitude: TestDataFactory.geoFence.centerLat,
            longitude: TestDataFactory.geoFence.centerLon
        )

        XCTAssertEqual(
            locationRepository.postLocationCallCount,
            1
        )

        XCTAssertEqual(
            locationRepository.lastGroupID,
            TestDataFactory.groupID
        )

        XCTAssertEqual(
            locationRepository.lastSnapshot?.userID,
            TestDataFactory.userID
        )

        XCTAssertEqual(
            notificationRepository.notifyMembersCallCount,
            0
        )
    }

    func test_execute_notifiesMembers_whenUserLeavesGeofence()
        async throws {

        let authRepository = MockAuthRepository()

        let locationRepository =
            MockLocationRepository()

        let groupRepository =
            MockGroupRepository()

        groupRepository.groupToReturn =
            TestDataFactory.group

        let notificationRepository =
            MockNotificationRepository()

        let useCase = ReportLocationUseCase(
            locationRepo: locationRepository,
            groupRepo: groupRepository,
            notificationRepo: notificationRepository,
            authRepo: authRepository
        )

        try await useCase.execute(
            groupID: TestDataFactory.groupID,
            latitude: 30.7100,
            longitude: 76.7200
        )

        XCTAssertEqual(
            locationRepository.postLocationCallCount,
            1
        )

        XCTAssertEqual(
            notificationRepository.notifyMembersCallCount,
            1
        )

        XCTAssertEqual(
            notificationRepository.lastGroupID,
            TestDataFactory.groupID
        )

        XCTAssertEqual(
            notificationRepository.lastExcludedUserID,
            TestDataFactory.userID
        )

        XCTAssertEqual(
            notificationRepository.lastTitle,
            "Member left geofence"
        )

        XCTAssertEqual(
            notificationRepository.lastBody,
            "Raman moved out of the region."
        )
    }

    func test_execute_doesNotNotify_whenUserIsInsideGeofence()
        async throws {

        let locationRepository =
            MockLocationRepository()

        let groupRepository =
            MockGroupRepository()

        groupRepository.groupToReturn =
            TestDataFactory.group

        let notificationRepository =
            MockNotificationRepository()

        let useCase = ReportLocationUseCase(
            locationRepo: locationRepository,
            groupRepo: groupRepository,
            notificationRepo: notificationRepository,
            authRepo: MockAuthRepository()
        )

        try await useCase.execute(
            groupID: TestDataFactory.groupID,
            latitude: 30.7046,
            longitude: 76.7179
        )

        XCTAssertEqual(
            notificationRepository.notifyMembersCallCount,
            0
        )
    }

    func test_execute_propagatesLocationRepositoryError()
        async {

        let locationRepository =
            MockLocationRepository()

        locationRepository.error =
            MockError.forcedFailure

        let groupRepository =
            MockGroupRepository()

        groupRepository.groupToReturn =
            TestDataFactory.group

        let notificationRepository =
            MockNotificationRepository()

        let useCase = ReportLocationUseCase(
            locationRepo: locationRepository,
            groupRepo: groupRepository,
            notificationRepo: notificationRepository,
            authRepo: MockAuthRepository()
        )

        do {

            try await useCase.execute(
                groupID: TestDataFactory.groupID,
                latitude: 30.7046,
                longitude: 76.7179
            )

            XCTFail("Expected location repository error")

        } catch {

            XCTAssertEqual(
                locationRepository.postLocationCallCount,
                1
            )

            XCTAssertEqual(
                groupRepository.getGroupCallCount,
                0
            )

            XCTAssertEqual(
                notificationRepository.notifyMembersCallCount,
                0
            )
        }
    }
}

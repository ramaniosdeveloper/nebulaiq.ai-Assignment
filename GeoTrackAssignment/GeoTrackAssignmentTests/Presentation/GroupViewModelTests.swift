//
//  GroupViewModelTests.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//

import XCTest
@testable import GeoTrackAssignment

@MainActor
final class GroupViewModelTests: XCTestCase {

    private var authRepository: MockAuthRepository!
    private var groupRepository: MockGroupRepository!
    private var locationRepository: MockLocationRepository!
    private var notificationRepository: MockNotificationRepository!
    private var locationService: MockLocationMonitoringService!

    private var createGroupUseCase: CreateGroupUseCase!
    private var joinGroupUseCase: JoinGroupUseCase!
    private var reportLocationUseCase: ReportLocationUseCase!

    private var sut: GroupViewModel!

    override func setUp() {
        super.setUp()

        authRepository =
            MockAuthRepository()

        groupRepository =
            MockGroupRepository()

        locationRepository =
            MockLocationRepository()

        notificationRepository =
            MockNotificationRepository()

        locationService =
            MockLocationMonitoringService()

        createGroupUseCase =
            CreateGroupUseCase(
                groupRepo: groupRepository,
                authRepo: authRepository
            )

        joinGroupUseCase =
            JoinGroupUseCase(
                groupRepo: groupRepository,
                authRepo: authRepository
            )

        reportLocationUseCase =
            ReportLocationUseCase(
                locationRepo: locationRepository,
                groupRepo: groupRepository,
                notificationRepo: notificationRepository,
                authRepo: authRepository
            )

        sut = GroupViewModel(
            createGroup: createGroupUseCase,
            joinGroup: joinGroupUseCase,
            reportLocation: reportLocationUseCase,
            groupRepo: groupRepository,
            authRepo: authRepository,
            locationService: locationService
        )
    }

    override func tearDown() {

        sut = nil
        reportLocationUseCase = nil
        joinGroupUseCase = nil
        createGroupUseCase = nil

        locationService = nil
        notificationRepository = nil
        locationRepository = nil
        groupRepository = nil
        authRepository = nil

        super.tearDown()
    }

    func test_loadGroups_loadsGroupsAndSelectsFirstGroup()
        async {

        groupRepository.groupsToReturn = [
            TestDataFactory.group
        ]

        await sut.loadGroups()

        XCTAssertEqual(
            sut.groups.count,
            1
        )

        XCTAssertEqual(
            sut.groups.first,
            TestDataFactory.group
        )

        XCTAssertEqual(
            sut.selectedGroup,
            TestDataFactory.group
        )

        XCTAssertEqual(
            locationService.startMonitoringCallCount,
            1
        )

        XCTAssertEqual(
            locationService.lastMonitoredGroup,
            TestDataFactory.group
        )
    }

    func test_loadGroups_setsError_whenRepositoryFails()
        async {

        groupRepository.listGroupsError =
            MockError.forcedFailure

        await sut.loadGroups()

        XCTAssertTrue(
            sut.groups.isEmpty
        )

        XCTAssertNotNil(
            sut.statusMessage
        )

        XCTAssertTrue(
            sut.statusMessage?.contains(
                "Failed to load groups"
            ) == true
        )
    }

    func test_create_addsNewGroupAndSelectsIt()
        async {

        let createdGroup =
            TestDataFactory.group

        groupRepository.createdGroup =
            createdGroup

        await sut.create(
            name: "Family",
            center: (
                latitude: 30.7046,
                longitude: 76.7179
            ),
            radius: 500
        )

        XCTAssertEqual(
            sut.groups.count,
            1
        )

        XCTAssertEqual(
            sut.groups.first,
            createdGroup
        )

        XCTAssertEqual(
            sut.selectedGroup,
            createdGroup
        )

        XCTAssertEqual(
            groupRepository.createGroupCallCount,
            1
        )

        XCTAssertEqual(
            groupRepository.lastCreatedName,
            "Family"
        )

        XCTAssertEqual(
            groupRepository.lastCreatedOwner,
            TestDataFactory.userID
        )

        XCTAssertEqual(
            locationService.startMonitoringCallCount,
            1
        )
    }

    func test_create_setsError_whenCreationFails()
        async {

        groupRepository.createError =
            MockError.forcedFailure

        await sut.create(
            name: "Family",
            center: (
                latitude: 30.7046,
                longitude: 76.7179
            ),
            radius: 500
        )

        XCTAssertTrue(
            sut.groups.isEmpty
        )

        XCTAssertNotNil(
            sut.statusMessage
        )

        XCTAssertTrue(
            sut.statusMessage?.contains(
                "Create failed"
            ) == true
        )
    }

    func test_join_addsGroupWhenNotAlreadyPresent()
        async {

        groupRepository.groupToReturn =
            TestDataFactory.group

        await sut.join(
            groupID: TestDataFactory.groupID
        )

        XCTAssertEqual(
            sut.groups.count,
            1
        )

        XCTAssertEqual(
            sut.selectedGroup,
            TestDataFactory.group
        )

        XCTAssertEqual(
            groupRepository.addMemberCallCount,
            1
        )

        XCTAssertEqual(
            locationService.startMonitoringCallCount,
            1
        )
    }

    func test_join_doesNotDuplicateExistingGroup()
        async {

        groupRepository.groupToReturn =
            TestDataFactory.group

        await sut.loadGroups()

        XCTAssertEqual(
            sut.groups.count,
            0
        )

        // Manually add the existing group by selecting it.
        sut.select(
            group: TestDataFactory.group
        )

        // groups is still empty because select() only selects.
        XCTAssertEqual(
            sut.groups.count,
            0
        )

        await sut.join(
            groupID: TestDataFactory.groupID
        )

        XCTAssertEqual(
            sut.groups.count,
            1
        )

        await sut.join(
            groupID: TestDataFactory.groupID
        )

        XCTAssertEqual(
            sut.groups.count,
            1
        )
    }

    func test_join_setsError_whenRepositoryFails()
        async {

        groupRepository.addMemberError =
            MockError.forcedFailure

        await sut.join(
            groupID: TestDataFactory.groupID
        )

        XCTAssertTrue(
            sut.groups.isEmpty
        )

        XCTAssertNotNil(
            sut.statusMessage
        )

        XCTAssertTrue(
            sut.statusMessage?.contains(
                "Join failed"
            ) == true
        )
    }

    func test_select_setsSelectedGroupAndStartsMonitoring() {

        sut.select(
            group: TestDataFactory.group
        )

        XCTAssertEqual(
            sut.selectedGroup,
            TestDataFactory.group
        )

        XCTAssertEqual(
            locationService.startMonitoringCallCount,
            1
        )

        XCTAssertEqual(
            locationService.lastMonitoredGroup,
            TestDataFactory.group
        )
    }
}

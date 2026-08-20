//
//  MockNotificationRepository.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//

import Foundation
@testable import GeoTrackAssignment

final class MockNotificationRepository: NotificationRepository {

    private(set) var notifyMembersCallCount = 0

    private(set) var lastGroupID: GroupID?
    private(set) var lastExcludedUserID: UserID?
    private(set) var lastTitle: String?
    private(set) var lastBody: String?

    var error: Error?

    func notifyMembers(
        groupID: GroupID,
        excluding: UserID,
        title: String,
        body: String
    ) async throws {

        notifyMembersCallCount += 1

        lastGroupID = groupID
        lastExcludedUserID = excluding
        lastTitle = title
        lastBody = body

        if let error {
            throw error
        }
    }
}


enum MockError: LocalizedError {

    case userNotConfigured
    case groupNotConfigured
    case forcedFailure

    var errorDescription: String? {
        switch self {
        case .userNotConfigured:
            return "User not configured"

        case .groupNotConfigured:
            return "Group not configured"

        case .forcedFailure:
            return "Forced test failure"
        }
    }
}

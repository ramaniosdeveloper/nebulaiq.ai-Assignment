//
//  User.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//

import Foundation

// MARK: - User

// MARK: - User ID

/// Unique identifier for a user.
///
/// The identifier is kept as a value type so it can safely be used
/// throughout the domain layer without depending on a specific
/// authentication or database implementation.
public struct UserID: Hashable, Codable {

    /// Raw string representation of the user identifier.
    public let rawValue: String
}

/// Represents a user participating in a tracking group.
///
/// This is a domain model and is independent of authentication,
/// networking, or persistence frameworks.
public struct User: Equatable, Codable {

    /// Unique identifier of the user.
    public let id: UserID

    /// Name displayed to other group members.
    public let displayName: String

    /// Optional push notification token associated with the user.
    ///
    /// This can be used by a notification layer to deliver
    /// notifications to the user's device.
    public let deviceToken: String?

    /// Creates a user domain model.
    ///
    /// - Parameters:
    ///   - id: Unique user identifier.
    ///   - displayName: Name displayed in the application.
    ///   - deviceToken: Optional push notification token.
    public init(
        id: UserID,
        displayName: String,
        deviceToken: String?
    ) {
        self.id = id
        self.displayName = displayName
        self.deviceToken = deviceToken
    }
}

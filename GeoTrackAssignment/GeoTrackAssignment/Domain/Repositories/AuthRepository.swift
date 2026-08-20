//
//  AuthRepository.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//

// MARK: - Authentication Repository

/// Defines the authentication data-access contract.
///
/// The domain layer uses this protocol to obtain information about
/// the currently authenticated user without depending on a specific
/// authentication provider.
public protocol AuthRepository {

    /// Returns the currently authenticated user.
    ///
    /// - Returns: The current authenticated user.
    /// - Throws: An error if the current user cannot be retrieved
    ///   or if authentication is unavailable.
    func currentUser() async throws -> User
}

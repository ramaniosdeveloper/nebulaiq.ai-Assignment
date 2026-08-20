//
//  HTTPClient.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//

//
//  HTTPClient.swift
//  GeoTrackAssignment
//
//  Created by Raman Kumar on 20/08/26.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// A lightweight HTTP client responsible for executing REST API requests.
///
/// `HTTPClient` provides generic support for:
/// - GET requests
/// - POST requests
/// - PUT requests
/// - JSON request bodies
/// - JSON response decoding
/// - HTTP status-code validation
///
/// The client uses Swift Concurrency (`async/await`) for asynchronous
/// network operations.
public final class HTTPClient {

    // MARK: - Properties

    /// Base URL used for all API requests.
    private let baseURL: URL

    /// URL session used to execute network requests.
    private let session: URLSession

    /// JSON decoder used to decode API responses.
    private let decoder: JSONDecoder

    /// JSON encoder/serializer configuration for request bodies.
    ///
    /// `JSONSerialization` is used because the current API accepts
    /// `[String: Any]` payloads.
    public init(
        baseURL: URL,
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = decoder
    }

    // MARK: - GET

    /// Performs a GET request and decodes the response.
    ///
    /// - Parameter path: API endpoint path.
    /// - Returns: Decoded response object.
    /// - Throws: `URLError` for HTTP/network failures or
    ///           `DecodingError` when response decoding fails.
    public func get<T: Decodable>(
        _ path: String
    ) async throws -> T {
        let request = try makeRequest(
            path: path,
            method: "GET"
        )

        return try await execute(request)
    }

    // MARK: - POST

    /// Performs a POST request and decodes the response.
    ///
    /// - Parameters:
    ///   - path: API endpoint path.
    ///   - json: JSON-compatible request body.
    /// - Returns: Decoded response object.
    /// - Throws: Network, HTTP, serialization, or decoding errors.
    public func post<T: Decodable>(
        _ path: String,
        json: [String: Any]
    ) async throws -> T {
        let request = try makeRequest(
            path: path,
            method: "POST",
            json: json
        )

        return try await execute(request)
    }

    /// Performs a POST request when the server does not return a response body.
    ///
    /// - Parameters:
    ///   - path: API endpoint path.
    ///   - json: JSON-compatible request body.
    /// - Throws: Network, HTTP, or serialization errors.
    public func post(
        _ path: String,
        json: [String: Any]
    ) async throws {
        let request = try makeRequest(
            path: path,
            method: "POST",
            json: json
        )

        _ = try await perform(request)
    }

    // MARK: - PUT

    /// Performs a PUT request and decodes the response.
    ///
    /// - Parameters:
    ///   - path: API endpoint path.
    ///   - json: JSON-compatible request body.
    /// - Returns: Decoded response object.
    /// - Throws: Network, HTTP, serialization, or decoding errors.
    public func put<T: Decodable>(
        _ path: String,
        json: [String: Any]
    ) async throws -> T {
        let request = try makeRequest(
            path: path,
            method: "PUT",
            json: json
        )

        return try await execute(request)
    }

    // MARK: - Request Creation

    /// Creates a URL request for the supplied endpoint.
    ///
    /// - Parameters:
    ///   - path: API endpoint path.
    ///   - method: HTTP method.
    ///   - json: Optional JSON-compatible request body.
    /// - Returns: Configured `URLRequest`.
    /// - Throws: An error if the JSON body cannot be serialized.
    private func makeRequest(
        path: String,
        method: String,
        json: [String: Any]? = nil
    ) throws -> URLRequest {

        let url = baseURL.appendingPathComponent(path)

        var request = URLRequest(url: url)
        request.httpMethod = method

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Accept"
        )

        if let json {
            request.setValue(
                "application/json",
                forHTTPHeaderField: "Content-Type"
            )

            request.httpBody = try JSONSerialization.data(
                withJSONObject: json,
                options: []
            )
        }

        return request
    }

    // MARK: - Request Execution

    /// Executes a request and returns the response data.
    ///
    /// - Parameter request: Configured URL request.
    /// - Returns: Response data.
    /// - Throws: Network or HTTP errors.
    private func perform(
        _ request: URLRequest
    ) async throws -> Data {

        let (data, response) = try await session.data(
            for: request
        )

        try validate(response: response)

        return data
    }

    /// Executes a request and decodes the response.
    ///
    /// - Parameter request: Configured URL request.
    /// - Returns: Decoded response object.
    /// - Throws: Network, HTTP, or decoding errors.
    private func execute<T: Decodable>(
        _ request: URLRequest
    ) async throws -> T {

        let data = try await perform(request)

        return try decoder.decode(
            T.self,
            from: data
        )
    }

    // MARK: - Response Validation

    /// Validates the HTTP response status code.
    ///
    /// Only status codes in the `2xx` range are considered successful.
    ///
    /// - Parameter response: URL response returned by the server.
    /// - Throws: `URLError.badServerResponse` for invalid responses
    ///           or non-success HTTP status codes.
    private func validate(
        response: URLResponse
    ) throws {

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
}

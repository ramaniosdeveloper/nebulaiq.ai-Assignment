//
//  HTTPClient.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//

import Foundation

public final class HTTPClient {
    private let baseURL: URL
    private let session: URLSession

    public init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    public func get<T: Decodable>(_ path: String) async throws -> T {
        let url = baseURL.appendingPathComponent(path)
        let (data, resp) = try await session.data(from: url)
        try HTTPClient.validate(resp: resp)
        return try JSONDecoder().decode(T.self, from: data)
    }

    public func post<T: Decodable>(_ path: String, json: [String: Any]) async throws -> T {
        let url = baseURL.appendingPathComponent(path)
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONSerialization.data(withJSONObject: json, options: [])
        let (data, resp) = try await session.data(for: req)
        try HTTPClient.validate(resp: resp)
        return try JSONDecoder().decode(T.self, from: data)
    }

    public func post(_ path: String, json: [String: Any]) async throws -> Void {
        let url = baseURL.appendingPathComponent(path)
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONSerialization.data(withJSONObject: json, options: [])
        let (_, resp) = try await session.data(for: req)
        try HTTPClient.validate(resp: resp)
    }

    public func put<T: Decodable>(_ path: String, json: [String: Any]) async throws -> T {
        let url = baseURL.appendingPathComponent(path)
        var req = URLRequest(url: url)
        req.httpMethod = "PUT"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONSerialization.data(withJSONObject: json, options: [])
        let (data, resp) = try await session.data(for: req)
        try HTTPClient.validate(resp: resp)
        return try JSONDecoder().decode(T.self, from: data)
    }

    private static func validate(resp: URLResponse) throws {
        guard let http = resp as? HTTPURLResponse else { throw URLError(.badServerResponse) }
        guard 200..<300 ~= http.statusCode else { throw URLError(.badServerResponse) }
    }
}

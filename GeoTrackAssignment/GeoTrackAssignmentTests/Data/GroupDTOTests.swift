//
//  GroupDTOTests.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//

import XCTest
@testable import GeoTrackAssignment

final class GroupDTOTests: XCTestCase {

    func test_toDomain_mapsAllProperties() {

        let dto = GroupDTO(
            id: "group-100",
            name: "Friends",
            members: [
                "user-1",
                "user-2"
            ],
            geo: GeoDTO(
                lat: 30.7046,
                lon: 76.7179,
                radius: 500
            )
        )

        let group = dto.toDomain()

        XCTAssertEqual(
            group.id.rawValue,
            "group-100"
        )

        XCTAssertEqual(
            group.name,
            "Friends"
        )

        XCTAssertEqual(
            group.members.map(\.rawValue),
            ["user-1", "user-2"]
        )

        XCTAssertEqual(
            group.geoFence.centerLat,
            30.7046
        )

        XCTAssertEqual(
            group.geoFence.centerLon,
            76.7179
        )

        XCTAssertEqual(
            group.geoFence.radiusMeters,
            500
        )
    }

    func test_dto_decodesFromJSON() throws {

        let json = """
        {
            "id": "group-1",
            "name": "Family",
            "members": ["user-1", "user-2"],
            "geo": {
                "lat": 30.7046,
                "lon": 76.7179,
                "radius": 100
            }
        }
        """

        let data = Data(json.utf8)

        let dto = try JSONDecoder().decode(
            GroupDTO.self,
            from: data
        )

        XCTAssertEqual(
            dto.id,
            "group-1"
        )

        XCTAssertEqual(
            dto.name,
            "Family"
        )

        XCTAssertEqual(
            dto.members,
            ["user-1", "user-2"]
        )

        XCTAssertEqual(
            dto.geo.radius,
            100
        )
    }
}

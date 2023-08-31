//
//  AnyCodableModelTests.swift
//
//
//  Created by Yusuf Özgül on 31.08.2023.
//

import XCTest
@testable import AnyCodable

final class AnyCodableTests: XCTestCase {
    struct DemoModel: Codable {
        let sizeExpectations: AnyCodableModel
    }

    func test_simpleArray_ExpectEncodeAndDecode() throws {
        let jsonText = """
{
  "sizeExpectations" : [
    0,
    1,
    2,
    3
  ]
}
"""

        let data = try XCTUnwrap(jsonText.data(using: .utf8))
        let decoded = try JSONDecoder().decode(DemoModel.self, from: data)
        let encoded = try JSONEncoder().encode(decoded)

        let encodedString = try XCTUnwrap(String(data: encoded, encoding: .utf8))

        let encodedJsonText = """
{"sizeExpectations":[0,1,2,3]}
"""

        XCTAssertEqual(encodedString, encodedJsonText)
    }

    func test_complexArray_ExpectEncodeAndDecode() throws {
        let jsonText = """
{
  "sizeExpectations": [
    [
      0
    ],
    [
      1
    ],
    [
      2
    ],
    [
      3
    ]
  ]
}
"""

        let data = try XCTUnwrap(jsonText.data(using: .utf8))
        let decoded = try JSONDecoder().decode(DemoModel.self, from: data)
        let encoded = try JSONEncoder().encode(decoded)

        let encodedString = try XCTUnwrap(String(data: encoded, encoding: .utf8))

        let encodedJsonText = """
{"sizeExpectations":[[0],[1],[2],[3]]}
"""

        XCTAssertEqual(encodedString, encodedJsonText)
    }

    func test_simpleObject_ExpectEncodeAndDecode() throws {
        let jsonText = """
{
  "sizeExpectations": {
    "color": "F27A1A"
  }
}
"""

        let data = try XCTUnwrap(jsonText.data(using: .utf8))
        let decoded = try JSONDecoder().decode(DemoModel.self, from: data)
        let encoded = try JSONEncoder().encode(decoded)

        let encodedString = try XCTUnwrap(String(data: encoded, encoding: .utf8))

        let encodedJsonText = """
{"sizeExpectations":{"color":"F27A1A"}}
"""

        XCTAssertEqual(encodedString, encodedJsonText)
    }

    func test_complexObject_ExpectEncodeAndDecode() throws {
        let jsonText = """
{
  "sizeExpectations": {
    "colors": {
      "selectedColor": {
        "foregroundColor": "F27A1A"
      }
    }
  }
}
"""

        let data = try XCTUnwrap(jsonText.data(using: .utf8))
        let decoded = try JSONDecoder().decode(DemoModel.self, from: data)
        let encoded = try JSONEncoder().encode(decoded)

        let encodedString = try XCTUnwrap(String(data: encoded, encoding: .utf8))

        let encodedJsonText = """
{"sizeExpectations":{"colors":{"selectedColor":{"foregroundColor":"F27A1A"}}}}
"""

        XCTAssertEqual(encodedString, encodedJsonText)
    }

}

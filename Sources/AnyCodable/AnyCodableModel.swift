//
//  AnyCodableModel.swift
//
//
//  Created by Yusuf Özgül on 31.08.2023.
//

import Foundation

public struct AnyCodableModel: Codable {
    public let value: Any

    public init<T>(_ value: T?) {
        self.value = value ?? ()
    }
}

public extension AnyCodableModel {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            self.init(NSNull())
        } else if let bool = try? container.decode(Bool.self) {
            self.init(bool)
        } else if let int = try? container.decode(Int.self) {
            self.init(int)
        } else if let double = try? container.decode(Double.self) {
            self.init(double)
        } else if let string = try? container.decode(String.self) {
            self.init(string)
        } else if let array = try? container.decode([AnyCodableModel].self) {
            self.init(array.map { $0.value })
        } else if let dictionary = try? container.decode([String: AnyCodableModel].self) {
            self.init(dictionary.mapValues { $0.value })
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "AnyDecodable value cannot be decoded")
        }
    }
}

public extension AnyCodableModel {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch value {
        case let encodable as Encodable:
            try encodable.encode(to: encoder)
        case let array as [Any?]:
            try container.encode(array.map { AnyCodableModel($0) })
        case let dictionary as [String: Any?]:
            try container.encode(dictionary.mapValues { AnyCodableModel($0) })
        case is NSNull:
            try container.encodeNil()
        default:
            let context = EncodingError.Context(codingPath: container.codingPath, debugDescription: "AnyEncodable value cannot be encoded")
            throw EncodingError.invalidValue(value, context)
        }
    }
}

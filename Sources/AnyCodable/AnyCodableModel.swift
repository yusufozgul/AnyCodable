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

    public init(jsonText: String) throws {
        guard let data = jsonText.data(using: .utf8) else {
            throw NSError(domain: "AnyDecodable", code: -1)
        }

        self = try JSONDecoder().decode(Self.self, from: data)
    }
}

// MARK: - Decodable
public extension AnyCodableModel {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let bool = try? container.decode(Bool.self) {
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
        } else if container.decodeNil() {
            self.init(NSNull())
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "AnyDecodable value cannot be decoded")
        }
    }
}

// MARK: - Encodable
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

// MARK: - CustomStringConvertible
extension AnyCodableModel: CustomStringConvertible {
    public var description: String {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self.value, options: [.prettyPrinted, .sortedKeys])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
            return "Error converting to JSON"
        } catch {
            return "Error converting to JSON: \(error)."
        }
    }
}

// MARK: - Equatable
extension AnyCodableModel: Equatable {
    public static func == (lhs: AnyCodableModel, rhs: AnyCodableModel) -> Bool {
        switch (lhs.value, rhs.value) {
        case let (lhs as Bool, rhs as Bool):
            return lhs == rhs
        case let (lhs as Int, rhs as Int):
            return lhs == rhs
        case let (lhs as Double, rhs as Double):
            return lhs == rhs
        case let (lhs as String, rhs as String):
            return lhs == rhs
        case let (lhs as [String: AnyCodableModel], rhs as [String: AnyCodableModel]):
            return lhs == rhs
        case let (lhs as [AnyCodableModel], rhs as [AnyCodableModel]):
            return lhs == rhs
        case is (NSNull, NSNull), is (Void, Void):
            return true
        default:
            return false
        }
    }
}

// MARK: - Hashable
extension AnyCodableModel: Hashable {
    public func hash(into hasher: inout Hasher) {
        switch value {
        case let value as Bool:
            hasher.combine(value)
        case let value as Int:
            hasher.combine(value)
        case let value as Double:
            hasher.combine(value)
        case let value as String:
            hasher.combine(value)
        case let value as [String: AnyCodableModel]:
            hasher.combine(value)
        case let value as [AnyCodableModel]:
            hasher.combine(value)
        default:
            break
        }
    }
}

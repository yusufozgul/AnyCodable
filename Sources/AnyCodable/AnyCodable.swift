import Foundation

public struct JSONCodingKeys: CodingKey {
    public var stringValue: String

    public init(stringValue: String) {
        self.stringValue = stringValue
    }

    public var intValue: Int?

    public init?(intValue: Int) {
        self.init(stringValue: "\(intValue)")
        self.intValue = intValue
    }
}

public extension KeyedDecodingContainer {
    func decode(_ type: Any.Type, forKey key: K) throws -> Any {
        if let container = try? self.nestedContainer(keyedBy: JSONCodingKeys.self, forKey: key),
           let value = try? container.decode([String: Any].self) {
            return value
        } else if var container = try? self.nestedUnkeyedContainer(forKey: key),
                  let value = try? container.decode([Any].self) {
            return value
        } else {
            throw EncodingError.invalidValue(key, .init(codingPath: codingPath, debugDescription: "Invalid JSON value"))
        }
    }

    func decode(_ type: [String: Any].Type, forKey key: K) throws -> [String: Any] {
        let container = try self.nestedContainer(keyedBy: JSONCodingKeys.self, forKey: key)
        return try container.decode(type)
    }

    func decode(_ type: [Any].Type, forKey key: K) throws -> [Any] {
        var container = try self.nestedUnkeyedContainer(forKey: key)
        return try container.decode(type)
    }

    func decode(_ type: [String: Any].Type) throws -> [String: Any] {
        var dictionary = [String: Any]()

        for key in allKeys {
            if let boolValue = try? decode(Bool.self, forKey: key) {
                dictionary[key.stringValue] = boolValue
            } else if let stringValue = try? decode(String.self, forKey: key) {
                dictionary[key.stringValue] = stringValue
            } else if let intValue = try? decode(Int.self, forKey: key) {
                dictionary[key.stringValue] = intValue
            } else if let doubleValue = try? decode(Double.self, forKey: key) {
                dictionary[key.stringValue] = doubleValue
            } else if let nestedDictionary = try? decode([String: Any].self, forKey: key) {
                dictionary[key.stringValue] = nestedDictionary
            } else if let nestedArray = try? decode([Any].self, forKey: key) {
                dictionary[key.stringValue] = nestedArray
            } else {
                do {
                    if try decode(String?.self, forKey: key) == nil {
                        dictionary[key.stringValue] = nil
                    }
                } catch { }
            }
        }
        return dictionary
    }

    func decode(_ type: [Any].Type) throws -> Any {
        var array = [Any?]()

        for key in allKeys {
            if let boolValue = try? decode(Bool.self, forKey: key) {
                array.append(boolValue)
            } else if let stringValue = try? decode(String.self, forKey: key) {
                array.append(stringValue)
            } else if let intValue = try? decode(Int.self, forKey: key) {
                array.append(intValue)
            } else if let doubleValue = try? decode(Double.self, forKey: key) {
                array.append(doubleValue)
            } else if let nestedDictionary = try? decode([String: Any].self, forKey: key) {
                array.append(nestedDictionary)
            } else if let nestedArray = try? decode([Any].self, forKey: key) {
                array.append(nestedArray)
            } else {
                do {
                    if try decode(String?.self, forKey: key) == nil {
                        array.append(nil)
                    }
                } catch { }
            }
        }
        return array
    }
}

public extension UnkeyedDecodingContainer {
    mutating func decode(_ type: [Any].Type) throws -> [Any] {
        var array: [Any] = []

        while !isAtEnd {
            if let value = try? decode(Bool.self) {
                array.append(value)
            } else if let value = try? decode(Int.self) {
                array.append(value)
            } else if let value = try? decode(Double.self) {
                array.append(value)
            } else if let value = try? decode(String.self) {
                array.append(value)
            } else if let nestedDictionary = try? decode([String: Any].self) {
                array.append(nestedDictionary)
            } else if let nestedArray = try? decode([Any].self) {
                array.append(nestedArray)
            }
        }
        return array
    }

    mutating func decode(_ type: [String: Any].Type) throws -> [String: Any] {
        let nestedContainer = try self.nestedContainer(keyedBy: JSONCodingKeys.self)
        return try nestedContainer.decode(type)
    }
}

public extension KeyedEncodingContainerProtocol where Key == JSONCodingKeys {
    mutating func encode(_ value: [String: Any]) throws {
        try value.forEach({ (key, jsonValue) in
            let key = JSONCodingKeys(stringValue: key)
            switch jsonValue {
            case let value as Bool where type(of: jsonValue) == type(of: NSNumber(booleanLiteral: true)) || type(of: jsonValue) == Swift.Bool.self:
                            try encode(value, forKey: key)
                            :
                try encode(value, forKey: key)
            case let value as Int:
                try encode(value, forKey: key)
            case let value as String:
                try encode(value, forKey: key)
            case let value as Double:
                try encode(value, forKey: key)
            case let value as CGFloat:
                try encode(value, forKey: key)
            case let value as [String: Any]:
                try encode(value, forKey: key)
            case let value as [Any]:
                try encode(value, forKey: key)
            case Optional<Any>.none, is NSNull:
                try encodeNil(forKey: key)
            default:
                throw EncodingError.invalidValue(value, .init(codingPath: codingPath, debugDescription: "Invalid JSON value"))
            }
        })
    }
}

public extension KeyedEncodingContainerProtocol {
    mutating func encode(_ value: [String: Any]?, forKey key: Key) throws {
        if value != nil {
            var container = self.nestedContainer(keyedBy: JSONCodingKeys.self, forKey: key)
            try container.encode(value!)
        }
    }

    mutating func encode(_ value: [Any]?, forKey key: Key) throws {
        if value != nil {
            var container = self.nestedUnkeyedContainer(forKey: key)
            try container.encode(value!)
        }
    }

    mutating func encode(_ value: Any, forKey key: Key) throws {
        if let jsonValue = value as? [Any] {
            var unkeyedContainer = self.nestedUnkeyedContainer(forKey: key)
            try unkeyedContainer.encode(jsonValue)
        } else if let jsonValue = value as? [String: Any] {
            var keyedContainer = self.nestedContainer(keyedBy: JSONCodingKeys.self, forKey: key)
            try keyedContainer.encode(jsonValue)
        } else if let jsonValue = value as? EmptyResponse {
            var unkeyedContainer = self.nestedUnkeyedContainer(forKey: key)
            try unkeyedContainer.encode(jsonValue)
        } else {
            throw EncodingError.invalidValue(key, .init(codingPath: codingPath, debugDescription: "Invalid JSON value"))
        }
    }
}

public extension UnkeyedEncodingContainer {
    mutating func encode(_ value: [Any]) throws {
        try value.enumerated().forEach({ (index, jsonValue) in
            switch jsonValue {
            case let value as Bool where type(of: jsonValue) == type(of: NSNumber(booleanLiteral: true)) || type(of: jsonValue) == Swift.Bool.self:
                try encode(value)
            case let value as Int:
                try encode(value)
            case let value as String:
                try encode(value)
            case let value as Double:
                try encode(value)
            case let value as CGFloat:
                try encode(value)
            case let value as [String: Any]:
                try encode(value)
            case let value as [Any]:
                try encode(value)
            case Optional<Any>.none, is NSNull:
                try encodeNil()
            default:
                let keys = JSONCodingKeys(intValue: index).map({ [ $0 ] }) ?? []
                throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: codingPath + keys, debugDescription: "Invalid JSON value"))
            }
        })
    }

    mutating func encode(_ value: [String: Any]) throws {
        var nestedContainer = self.nestedContainer(keyedBy: JSONCodingKeys.self)
        try nestedContainer.encode(value)
    }
}

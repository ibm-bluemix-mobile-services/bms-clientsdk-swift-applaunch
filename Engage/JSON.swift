/**
 * Copyright IBM Corporation 2016
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import Foundation

// MARK: WJSON Paths

public protocol JSONPathType {
    func value(in dictionary: [String: Any]) throws -> WJSON
    func value(in array: [Any]) throws -> WJSON
}

extension String: JSONPathType {
    public func value(in dictionary: [String: Any]) throws -> WJSON {
        let json = dictionary[self]
        return WJSON(json: json)
    }
    
    public func value(in array: [Any]) throws -> WJSON {
        throw WJSON.Error.unexpectedSubscript(type: String.self)
    }
}

extension Int: JSONPathType {
    public func value(in dictionary: [String: Any]) throws -> WJSON {
        throw WJSON.Error.unexpectedSubscript(type: Int.self)
    }
    
    public func value(in array: [Any]) throws -> WJSON {
        let json = array[self]
        return WJSON(json: json)
    }
}

// MARK: - WJSON

public struct WJSON {
    fileprivate let json: Any
    
    public init(json: Any) {
        self.json = json
    }
    
    public init(string: String) throws {
        guard let data = string.data(using: .utf8) else {
            throw Error.encodingError
        }
        json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
    }
    
    public init(data: Data) throws {
        json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
    }
    
    public init(dictionary: [String: Any]) {
        json = dictionary
    }
    
    public init(array: [Any]) {
        json = array
    }
    
    public func serialize() throws -> Data {
        return try JSONSerialization.data(withJSONObject: json, options: [])
    }
    
    public func serializeString() throws -> String {
        let data = try serialize()
        guard let string = String(data: data, encoding: .utf8) else {
            throw Error.stringSerializationError
        }
        return string
    }
    
    private func value(at path: JSONPathType) throws -> WJSON {
        if let dictionary = json as? [String: Any] {
            return try path.value(in: dictionary)
        }
        if let array = json as? [Any] {
            return try path.value(in: array)
        }
        throw Error.unexpectedSubscript(type: type(of: path))
    }
    
    private func value(at path: [JSONPathType]) throws -> WJSON {
        var value = self
        for fragment in path {
            value = try value.value(at: fragment)
        }
        return value
    }

    public func decode<Decoded: JSONDecodable>(at path: JSONPathType..., type: Decoded.Type = Decoded.self) throws -> Decoded {
        return try Decoded(json: value(at: path))
    }
    
    public func getDouble(at path: JSONPathType...) throws -> Double {
        return try Double(json: value(at: path))
    }
    
    public func getInt(at path: JSONPathType...) throws -> Int {
        return try Int(json: value(at: path))
    }
    
    public func getString(at path: JSONPathType...) throws -> String {
        return try String(json: value(at: path))
    }
    
    public func getBool(at path: JSONPathType...) throws -> Bool {
        return try Bool(json: value(at: path))
    }
    
    public func getArray(at path: JSONPathType...) throws -> [WJSON] {
        let json = try value(at: path)
        guard let array = json.json as? [Any] else {
            throw Error.valueNotConvertible(value: json, to: [WJSON].self)
        }
        return array.map { WJSON(json: $0) }
    }
    
    public func decodedArray<Decoded: JSONDecodable>(at path: JSONPathType..., type: Decoded.Type = Decoded.self) throws -> [Decoded] {
        let json = try value(at: path)
        guard let array = json.json as? [Any] else {
            throw Error.valueNotConvertible(value: json, to: [Decoded].self)
        }
        return try array.map { try Decoded(json: WJSON(json: $0)) }
    }
    
    public func decodedDictionary<Decoded: JSONDecodable>(at path: JSONPathType..., type: Decoded.Type = Decoded.self) throws -> [String: Decoded] {
        let json = try value(at: path)
        guard let dictionary = json.json as? [String: Any] else {
            throw Error.valueNotConvertible(value: json, to: [String: Decoded].self)
        }
        var decoded = [String: Decoded](minimumCapacity: dictionary.count)
        for (key, value) in dictionary {
            decoded[key] = try Decoded(json: WJSON(json: value))
        }
        return decoded
    }
    
    public func getJSON(at path: JSONPathType...) throws -> Any {
        return try value(at: path).json
    }
    
    public func getDictionary(at path: JSONPathType...) throws -> [String: WJSON] {
        let json = try value(at: path)
        guard let dictionary = json.json as? [String: Any] else {
            throw Error.valueNotConvertible(value: json, to: [String: WJSON].self)
        }
        return dictionary.map { WJSON(json: $0) }
    }
    
    public func getDictionaryObject(at path: JSONPathType...) throws -> [String: Any] {
        let json = try value(at: path)
        guard let dictionary = json.json as? [String: Any] else {
            throw Error.valueNotConvertible(value: json, to: [String: WJSON].self)
        }
        return dictionary
    }
}

// MARK: - WJSON Errors

extension WJSON {
    public enum Error: Swift.Error {
        case indexOutOfBounds(index: Int)
        case keyNotFound(key: String)
        case unexpectedSubscript(type: JSONPathType.Type)
        case valueNotConvertible(value: WJSON, to: Any.Type)
        case encodingError
        case stringSerializationError
    }
}

// MARK: - WJSON Protocols

public protocol JSONDecodable {
    init(json: WJSON) throws
}

public protocol JSONEncodable {
    func toJSON() -> WJSON
    func toJSONObject() -> Any
}

extension JSONEncodable {
    public func toJSON() -> WJSON {
        return WJSON(json: self.toJSONObject())
    }
}

extension Double: JSONDecodable {
    public init(json: WJSON) throws {
        let any = json.json
        if let double = any as? Double {
            self = double
        } else if let int = any as? Int {
            self = Double(int)
        } else if let string = any as? String, let double = Double(string) {
            self = double
        } else {
            throw WJSON.Error.valueNotConvertible(value: json, to: Double.self)
        }
    }
}

extension Int: JSONDecodable {
    public init(json: WJSON) throws {
        let any = json.json
        if let int = any as? Int {
            self = int
        } else if let double = any as? Double, double <= Double(Int.max) {
            self = Int(double)
        } else if let string = any as? String, let int = Int(string) {
            self = int
        } else {
            throw WJSON.Error.valueNotConvertible(value: json, to: Int.self)
        }
    }
}

extension Bool: JSONDecodable {
    public init(json: WJSON) throws {
        let any = json.json
        if let bool = any as? Bool {
            self = bool
        } else {
            throw WJSON.Error.valueNotConvertible(value: json, to: Bool.self)
        }
    }
}

extension String: JSONDecodable {
    public init(json: WJSON) throws {
        let any = json.json
        if let string = any as? String {
            self = string
        } else if let int = any as? Int {
            self = String(int)
        } else if let bool = any as? Bool {
            self = String(bool)
        } else if let double = any as? Double {
            self = String(double)
        } else {
            throw WJSON.Error.valueNotConvertible(value: json, to: String.self)
        }
    }
}

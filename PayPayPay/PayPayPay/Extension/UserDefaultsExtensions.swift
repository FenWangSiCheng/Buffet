//
//  UserDefaultsExtensions.swift
//  SwifterSwift
//
//  Created by wangsicheng on 9/5/18.
//  Copyright © 2018 SwifterSwift
//

import Foundation

public extension UserDefaults {

    subscript(key: String) -> Any? {
        get {
            return object(forKey: key)
        }
        set {
            set(newValue, forKey: key)
        }
    }

    func float(forKey key: String) -> Float? {
        return object(forKey: key) as? Float
    }

    func date(forKey key: String) -> Date? {
        return object(forKey: key) as? Date
    }

    func object<T: Codable>(_ type: T.Type, with key: String, usingDecoder decoder: JSONDecoder = JSONDecoder()) -> T? {
        guard let data = value(forKey: key) as? Data else { return nil }
        return try? decoder.decode(type.self, from: data)
    }

    func set<T: Codable>(object: T, forKey key: String, usingEncoder encoder: JSONEncoder = JSONEncoder()) {
        let data = try? encoder.encode(object)
        set(data, forKey: key)
    }

}

@propertyWrapper
struct UserDefault<T: Codable> {
    let key: String
    let defaultValue: T

    init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: T {
        get {
            return UserDefaults.standard.object(T.self, with: key) ?? defaultValue
        }
        set {
            UserDefaults.standard.set(object: newValue, forKey: key)
        }
    }
}

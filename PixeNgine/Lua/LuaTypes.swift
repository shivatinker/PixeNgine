//
//  LuaTypes.swift
//  PixeNgine
//
//  Created by Andrii Zinoviev on 05.05.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation

public protocol LuaCodable {

}

public class LuaEncoder {
    public static func encode(_ c: LuaCodable) -> LuaValue {
        let mirror = Mirror(reflecting: c)
        var kv = [String: LuaValue]()
        for child in mirror.children {
            if let key = child.label {
                if let codable = child.value as? LuaCodable {
                    kv[key] = Self.encode(codable)
                } else if let compatible = child.value as? LuaCompatible {
                    kv[key] = compatible.luaValue
                } else {
                    fatalError("\(key):\(child.value) is not LuaCodable nor LuaCompatible")
                }
            }
        }
        return .table(kv)
    }
}

public enum LuaType {
    case string
    case integer
    case number
    case table
}

public enum LuaValue {
    case string(_ swiftType: String)
    case integer(_ swiftType: Int64)
    case number(_ swiftType: Float)
    case table(_ kv: [String: LuaValue])
}

public protocol LuaCompatible {
    var luaValue: LuaValue { get }
    static func fromLua(_ v: LuaValue?) -> Self?
}

// MARK: Type extensions

extension Int64: LuaCompatible {
    public static func fromLua(_ v: LuaValue?) -> Int64? {
        switch v {
        case let .integer(i):
            return Int64(i)
        case let .number(f):
            return Int64(roundf(f))
        default:
            return nil
        }
    }

    public var luaValue: LuaValue {
            .integer(self)
    }
}

extension Int: LuaCompatible {
    public static func fromLua(_ v: LuaValue?) -> Int? {
        if let i64 = Int64.fromLua(v) {
            return Int(i64)
        } else {
            return nil
        }
    }
    public var luaValue: LuaValue {
            .integer(Int64(self))
    }
}

extension String: LuaCompatible {

    public static func fromLua(_ v: LuaValue?) -> String? {
        if case let .string(s) = v {
            return s
        } else {
            return nil
        }
    }

    public var luaValue: LuaValue {
            .string(self)
    }
}

extension Float: LuaCompatible {
    public static func fromLua(_ v: LuaValue?) -> Float? {
        switch v {
        case let .integer(i):
            return Float(i)
        case let .number(f):
            return f
        default:
            return nil
        }
    }

    public var luaValue: LuaValue {
            .number(self)
    }
}

extension Double: LuaCompatible {
    public static func fromLua(_ v: LuaValue?) -> Double? {
        if let f = Float.fromLua(v) {
            return Double(f)
        } else {
            return nil
        }
    }
    public var luaValue: LuaValue {
            .number(Float(self))
    }
}

//
//  LuaTypes.swift
//  PixeNgine
//
//  Created by Andrii Zinoviev on 05.05.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation


//public class LuaEncoder {
//    public static func encode(_ c: LuaCodable) -> LuaValue {
//        let mirror = Mirror(reflecting: c)
//        var kv = [String: LuaValue]()
//        for child in mirror.children {
//            if let key = child.label {
//                if let codable = child.value as? LuaCodable {
//                    kv[key] = Self.encode(codable)
//                } else if let compatible = child.value as? LuaCompatible {
//                    kv[key] = compatible.luaValue
//                } else {
//                    fatalError("\(key):\(child.value) is not LuaCodable nor LuaCompatible")
//                }
//            }
//        }
//        return .table(kv)
//    }
//}

public protocol LuaValue {
    func luaPush(_ L: LuaVM.VMState)

    static func luaGet(_ L: LuaVM.VMState, _ addr: Int32) -> Self
}

public extension LuaValue {


    static func luaTop(_ L: LuaVM.VMState) -> Self {
        return luaGet(L, -1)
    }

    static func luaPop(_ L: LuaVM.VMState) -> Self {
        defer { luaPop_(L) }
        return luaGet(L, -1)
    }
}

// MARK: Integers
extension Int64: LuaValue {
    public func luaPush(_ L: LuaVM.VMState) {
        lua_pushinteger(L, lua_Integer(self))
    }

    public static func luaGet(_ L: LuaVM.VMState, _ addr: Int32) -> Int64 {
        return lua_tointegerx(L, addr, nil)
    }
}

extension Int: LuaValue {
    public func luaPush(_ L: LuaVM.VMState) {
        Int64(self).luaPush(L)
    }

    public static func luaGet(_ L: LuaVM.VMState, _ addr: Int32) -> Int {
        return Int(Int64.luaGet(L, addr))
    }
}

// MARK: String
extension String: LuaValue {
    public func luaPush(_ L: LuaVM.VMState) {
        lua_pushstring(L, self)
    }

    public static func luaGet(_ L: LuaVM.VMState, _ addr: Int32) -> String {
        return String(cString: lua_tolstring(L, addr, nil))
    }
}

// MARK: Numbers
extension Double: LuaValue {
    public func luaPush(_ L: LuaVM.VMState) {
        lua_pushnumber(L, self)
    }

    public static func luaGet(_ L: LuaVM.VMState, _ addr: Int32) -> Double {
        return lua_tonumberx(L, addr, nil)
    }
}

extension Float: LuaValue {
    public func luaPush(_ L: LuaVM.VMState) {
        Double(self).luaPush(L)
    }

    public static func luaGet(_ L: LuaVM.VMState, _ addr: Int32) -> Float {
        return Float(Double.luaGet(L, addr))
    }
}

private func getType(_ L: LuaVM.VMState, _ addr: Int32 = -1) -> LuaValue.Type {
    lua_getglobal(L, "math")
    guard lua_type(L, -1) != LUA_TNIL else {
        fatalError("Unable to get lua math library")
    }
    lua_getfield(L, -1, "type")
    lua_pushvalue(L, -3)
    lua_rotate(L, -1, 1)
    lua_pcallk(L, 1, 1, 0, 0, nil)

    if lua_type(L, -1) != LUA_TNIL {
        let ntype = String.luaPop(L)
        luaPop_(L)

        switch ntype {
        case "float":
            return Double.self
        case "integer":
            return Int64.self
        default: assertionFailure()
        }
    }
    luaPop_(L)
    luaPop_(L)

    let t = lua_type(L, addr)

    switch t {
    case LUA_TSTRING:
        return String.self
    case LUA_TTABLE:
        return LuaTable.self
    default:
        stackDump(L)
        fatalError("Unknown type on top of the stack: \(String(cString: lua_typename(L, -1)))")
    }
}

internal func luaGetAuto(_ L: LuaVM.VMState, _ addr: Int32 = -1) -> LuaValue {
    let type: LuaValue.Type = getType(L)
    return type.luaGet(L, addr)
}

internal func luaPopAuto(_ L: LuaVM.VMState) -> LuaValue {
    let tt: LuaValue.Type = getType(L)
    debugPrint(tt)
    return tt.luaPop(L)
}

// MARK: Tables

public struct LuaTable: LuaValue {

    private var rows: [String: LuaValue]

    public func luaPush(_ L: LuaVM.VMState) {
        lua_createtable(L, 0, Int32(rows.count))
        for kv in rows {
            let val = kv.value
            lua_pushstring(L, kv.key)
            val.luaPush(L)
            lua_settable(L, -3)
        }
    }

    public static func luaGet(_ L: LuaVM.VMState, _ addr: Int32) -> LuaTable {

        print("Table get")
        stackDump(L)

        var res = LuaTable()
        lua_pushnil(L)

        while(lua_next(L, -2) != 0) {
            let key = String.luaGet(L, -2)
            print("Key: \(key)")
            stackDump(L)
            res.rows[key] = luaPopAuto(L)
            debugPrint(res)
//            stackDump(L)
        }
        return res
    }

    public init(rows: [String: LuaValue] = [:]) {
        self.rows = rows
    }


    public subscript(index: String) -> LuaValue {
        if let row = rows[index] {
            return row
        } else {
            fatalError("No \"\(index)\" row in table")
        }
    }
}

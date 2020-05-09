//
//  PXLuaTest.swift
//  PixeNgine
//
//  Created by Andrii Zinoviev on 05.05.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation

public struct LuaFunction {
    public init(name: String, args: Int, res: Int) {
        self.name = name
        self.args = args
        self.res = res
    }

    public let name: String
    public let args: Int
    public let res: Int
}

// MARK: Useful marcos
private func pop(_ L: LuaVM.VMState, n: Int = 1) {
    lua_settop(L, Int32(-n - 1))
}

private func upvalue_index(_ i: Int) -> Int32 {
    return (-LUAI_MAXSTACK - 1000) - Int32(i)
}


private func push(_ L: LuaVM.VMState, _ v: LuaValue) {
    switch v {
    case let .number(f):
        lua_pushnumber(L, lua_Number(f))
    case let .integer(i):
        lua_pushinteger(L, lua_Integer(i))
    case let .string(s):
        lua_pushstring(L, s)
    case let .table(kv):
        lua_createtable(L, 0, Int32(kv.count))
        for kv in kv {
            let v = kv.value
            lua_pushstring(L, kv.key)
            push(L, v)
            lua_settable(L, -3)
        }
    }
}

// TODO: FIX THIS DOUBLE SHIT
private func poparg(_ L: LuaVM.VMState) -> LuaValue? {
    defer {
        pop(L)
    }
    switch lua_type(L, -1) {
    case LUA_TNUMBER:
        return .number(Float(lua_tonumberx(L, -1, nil)))
    case LUA_TSTRING:
        return .string(String(cString: lua_tolstring(L, -1, nil)))
    case LUA_TTABLE:
        var kv = [String: LuaValue]()
        lua_pushnil(L)
        while(lua_next(L, -2) != 0) {
            kv[String(cString: lua_tolstring(L, -2, nil))] = poparg(L)
        }
        return .table(kv)
    default:
        return nil
    }
}

// MARK: LuaVM
public class LuaVM {
    // MARK: Private
    private var L: VMState
    private var loadedCModules = [LuaCModule]()

    // Error handler for pcall
    private var errorfuncSL: Int32
    private static let errorfunc: lua_CFunction = { L in
        pxDebug("Lua error!:")
        pxDebug(String(cString: lua_tolstring(L, -1, nil)))
        lua_getglobal(L, "debug")
        lua_getfield(L, -1, "traceback")
        lua_pcallk(L, 0, 1, 0, 0, nil)
        pxDebug(String(cString: lua_tolstring(L, -1, nil)))
        lua_settop(L, -2)
        return 0
    }

    private func pcall(nargs: Int, nresults: Int) {
        lua_pcallk(L, Int32(nargs), Int32(nresults), errorfuncSL, 0, nil)
    }

    /// Calls passed closure and ensures, that pointer in "_loadedModules" will be correct in this closure
    /// - Parameter f: Closure to be called
    private func withModules(_ f: () -> ()) {
        withUnsafePointer(to: loadedCModules) { ptr in

            let iptr: lua_Integer = lua_Integer(Int(bitPattern: ptr))
            lua_pushinteger(L, lua_Integer(iptr))
            lua_setglobal(L, "_loadedModules")

            f()
        }
    }

    /// Calls function on top of the stack
    /// - Parameters:
    ///   - f: LuaFunction to be called
    ///   - args: Arguments
    /// - Returns: Array of LuaValue, if function call succeeded, else nil
    private func callFunctionOnTop(_ f: LuaFunction, args: [LuaValue]) -> [LuaValue]? {
        guard args.count == f.args else {
            pxDebug("Wrong number of args for \(f.name). Expected: \(f.args). Got: \(args.count)")
            return nil
        }
        guard lua_type(L, -1) == LUA_TFUNCTION else {
            pxDebug("\(f.name) is not a function, it is \(lua_type(L, -1))!")
            return nil
        }


        for v in args { push(L, v) }

        withModules {
            pcall(nargs: args.count, nresults: f.res)
        }

        var res = [LuaValue]()
        for i in 1...f.res {
            if let v = poparg(L) {
                res.append(v)
            } else {
                pxDebug("Wrong return type!")
                // Stack safety
                pop(L, n: f.res - i)
                return nil
            }
        }
        return res.reversed()
    }

    // MARK: Internal
    internal func debugInfo() {
        pxDebug("Stack size: \(lua_gettop(L)), Top type: \(lua_type(L, -1))")
    }

    internal func callFromGlobals(_ f: LuaFunction, args: [LuaValue] = []) -> [LuaValue]? {
        lua_getglobal(L, f.name)
        guard let r = callFunctionOnTop(f, args: args) else {
            pop(L, n: 1)
            return nil
        }
        return r
    }

    internal func callFromModule(moduleName: String, f: LuaFunction, args: [LuaValue] = []) -> [LuaValue]? {
        lua_getglobal(L, moduleName) // 1
        lua_getfield(L, -1, f.name) // 2
        guard let r = callFunctionOnTop(f, args: args) else { // pop 2
            pop(L, n: 2)
            return nil
        }
        pop(L, n: 1) // pop 1
        return r
    }

    // MARK: Public
    public typealias VMState = UnsafeMutablePointer<lua_State>

    public init() {
        self.L = luaL_newstate()
        luaL_openlibs(L)
        lua_pushcclosure(L, Self.errorfunc, 0)
        errorfuncSL = lua_gettop(L)
    }
    
    /// Runs lua code in string
    /// - Parameter data: lua codec
    public func doString(_ data: String) {
        withModules {
            luaL_loadstring(L, data)
            pcall(nargs: 0, nresults: -1)
        }
    }
    
    /// Runs lua script in file
    /// - Parameter file: file URL
    public func doFile(_ file: URL) {
        withModules {
            luaL_loadfilex(L, file.path, nil)
            pcall(nargs: 0, nresults: -1)
        }
    }
    
    /// Loads Lua module from file and assigns its table to global variable
    /// - Parameters:
    ///   - file: .lua file
    ///   - name: global variable name
    public func loadLModule(_ file: URL, name: String) {
        withModules {
            luaL_loadfilex(L, file.path, nil)
            pcall(nargs: 0, nresults: 1)
            lua_setglobal(L, name)
            pxDebug("Lua module \(name) loaded")
        }
    }

    /// Registers module of functions defined in C/Swift code
    /// - Parameter module: A LuaCModule object to be registered
    public func registerCModule(_ module: LuaCModule) {
        // Each module from C/Swift binds in function table in Lua, which has global visibility on VM
        // Also, we have global Lua table "_loadedModules", which stores pointer to [LuaCModule] object, so we can find our function body in Swift
        // Correction of pointers in this table achieved by running all Lua-code inside .withUnsafedPointer closure
        lua_createtable(L, 0, Int32(module.functions.count))
        for f in module.functions {
            lua_pushstring(L, "\(f.name)")

            // Closure has an upvalues with function name and module name, so we can refer to LuaCFunction object in C-closure
            lua_pushstring(L, module.name)
            lua_pushstring(L, f.name)
            lua_pushcclosure(L, { L in
                guard let L = L else { fatalError() }
                let mname = String(cString: lua_tolstring(L, upvalue_index(1), nil))
                let fname = String(cString: lua_tolstring(L, upvalue_index(2), nil))

                // Getting LuaCFunction object of current function
                lua_getglobal(L, "_loadedModules")
                let ptr: Int = Int(lua_tointegerx(L, -1, nil))
                pop(L)
                let modules = UnsafeRawPointer(bitPattern: ptr)!.load(as: [LuaCModule].self)
                let fu = (modules.first(where: { $0.name == mname })?.functions.first(where: { $0.name == fname }))!

                // Popping function arguments from stack
                var args = [LuaValue]()
                for _ in 0..<fu.args {
                    args.append(poparg(L)!)
                }
                let res = fu.body(args)
                // Pushing function results to stack
                assert(res.count == fu.res)
                for r in res {
                    push(L, r)
                }
                return Int32(fu.res)
            }, 2)
            lua_settable(L, -3)
        }
        lua_setglobal(L, "\(module.name)")
        loadedCModules.append(module)
    }
}

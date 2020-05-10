//
//  LuaLModule.swift
//  PixeNgine
//
//  Created by Andrii Zinoviev on 06.05.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation

public struct LuaLModule {
    private var vm: LuaVM
    private var impl: String
    private var functionsL = [String: LuaFunction]()

    public var moduleName: String {
        impl
    }

    public func getFunction(_ name: String) -> LuaFunction? {
        return functionsL[name]
    }

    public init(vm: LuaVM, name: String, functions: [LuaFunction]) {
        self.vm = vm
        self.impl = name
        functions.forEach({ self.functionsL[$0.name] = $0 })
    }

    public func call(_ f: String, _ args: LuaValue...) -> [LuaValue]? {
        guard let fl = functionsL[f] else {
            pxDebug("No function \(f) in module \(impl)")
            return nil
        }
        guard args.count == fl.args else {
            pxDebug("Wrong argument count for function \(f). Expected: \(fl.args), got: \(args.count)")
            return nil
        }
        return vm.callFromModule(moduleName: impl, f: fl, args: args)
    }
}

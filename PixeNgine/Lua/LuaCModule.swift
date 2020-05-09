//
//  LuaCModule.swift
//  PixeNgine
//
//  Created by Andrii Zinoviev on 05.05.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation

public struct LuaCFunction {
    public init(name: String, args: Int, res: Int, body: @escaping ([LuaValue]) -> [LuaValue]) {
        self.name = name
        self.args = args
        self.res = res
        self.body = body
    }

    public let name: String
    public let args: Int
    public let res: Int
    public let body: ([LuaValue]) -> [LuaValue]
}

public struct LuaCModule {
    public init(name: String, functions: [LuaCFunction]) {
        self.name = name
        self.functions = functions
    }

    public let name: String
    public var functions: [LuaCFunction]
}

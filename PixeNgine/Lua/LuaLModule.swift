//
//  LuaLModule.swift
//  PixeNgine
//
//  Created by Andrii Zinoviev on 06.05.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation


/// Struct describing loadable lua module and its functions
public struct LuaLModule {
    internal var functionsL = [String: LuaFunction]()

    public init(functions: [LuaFunction]) {
        functions.forEach({ self.functionsL[$0.name] = $0 })
    }
}

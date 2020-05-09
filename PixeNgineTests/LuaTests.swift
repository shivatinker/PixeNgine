//
//  LuaTests.swift
//  PixeNgineTests
//
//  Created by Andrii Zinoviev on 09.05.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import XCTest
import PixeNgine

class LuaTests: XCTestCase {

    private var vm: LuaVM!

    override func setUpWithError() throws {
        vm = LuaVM()
    }

    override func tearDownWithError() throws {

    }

    func testCModules() {
        let module = LuaCModule(name: "test", functions: [
            LuaCFunction(name: "addmul", args: 2, res: 2, body: { args in
                let (x, y) = (Int.fromLua(args[0])!, Int.fromLua(args[1])!)
                return [(x + y).luaValue, (x * y).luaValue]
            })
        ])
        vm.registerCModule(module)

        let testScript = Bundle(for: type(of: self)).url(forResource: "testimpl", withExtension: "lua")!
        vm.loadLModule(testScript, name: "testL")
        let lmodule = LuaLModule(vm: vm, name: "testL", functions: [
            LuaFunction(name: "test", args: 2, res: 2)
        ])
        
        XCTAssertEqual(lmodule.call("test", 43, 51)!.map({ Int.fromLua($0) }), [94, 2193])
    }

}

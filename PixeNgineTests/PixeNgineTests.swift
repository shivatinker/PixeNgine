//
//  PixeNgineTests.swift
//  PixeNgineTests
//
//  Created by Andrii Zinoviev on 09.04.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import XCTest
@testable import PixeNgine


struct TestStruct: LuaCodable {
    var someInteger: Int
    var someString: String
}



class PixeNgineTests: XCTestCase {

    private var vm: LuaVM!
    override func setUpWithError() throws {
        vm = LuaVM()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }


    let f = LuaCFunction(name: "test", args: 2, res: 1) { x in
        [(Int.fromLua(x[0])! + Int.fromLua(x[1])!).luaValue]
    }

    var module: LuaCModule!

    func testExample() throws {
        module = LuaCModule(name: "core", functions: [f])
        vm.registerCModule(module)
        vm.doString("""

            print(core.test(5,35))

            """)
    }

}

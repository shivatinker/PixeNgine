//
//  LuaTests.swift
//  PixeNgineTests
//
//  Created by Andrii Zinoviev on 09.05.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import XCTest
@testable import PixeNgine

class LuaTests: XCTestCase {

    private var vm: LuaVM!

    override func setUpWithError() throws {
        vm = LuaVM()
    }

    override func tearDownWithError() throws {

    }

//    func testCModules() {
//        let module = LuaCModule(name: "test", functions: [
//            LuaCFunction(name: "addmul", args: 2, res: 2, body: { args in
//                let (x, y) = (Int.fromLua(args[0])!, Int.fromLua(args[1])!)
//                return [(x + y).luaValue, (x * y).luaValue]
//            })
//        ])
//        vm.registerCModule(module)
//
//        let testScript = Bundle(for: type(of: self)).url(forResource: "testimpl", withExtension: "lua")!
//        vm.loadLModule(testScript, name: "testL")
//        let lmodule = LuaLModule(vm: vm, name: "testL", functions: [
//            LuaFunction(name: "test", args: 2, res: 2)
//        ])
//
//        XCTAssertEqual(lmodule.call("test", 43, 51)!.map({ Int.fromLua($0) }), [94, 2193])
//    }

    func testInt64(_ v: Int64, auto: Bool = false) {
        v.luaPush(vm.L)
        XCTAssertEqual(auto ? luaPopAuto(vm.L) as! Int64: Int64.luaPop(vm.L), v)
    }


    func testDouble(_ v: Double, auto: Bool = false) {
        v.luaPush(vm.L)
        XCTAssertEqual(auto ? luaPopAuto(vm.L) as! Double: Double.luaPop(vm.L), v, accuracy: 1e-7)
    }

    func testString(_ v: String, auto: Bool = false) {
        v.luaPush(vm.L)
        XCTAssertEqual(auto ? luaPopAuto(vm.L) as! String: String.luaPop(vm.L), v)
    }

    func testTable(_ v: LuaTable) {
        debugPrint(v)
        
        v.luaPush(vm.L)
        
        debugPrint(LuaTable.luaPop(vm.L))
        
//        v.luaPush(vm.L)
//        debugPrint(luaGetAuto(vm.L) as! LuaTable)
    }

    func testTypesWithAuto(auto: Bool) {
        testInt64(0xfffeeefffaaaf44, auto: auto)
        testInt64(0xfffba7941bba953, auto: auto)
        testDouble(1e-4, auto: auto)
        testDouble(15311643.5532, auto: auto)
        testString("12515frqgr3th2rjm9uje0x1rh719wehrjw1kelpmj-1j,x8soe")
    }

    func testTypes() {
        stackDump(vm.L)
        testTypesWithAuto(auto: false)
        testTypesWithAuto(auto: true)
        testTable(LuaTable(rows: [
            "adsf": 1234,
            "qwer__rq__": "rwf_",
            "ttqe": 31.5133
        ]))
        
        stackDump(vm.L)
    }
}

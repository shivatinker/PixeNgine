//
//  LuaCoderTests.swift
//  PixeNgineTests
//
//  Created by Andrii Zinoviev on 11.05.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import XCTest
import Foundation
@testable import PixeNgine

class LuaCoderTests: XCTestCase {

    override func setUpWithError() throws {

    }

    override func tearDownWithError() throws {

    }

    class Test: NSObject {
        @objc var name: String = ""
        @objc var int: PXv2f = .zero
    }

    func testExample() throws {
        let t = Test()
        t.setValue("fadg", forKey: "name")
        t.setValue(5234, forKey: "int")
        debugPrint(t.name, t.int)
    }

}

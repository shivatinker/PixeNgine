//
//  CollisionTests.swift
//  PixeNgineTests
//
//  Created by Andrii Zinoviev on 24.05.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import XCTest
@testable import PixeNgine

class CollisionTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        let e1 = PXEntity(name: "Ent 1")
        e1.physics = PXPhysics(shape: .rect(width: 16, height: 16))
        let e2 = PXEntity(name: "Ent 1")
        e2.physics = PXPhysics(shape: .rect(width: 32, height: 32))

        e1.pos = .zero
        e2.pos = PXv2f(3, 1)
        
        XCTAssert(PXCollider.isColliding(e2, e1))
        
        print(PXCollider.getIsectDepth(e2, e1))
        print(PXCollider.getResolveVector(e2, e1))
    }

}

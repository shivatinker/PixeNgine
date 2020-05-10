//
//  PXv2f.swift
//  PixeNgine
//
//  Created by Andrii Zinoviev on 14.04.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation

extension PXv2f: LuaValue {
    public func luaPush(_ L: LuaVM.VMState) {
        LuaTable(rows: [
            "x": x,
            "y": y
        ]).luaPush(L)
    }

    public static func luaGet(_ L: LuaVM.VMState, _ addr: Int32) -> PXv2f {
        let t = LuaTable.luaGet(L, addr)
        return PXv2f(t["x"] as! Float, t["y"] as! Float)
    }

}

public struct PXv2f {
    public static let zero = PXv2f(0, 0)
    public static let ones = PXv2f(1, 1)

    public init(_ x: Float, _ y: Float) {
        self.x = x
        self.y = y
    }

    public var x, y: Float
    public var abs: Float {
        sqrt(x * x + y * y)
    }
    public static func + (left: PXv2f, right: PXv2f) -> PXv2f {
        return PXv2f(left.x + right.x, left.y + right.y)
    }
    public static func - (left: PXv2f, right: PXv2f) -> PXv2f {
        return PXv2f(left.x - right.x, left.y - right.y)
    }
    public static func * (left: Float, right: PXv2f) -> PXv2f {
        return PXv2f(left * right.x, left * right.y)
    }
    public static func * (left: PXv2f, right: PXv2f) -> Float {
        return left.x * right.x + left.y * right.y
    }
    public func normalize() -> PXv2f {
        if abs == 0 {
            return .zero
        } else {
            return (1 / abs) * self
        }
    }
    public static func == (left: PXv2f, right: PXv2f) -> Bool {
        return left.x == right.x && left.y == right.y
    }
    public var vec: SIMD2<Float> {
        SIMD2<Float>(x: x, y: y)
    }
}

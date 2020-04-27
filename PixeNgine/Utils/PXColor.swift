//
//  PXColor.swift
//  PixeNgine
//
//  Created by Andrii Zinoviev on 09.04.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation
import UIKit
import Metal
import simd

public struct PXColor {
    public init(r: Float, g: Float, b: Float, a: Float) {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }
    
    public var r, g, b, a: Float
    public var vector: SIMD4<Float> {
        SIMD4<Float>(r, g, b, a)
    }
    public var uiColor: UIColor {
        UIColor(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: CGFloat(a))
    }
    public var mtlClearColor: MTLClearColor {
        MTLClearColor(red: Double(r), green: Double(g), blue: Double(b), alpha: Double(a))
    }
}

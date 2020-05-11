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

public struct PXColor: Codable {
    public init(r: Float, g: Float, b: Float, a: Float = 1.0) {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }

    public init(_ uicolor: UIColor){
        self.init(r: Float(uicolor.cgColor.components![0]),
                  g: Float(uicolor.cgColor.components![1]),
                  b: Float(uicolor.cgColor.components![2]),
                  a: Float(uicolor.cgColor.components![3]))
    }
    
    public var r, g, b: Float
    public var a: Float = 1.0
    public var vec: SIMD4<Float> {
        SIMD4<Float>(r, g, b, a)
    }
    public var uiColor: UIColor {
        UIColor(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: CGFloat(a))
    }
    public var mtlClearColor: MTLClearColor {
        MTLClearColor(red: Double(r), green: Double(g), blue: Double(b), alpha: Double(a))
    }
}

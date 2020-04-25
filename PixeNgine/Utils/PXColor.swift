//
//  PXColor.swift
//  PixeNgine
//
//  Created by Andrii Zinoviev on 09.04.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation
import UIKit
import simd

public struct PXColor {
    public var r, g, b, a: Float
    public var vector: SIMD4<Float> {
        SIMD4<Float>(r, g, b, a)
    }
    public var uiColor: UIColor {
        UIColor(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: CGFloat(a))
    }
}

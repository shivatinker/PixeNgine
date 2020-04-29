//
//  PXLight.swift
//  PixeNgine
//
//  Created by Andrii Zinoviev on 25.04.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation

open class PXLight {
    public var amount: Float
    public var color: PXColor
    public var radius: Float

    public var visible: Bool = true

    public init(amount: Float, color: PXColor, radius: Float) {
        self.amount = amount
        self.color = color
        self.radius = radius
    }
}

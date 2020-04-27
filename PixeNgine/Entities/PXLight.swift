//
//  PXLight.swift
//  PixeNgine
//
//  Created by Andrii Zinoviev on 25.04.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation

open class PXLight: PXEntity {
    public init(pos: PXv2f = .zero, dimensions: PXv2f = .zero, name: String, visible: Bool = true, outOfBoundsDiscardable: Bool = false, amount: Float, color: PXColor, radius: Float) {
        self.pos = pos
        self.dimensions = dimensions
        self.name = name
        self.visible = visible
        self.outOfBoundsDiscardable = outOfBoundsDiscardable
        self.amount = amount
        self.color = color
        self.radius = radius
    }

    public var pos: PXv2f = .zero

    public var dimensions: PXv2f = .zero

    public var name: String

    public var visible: Bool = true

    public var outOfBoundsDiscardable: Bool = false

    public var amount: Float
    public var color: PXColor
    public var radius: Float


}

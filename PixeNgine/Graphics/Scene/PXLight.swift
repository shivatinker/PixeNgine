//
//  PXLight.swift
//  PixeNgine
//
//  Created by Andrii Zinoviev on 25.04.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation

public class PXLight: PXEntity {
    public override var dimensions: PXv2f {
        2 * radius * .ones
    }

    public var amount: Float
    public var color: PXColor
    public var radius: Float

    public init(name: String, amount: Float, color: PXColor, radius: Float) {
        self.amount = amount
        self.color = color
        self.radius = radius
        super.init(name: name)
    }
}

public class PXFollowLight: PXLight {
    public weak var target: PXEntity?
    public override func update() {
        if let t = target {
            self.center = t.center
            if t.shouldBeRemoved {
                shouldBeRemoved = true
            }
        } else {
            shouldBeRemoved = true
        }
    }
}

// MARK: Descriptor support

public extension PXLight {
    convenience init(_ descriptor: PXLightDescriptor) {
        self.init(name: "[Unnamed]",
                  amount: descriptor.amount,
                  color: descriptor.color,
                  radius: descriptor.radius)
    }
}

public struct PXLightDescriptor: Codable {
    public var color: PXColor
    public var amount: Float
    public var radius: Float
}

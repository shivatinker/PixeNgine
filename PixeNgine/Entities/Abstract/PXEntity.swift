//
//  PXEntity.swift
//  PixeNgine
//
//  Created by Andrii Zinoviev on 12.04.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation
public protocol PXEntity: AnyObject {
    var pos: PXv2f { get set }
    var dimensions: PXv2f { get }
    var name: String { get }
    var visible: Bool { get }
    var outOfBoundsDiscardable: Bool { get }
}

public extension PXEntity {
    var center: PXv2f {
        get {
            pos + 0.5 * dimensions
        }
        set {
            pos = newValue - 0.5 * dimensions
        }
    }
    var width: Float {
        dimensions.x
    }
    var height: Float {
        dimensions.y
    }

    var rect: PXRect {
        PXRect(
            x1: pos.x,
            y1: pos.y,
            x2: pos.x + width,
            y2: pos.y + height)
    }

    func isInside(point: PXv2f) -> Bool {
        return pos.x <= point.x && point.x <= pos.x + width &&
            pos.y <= point.y && point.y <= pos.y + height
    }
}

public protocol PXUpdateableEntity: PXEntity {
    func onFrame()
}

public protocol PXDrawableEntity: PXEntity {
    var opacity: Float { get }
    var brightness: Float { get }
    var light: PXLight? { get }
    func draw(context: PXRendererContext)
}

public protocol PXSpritedEntity: PXDrawableEntity {
    var currentSprite: PXSprite? { get }
}

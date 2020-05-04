//
//  PXEntity.swift
//  PixeNgine
//
//  Created by Andrii Zinoviev on 12.04.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation

public enum PXRenderMode {
    case scene
    case hud
}

open class PXEntity {
    // Common fields
    public var pos: PXv2f = .zero
    public var name: String
    open var dimensions: PXv2f { .zero }
    public var shouldBeRemoved: Bool = false
    public var renderMode: PXRenderMode = .scene

    // Common methods
    open func update() {

    }
    open func draw(context: PXDrawContext) {

    }

    public init(name: String) {
        self.name = name
    }

    deinit {
        pxDebug("Entity \(name) deleted")
    }
}

public extension PXEntity {
    var center: PXv2f {
        get { pos + 0.5 * dimensions }
        set { pos = newValue - 0.5 * dimensions }
    }
    var width: Float { dimensions.x }
    var height: Float { dimensions.y }

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

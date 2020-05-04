//
//  PXCamera.swift
//  PixeNgine
//
//  Created by Andrii Zinoviev on 10.04.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation

// MARK: Basic static camera
public class PXCamera: PXEntity {
    // MARK: Conformance to PXEntity protocol
    public override var dimensions: PXv2f {
        cameraDimensions
    }

    public var cameraDimensions: PXv2f

    public init(dimensions: PXv2f) {
        self.cameraDimensions = dimensions
        super.init(name: "Camera")
    }
}


// MARK: Target follow camera

public class PXFollowCamera: PXCamera {
    public override func update() {
        super.update()
        if target.pos.x > pos.x + width - followBorder.x {
            pos.x = target.pos.x + followBorder.x - width
        }
        if target.pos.y > pos.y + height - followBorder.y {
            pos.y = target.pos.y + followBorder.y - height
        }
        if target.pos.x < pos.x + followBorder.x {
            pos.x = target.pos.x - followBorder.x
        }
        if target.pos.y < pos.y + followBorder.y {
            pos.y = target.pos.y - followBorder.y
        }
        pos.x = roundf(pos.x)
        pos.y = roundf(pos.y)
    }

    public var followBorder: PXv2f
    public var target: PXEntity
    public init(dimensions: PXv2f, followBorder: PXv2f, target: PXEntity) {
        self.followBorder = followBorder
        self.target = target
        super.init(dimensions: dimensions)
    }
}


// MARK: Misc camera methods
public extension PXCamera {
    var clipBounds: PXRect {
        PXRect(
            x1: pos.x,
            y1: pos.y,
            x2: pos.x + dimensions.x,
            y2: pos.y + dimensions.y)
    }

    struct PXCameraBgBounds {
        var x1, x2, y1, y2: Int
    }

    func onScreen(_ v: PXv2f) -> PXv2f {
        return v - pos
    }

    var backgroundBounds: PXCameraBgBounds {
        let cb = clipBounds
        return PXCameraBgBounds(
            x1: Int(floor(cb.x1 / Float(PXConfig.tileSize))),
            x2: Int(ceil(cb.x2 / Float(PXConfig.tileSize))),
            y1: Int(floor(cb.y1 / Float(PXConfig.tileSize))),
            y2: Int(ceil(cb.y2 / Float(PXConfig.tileSize))))
    }

    func isEntityVisible(_ entity: PXEntity) -> Bool {
        let xy = entity.pos
        let dim = entity.dimensions
        let clip = clipBounds
        return (xy.x + dim.x >= clip.x1 &&
            xy.y + dim.y >= clip.y1 &&
            xy.x <= clip.x2 &&
            xy.y <= clip.y2)
    }

    var projectionMatrix: float4x4 {
        return Matrices.ortho(
            l: clipBounds.x1,
            r: clipBounds.x2,
            t: clipBounds.y1,
            b: clipBounds.y2,
            f: 0.0,
            n: 2.0)
    }
}

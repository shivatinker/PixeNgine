//
//  PXStaticSprite.swift
//  PixeNgine
//
//  Created by Andrii Zinoviev on 02.05.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation

public class PXSpriteDrawable: PXDrawable {
    public var dimensions: PXv2f {
        Float(scale) * (sprite?.dimensions ?? .zero)
    }
    public var visible: Bool = true
    public var opacity: Float = 1.0
    public var brightness: Float = 1.0
    public var scale: Int = 1
    public var sprite: PXSprite?

    public func draw(entity: PXEntity, context: PXDrawContext) {
        if let s = sprite {
            let params = PXDrawParams(opacity: opacity, brightness: brightness, scale: Float(scale))
            context.drawSprite(sprite: s, worldPos: entity.pos, params: params)
        }
    }
    public init() {

    }
}

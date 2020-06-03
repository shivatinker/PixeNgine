//
//  PXTile.swift
//  PixeNgine
//
//  Created by Andrii Zinoviev on 09.04.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation

public class PXTileDrawable: PXDrawable {
    public typealias Parent = PXTile
    // TODO: Move sprite loading to component
    public var visible: Bool = true
    public var opacity: Float = 1.0
    public var brightness: Float = 1.0

    public var sprite: PXSprite?

    public func draw(entity: Parent, context: PXDrawContext) {
        if visible, let sprite = sprite {
            if entity.physics?.solid ?? false{
                brightness = 0.3
            } else {
                brightness = 1.0
            }
            let params = PXDrawParams(opacity: opacity, brightness: brightness, scale: 1)
            context.drawSprite(sprite: sprite, worldPos: entity.pos, params: params)
        }
    }
}

public class PXTile: PXEntity {
    public override var dimensions: PXv2f {
        Float(PXConfig.tileSize) * .ones
    }

    public override func draw(context: PXDrawContext) {
        drawable.draw(entity: self, context: context)
    }

    // MARK: Components
    public var drawable = PXTileDrawable()

    // MARK: State fields
    private let descriptor: PXTileDescriptor

    public init?(id: Int) {
        // Get tile descriptor from resources
        guard let descriptor = PXConfig.resourceManager.tileDescriptors[id] else {
            pxDebug("No such TileID: \(id)")
            return nil
        }
        self.descriptor = descriptor
        super.init(name: descriptor.name)

        physics = PXPhysics(shape: .rect(
            width: Float(PXConfig.tileSize),
            height: Float(PXConfig.tileSize)
        ))
        physics?.solid = false

        // Load static sprite
        let texture = PXConfig.sharedTextureManager.getTextureByID(id: descriptor.texture)
        let sprite = PXSprite(texture: texture)
        drawable.sprite = sprite
    }
}

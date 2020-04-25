//
//  PXTile.swift
//  PixeNgine
//
//  Created by Andrii Zinoviev on 09.04.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation

public class PXTile: PXStaticSprite {


    private let descriptor: PXTileDescriptor

    public init?(id: Int) {
        guard let descriptor = PXConfig.resourceManager.tileDescriptors[id] else {
            pxDebug("No such TileID: \(id)")
            return nil
        }
        self.descriptor = descriptor
        super.init(name: descriptor.name)
        let texture = PXConfig.sharedTextureManager.getTextureByID(id: descriptor.texture)
        animator.currentSprite = PXSprite(texture: texture)

//        guard dimensions == Float(PXConfig.TILE_SIZE) * .ones else {
//            pxDebug("Tile texture \(name) has invalid size")
//            return nil
//        }
    }
}

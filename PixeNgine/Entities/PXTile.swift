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
    public var solid: Bool = false
    public override var brightness: Float {
        if solid {
            return 0.4
        } else {
            return 1.0
        }
    }

    public init?(id: Int) {
        guard let descriptor = PXConfig.resourceManager.tileDescriptors[id] else {
            pxDebug("No such TileID: \(id)")
            return nil
        }
        self.descriptor = descriptor
        super.init(name: descriptor.name)
        let texture = PXConfig.sharedTextureManager.getTextureByID(id: descriptor.texture)
        animator.currentSprite = PXSprite(texture: texture)
    }
}

//
//  PXSprite.swift
//  PixeNgine
//
//  Created by Andrii Zinoviev on 14.04.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation

public struct PXSprite {
    public init(texture: PXTexture) {
        self.texture = texture
    }

    public var texture: PXTexture

    public var dimensions: PXv2f {
        PXv2f(Float(texture.texture.width) * texture.uvBounds.width, Float(texture.texture.height) * texture.uvBounds.height)
    }
}

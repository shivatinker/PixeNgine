//
//  PXStaticSprite.swift
//  PixeNgine
//
//  Created by Andrii Zinoviev on 04.05.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation

public class PXStaticSprite: PXEntity {
    public override var dimensions: PXv2f {
        drawable.dimensions
    }

    public var drawable = PXSpriteDrawable()

    public override func draw(context: PXDrawContext) {
        drawable.draw(entity: self, context: context)
    }

    public init(name: String, sprite: PXSprite) {
        super.init(name: name)
        drawable.sprite = sprite
    }
}

//
//  PXStaticSprite.swift
//  PixeNgine
//
//  Created by Andrii Zinoviev on 24.04.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation

public class PXStaticAnimator: PXAnimator {
    public var currentSprite: PXSprite?
}

extension PXStaticSprite: PXDrawableEntity {
    public func draw(context: PXRendererContext) {
        renderer.draw(context: context)
    }
}

open class PXStaticSprite: PXSpritedEntity {
    // MARK: Conformance to PXSpritedEntity protocol
    public let name: String
    public var pos: PXv2f = .zero
    public var dimensions: PXv2f {
        animator.currentSprite?.dimensions ?? PXv2f.zero
    }
    public var currentSprite: PXSprite? {
        animator.currentSprite
    }
    public var visible: Bool = true

    // MARK: Components

    public var animator = PXStaticAnimator()
    public var renderer = PXSpriteRenderer()

    public init(name: String) {
        self.name = name
        renderer.parent = self
    }
}

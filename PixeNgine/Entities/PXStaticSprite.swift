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
        Float(scale) * (animator.currentSprite?.dimensions ?? PXv2f.zero)
    }
    public var currentSprite: PXSprite? {
        animator.currentSprite
    }
    open var visible: Bool = true
    open var outOfBoundsDiscardable: Bool { false }
    open var opacity: Float { 1.0 }
    open var brightness: Float { 1.0 }

    // MARK: Components

    public var animator = PXStaticAnimator()
    public var renderer = PXSpriteRenderer()

    public var scale: Int = 1

    public init(name: String) {
        self.name = name
        renderer.parent = self
    }
}

//
//  PXText.swift
//  PixeNgine
//
//  Created by Andrii Zinoviev on 29.04.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation

public class PXTextDrawable: PXDrawable {
    public typealias Parent = PXText

    public var visible: Bool = true
    public var opacity: Float = 1.0
    public var brightness: Float = 1.0
    public var scale: Float = 1

    public func dimensionsOf(entity: Parent) -> PXv2f {
        return PXv2f(entity.font.getTextWidth(entity.text), entity.font.height)
    }

    public func draw(entity: Parent, context: PXDrawContext) {
        if visible {
            let params = PXDrawParams(opacity: opacity, brightness: brightness, scale: scale)
            context.drawText(text: entity.text, font: entity.font, worldPos: entity.pos, params: params)
        }
    }
}

public class PXText: PXEntity {
    // MARK: Conformance to PXEntity
    public override var dimensions: PXv2f {
        drawable.dimensionsOf(entity: self)
    }

    public override func draw(context: PXDrawContext) {
        drawable.draw(entity: self, context: context)
    }

    // MARK: Components
    public var drawable = PXTextDrawable()

    // MARK: State fields
    public var text: String
    public var font: PXFont = PXConfig.fontManager.getFontById("gamer")

    public init(text: String) {
        self.text = text
        super.init(name: text)
    }
}

private extension ClosedRange {
    func clamp(_ value : Bound) -> Bound {
        return self.lowerBound > value ? self.lowerBound
            : self.upperBound < value ? self.upperBound
            : value
    }
}

public class PXBlobText: PXText {
    private var speed: Float = 1
    private var maxY: Float = 0
    private var initialPos: PXv2f!
    public override func update() {
        pos = pos + PXv2f(0, -speed)
        let op: Float = 1.0 - (-pos.y + initialPos.y) / (initialPos.y - maxY)
        drawable.opacity = (0.0...1.0).clamp(op)
        if pos.y < maxY {
            shouldBeRemoved = true
        }
    }
    public init(text: String, pos: PXv2f, height: Float) {
        super.init(text: text)
        self.pos = pos
        self.maxY = self.pos.y - height
        self.initialPos = pos
        renderMode = .hud
    }
}

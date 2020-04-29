//
//  PXText.swift
//  PixeNgine
//
//  Created by Andrii Zinoviev on 29.04.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation

public class PXText: PXEntity, PXDrawableEntity {
    public var opacity: Float = 1.0

    public var brightness: Float = 1.0

    public var light: PXLight?

    private var renderer = PXTextRenderer()
    public func draw(context: PXRendererContext) {
        renderer.draw(context: context)
    }

    public var pos: PXv2f = .zero
    public var dimensions: PXv2f {
        PXv2f(font.getTextWidth(text), font.height)
    }
    public var name: String {
        "Text: \(text)"
    }
    public var visible: Bool = true
    public var outOfBoundsDiscardable: Bool = false

    public var text: String
    public var font: PXFont = PXConfig.fontManager.getFontById("arcade")

    public init(text: String) {
        self.text = text
        renderer.parent = self
    }
}

//
//  PXFont.swift
//  PixeNgine
//
//  Created by Andrii Zinoviev on 29.04.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation
import Metal

public struct PXFont {
    public let id: String
    public let texture: MTLTexture
    public let chars: [Character: PXFontChar]
    public let height: Float

    public func getChar(_ c: Character) -> PXFontChar {
        return chars[c] ?? (chars["0"]!)
    }

    public struct PXFontChar {
        public let uv: PXRect
        public let width: Float
        public let code: Character
    }

    public func getTextWidth(_ text: String) -> Float {
        var r: Float = 0.0
        for c in text {
            r += getChar(c).width
        }
        return r
    }
}

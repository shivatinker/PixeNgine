//
//  PXTexture.swift
//  PixeNgine
//
//  Created by Andrii Zinoviev on 10.04.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation
import Metal

public struct PXTexture {
    var id: String
    var texture: MTLTexture
    var uvBounds: PXRect
}

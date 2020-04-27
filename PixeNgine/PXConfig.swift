//
//  PXConfig.swift
//  PixeNgine
//
//  Created by Andrii Zinoviev on 10.04.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation
import Metal

public class PXConfig {
    public static let tileSize = 16
    public static let texturePixelFormat: MTLPixelFormat = .bgra8Unorm_srgb
    public static let framebufferPixelFormat: MTLPixelFormat = .bgra8Unorm_srgb
    public static let device = MTLCreateSystemDefaultDevice()!
    private static var _defaulttm = PXTextureManager()
    public static var sharedTextureManager: PXTextureManager {
        _defaulttm
    }
    private static var _defaultrm = PXResourceManager()
    public static var resourceManager: PXResourceManager {
        _defaultrm
    }
}

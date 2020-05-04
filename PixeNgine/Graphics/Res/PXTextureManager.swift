//
//  PXTextureManager.swift
//  PixeNgine
//
//  Created by Andrii Zinoviev on 10.04.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation
import Metal
import MetalKit

public class PXTextureManager {
    
    internal init(){
        
    }
    
    private let device = PXConfig.device
    private var textureCache = [String: PXTexture]()
    private let fileManager = FileManager.default
    private let decoder = JSONDecoder()

    public func getTextureByID(id: String) -> PXTexture{
        return textureCache[id] ?? (textureCache["invalid"]!)
    }
    
    public func loadAllTextures(path: URL, recursively: Bool = true) throws {
        let filenames = try fileManager.contentsOfDirectory(at: path, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        let textureJsonURLs = filenames.filter({ $0.lastPathComponent.contains(".pxatlas")})
//        pxDebug("Found \(textureDescriptors.count) textures: \(textureDescriptors)")
        for textureJsonURL in textureJsonURLs {
            let textureMapInfo = try decoder.decode(TextureMapInfo.self, from: Data(contentsOf: textureJsonURL))
            let loadedTexture = try MTKTextureLoader(device: device).newTexture(data: Data(contentsOf: path.appendingPathComponent(textureMapInfo.filename)))
            let w: Float = Float(loadedTexture.width)
            let h: Float = Float(loadedTexture.height)
            for textureInfo in textureMapInfo.textures {
                textureCache[textureInfo.id] = PXTexture(
                    id: textureInfo.id,
                    texture: loadedTexture,
                    uvBounds: PXRect(
                        x1: Float(textureInfo.x) / w + 1e-6,
                        y1: Float(textureInfo.y) / h,
                        x2: Float(textureInfo.x + textureInfo.width) / w,
                        y2: Float(textureInfo.y + textureInfo.height) / h))
            }
        }
        pxDebug("Loaded textures: \(textureCache.keys)")
    }

    private struct TextureInfo: Decodable {
        var id: String
        var x, y, width, height: Int
    }

    private struct TextureMapInfo: Decodable {
        var filename: String
        var textures: [TextureInfo]
    }
}

extension URL {
    var isDirectory: Bool {
        return (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
    var subDirectories: [URL] {
        guard isDirectory else { return [] }
        return (try? FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]).filter { $0.isDirectory }) ?? []
    }
}

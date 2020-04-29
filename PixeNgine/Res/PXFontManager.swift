//
//  PXFontManager.swift
//  PixeNgine
//
//  Created by Andrii Zinoviev on 29.04.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation
import Metal
import MetalKit

public class PXFontManager {
    internal init() {

    }

    private let device = PXConfig.device
    private var fontCache = [String: PXFont]()
    private let fileManager = FileManager.default
    private let decoder = JSONDecoder()

    private func replaceExtension(_ url: URL, _ newExtension: String) -> URL {
        // TODO: Do it better :)
        return url.deletingLastPathComponent().appendingPathComponent(url.lastPathComponent.split(separator: ".").first!.appending(newExtension))
    }

    private func stringToUVRect(_ s: String, textureSize: PXv2f) -> PXRect? {
        let coords = s.split(separator: " ")
        return PXRect(x1: Float(coords[0])! / textureSize.x,
                      y1: Float(coords[1])! / textureSize.y,
                      x2: Float(coords[0])! / textureSize.x + Float(coords[2])! / textureSize.x,
                      y2: Float(coords[1])! / textureSize.y + Float(coords[3])! / textureSize.y)
    }

    public func getFontById(_ id: String) -> PXFont {
        return fontCache[id]!
    }

    public func loadAllFonts(path: URL) throws {
        let filenames = try fileManager.contentsOfDirectory(at: path, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        let infoURLs = filenames.filter({ $0.lastPathComponent.contains(".font") })
        for infoURL in infoURLs {
            let fontInfo = try decoder.decode(FontInfo.self, from: Data(contentsOf: infoURL))
            let loadedTexture = try MTKTextureLoader(device: device).newTexture(data: Data(contentsOf: replaceExtension(infoURL, ".png")))

            let w: Float = Float(loadedTexture.width)
            let h: Float = Float(loadedTexture.height)

            let fontId = String(infoURL.lastPathComponent.split(separator: ".").first!)
            var chars = [Character: PXFont.PXFontChar]()
            for charInfo in fontInfo.chars {
                let code = charInfo.code.first!
                chars[code] = PXFont.PXFontChar(
                    uv: stringToUVRect(charInfo.rect,
                                       textureSize: PXv2f(w, h))!,
                    width: Float(charInfo.width)!,
                    code: code)
            }
            fontCache[fontId] = PXFont(id: fontId, texture: loadedTexture, chars: chars, height: Float(fontInfo.height)!)
        }
        pxDebug("Loaded fonts: \(fontCache.keys)")
    }
}

private struct FontInfo: Decodable {
    let size: String
    let family: String
    let height: String
    let style: String
    let chars: [CharInfo]
}

private struct CharInfo: Decodable {
    let width: String
    let offset: String
    let rect: String
    let code: String
}

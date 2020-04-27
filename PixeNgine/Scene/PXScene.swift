//
//  PXScene.swift
//  PixeNgine
//
//  Created by Andrii Zinoviev on 12.04.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation
import Metal
import MetalKit

public class PXScene {

    // MARK: Private members
    private var nextID = 0

    private var updateable = [Int: PXUpdateableEntity]()
    private var entities = [Int: PXEntity]()
    private var hud = [Int: PXEntity]()
    private var lights = [Int: PXLight]()


    private struct TileXY: Hashable {
        var x, y: Int
    }
    private var background = [TileXY: PXTile?]()

    // MARK: Public API

    public var width: Int
    public var height: Int
    public var bounds: PXRect {
        PXRect(
            x1: 0,
            y1: 0,
            x2: Float(width * PXConfig.tileSize),
            y2: Float(height * PXConfig.tileSize))
    }
    public var camera: PXCamera?
    public var hudCamera: PXCamera?

    public func addEntity(_ entity: PXEntity) {
        entities[nextID] = entity
        if let u = entity as? PXUpdateableEntity {
            updateable[nextID] = u
        }
        nextID += 1
    }

    public func addHudEntity(_ entity: PXEntity) {
        hud[nextID] = entity
//        if let u = entity as? PXUpdateableEntity {
//            updateable[nextID] = u
//        }
        nextID += 1
    }

    public func addLight(_ light: PXLight) {
        lights[nextID] = light
        nextID += 1
    }

    public func setBackgroundTile(x: Int, y: Int, tile: PXTile) {
        tile.pos = Float(PXConfig.tileSize) * PXv2f(Float(x), Float(y))
        background[TileXY(x: x, y: y)] = tile
    }

    public func getBackgroundTile(x: Int, y: Int) -> PXTile? {
        return background[TileXY(x: x, y: y)] ?? nil
    }

    public func borderTiles(entity: PXEntity) -> [(x: Int, y: Int)] {
        let border = PXRect(
            x1: floorf(entity.rect.x1 / Float(PXConfig.tileSize)),
            y1: floorf(entity.rect.y1 / Float(PXConfig.tileSize)),
            x2: floorf(entity.rect.x2 / Float(PXConfig.tileSize)),
            y2: floorf(entity.rect.y2 / Float(PXConfig.tileSize)))
        var res = [(Int, Int)]()
        for x in Int(border.x1)...Int(border.x2) {
            if x == Int(border.x1) || x == Int(border.x2) {
                for y in Int(border.y1)...Int(border.y2) {
                    res.append((x, y))
                }
            } else {
                res.append((x, Int(border.y1)))
                res.append((x, Int(border.y2)))
            }
        }
        return res
    }

    public init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }

    public func updateScene() {
        for u in updateable.values {
            u.onFrame()
        }

        var outOfBounds = Set<Int>()
        for kv in entities {
            if kv.value.outOfBoundsDiscardable && !bounds.isInside(kv.value.pos) {
                outOfBounds.insert(kv.key)
            }
        }

        outOfBounds.forEach({ entities.removeValue(forKey: $0) })
        outOfBounds.forEach({ updateable.removeValue(forKey: $0) })
//        print("\(entities.count) entities.")
    }

    

    public func renderLights(encoder: MTLRenderCommandEncoder) {
        // Lighting pass

        if let camera = camera {
            let context = PXRendererContext(encoder: encoder, camera: camera)
            let r = PXLightRenderer()
            r.draw(context: context, lights: lights.values.map({ $0 }))
        }
    }

    public func renderScene(encoder: MTLRenderCommandEncoder) {
        if let camera = camera {
            let context = PXRendererContext(encoder: encoder, camera: camera)

            //Optimized background rendering
            let bgBounds = camera.backgroundBounds
            for x in bgBounds.x1...bgBounds.x2 {
                for y in bgBounds.y1...bgBounds.y2 {
                    background[TileXY(x: x, y: y)]??.draw(context: context)
                }
            }
            //Entities rendering
            for e in entities.values {
                if let d = e as? PXDrawableEntity,
                    d.visible {
                    d.draw(context: context)
                }
            }
        }

        if let hudCamera = hudCamera {
            //HUD renddering
            let hudContext = PXRendererContext(encoder: encoder, camera: hudCamera)
            for e in hud.values {
                if let d = e as? PXDrawableEntity,
                    d.visible {
                    d.draw(context: hudContext)
                }
            }
        }
    }
}

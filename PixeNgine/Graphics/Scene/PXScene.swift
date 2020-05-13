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
    private let device = PXConfig.device

    private var sceneEntities = [Int]()
    private var hud = [Int]()

    private var entities = [Int: PXEntity]()

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
        sceneEntities.append(nextID)
        nextID += 1
        entity.subentities.forEach({ self.addEntity($0) })
    }

    public func addHudEntity(_ entity: PXEntity) {
        entities[nextID] = entity
        hud.append(nextID)
        nextID += 1
        entity.subentities.forEach({ self.addHudEntity($0) })
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

    private func removeEntity(_ id: Int) {
        entities.removeValue(forKey: id)
        sceneEntities.removeAll(where: { $0 == id })
        hud.removeAll(where: { $0 == id })
    }

    public func updateScene() {
//        debugPrint("Count: \(entities.count)")
        entities.values.forEach({ $0.update() })
        let shouldBeRemoved = entities.compactMap({ kv -> Int? in
            if kv.value.shouldBeRemoved || !bounds.isInside(kv.value.center){
                return kv.key
            }
            return nil
        })
        if !shouldBeRemoved.isEmpty {
            shouldBeRemoved.forEach({ entities[$0] = nil })
        }
    }

    public func renderLights(encoder: MTLRenderCommandEncoder) {
        // Lighting pass
        if let camera = camera {
            let context = PXDrawContext(device: device, encoder: encoder, camera: camera)
            context.drawLights(
                ambientColor: PXColor(r: 0.1, g: 0.1, b: 0.1, a: 1.0),
                lights: entities.values.compactMap({ $0 as? PXLight }))
        }
    }

    public func renderScene(encoder: MTLRenderCommandEncoder) {
        if let camera = camera {
            let context = PXDrawContext(device: device, encoder: encoder, camera: camera)

            //Optimized background rendering
            let bgBounds = camera.backgroundBounds
            for x in bgBounds.x1...bgBounds.x2 {
                for y in bgBounds.y1...bgBounds.y2 {
                    background[TileXY(x: x, y: y)]??.draw(context: context)
                }
            }
            //Entities rendering
            sceneEntities.forEach({
                if let e = entities[$0],
                    e.renderMode == .scene {
                    e.draw(context: context)
                }
            })
        }
    }

    public func renderOverlays(encoder: MTLRenderCommandEncoder) {
        if let hudCamera = hudCamera,
            let camera = camera {
            //HUD renddering
            let sceneHudContext = PXDrawContext(device: device, encoder: encoder, camera: camera)
            sceneEntities.forEach({
                if let e = entities[$0],
                    e.renderMode == .hud {
                    e.draw(context: sceneHudContext)
                }
            })
            let hudContext = PXDrawContext(device: device, encoder: encoder, camera: hudCamera)
            hud.forEach({
                if let e = entities[$0] {
                    e.draw(context: hudContext)
                }
            })
        }
    }
}

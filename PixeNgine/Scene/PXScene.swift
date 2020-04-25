//
//  PXScene.swift
//  PixeNgine
//
//  Created by Andrii Zinoviev on 12.04.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation
import Metal

public class PXScene {

    // MARK: Private members
    private var nextID = 0

    private var updateable = [PXUpdateableEntity]()
    private var entities = [Int: PXEntity]()
    private var hud = [PXEntity]()


    private struct TileXY: Hashable {
        var x, y: Int
    }
    private var background = [TileXY: PXTile?]()

    // MARK: Public API

    public var width: Int
    public var height: Int
    public var camera: PXCamera?
    public var hudCamera: PXCamera?

    public func addEntity(_ entity: PXEntity) {
        entities[nextID] = entity
        nextID += 1
        if let u = entity as? PXUpdateableEntity {
            updateable.append(u)
        }
    }

    public func addHudEntity(_ entity: PXEntity) {
        hud.append(entity)
        if let u = entity as? PXUpdateableEntity {
            updateable.append(u)
        }
    }

    public func setBackgroundTile(x: Int, y: Int, tile: PXTile) {
        tile.pos = Float(PXConfig.TILE_SIZE) * PXv2f(Float(x), Float(y))
        background[TileXY(x: x, y: y)] = tile
    }

    public init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }

    public func updateScene() {
        for u in updateable {
            u.onFrame()
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
                    d.visible{
                    d.draw(context: context)
                }
            }
        }

        if let hudCamera = hudCamera {
            //HUD renddering
            let hudContext = PXRendererContext(encoder: encoder, camera: hudCamera)
            for e in hud {
                if let d = e as? PXDrawableEntity,
                    d.visible {
                    d.draw(context: hudContext)
                }
            }
        }
    }
}

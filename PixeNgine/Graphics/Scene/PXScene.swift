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

    private var grid = [TileXY: Set<Int>]()

    private func removeEntity(_ id: Int) {

        entities.removeValue(forKey: id)
        sceneEntities.removeAll(where: { $0 == id })
        hud.removeAll(where: { $0 == id })
    }

    // Some misc methods

    private let gridSize: Float = 16

    private func getEntityCells(_ e: PXEntity) -> Set<TileXY> {
        if e.physics == nil {
            return []
        }
        var res = Set<TileXY>()
        let phrect = PXCollider.aabb(e)
        for x in Int(floor(phrect.x1 / gridSize))...Int(ceil(phrect.x2 / gridSize)) {
            for y in Int(floor(phrect.y1 / gridSize))...Int(ceil(phrect.y2 / gridSize)) {
                res.insert(TileXY(x: x, y: y))
            }
        }
        return res
    }

    private func getEntityCollisionCandidates(_ e: PXEntity) -> Set<Int> {
        if e.physics == nil {
            return []
        }

        var res = Set<Int>()
        let cells = getEntityCells(e)
        for c in cells {
            for z in grid[c] ?? [] {
                res.insert(z)
            }
        }
        return res
    }

    private func insertEntityInGrid(_ id: Int) {
        if let e = entities[id] {
            getEntityCells(e).forEach({

                if self.grid[$0] == nil {
                    self.grid[$0] = Set<Int>()
                }

                self.grid[$0]!.insert(id)

            })
        }
    }

    private func updateGrid() {
        grid.removeAll()
        for i in sceneEntities {
            insertEntityInGrid(i)
        }
    }

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
        insertEntityInGrid(nextID)
        nextID += 1
        entity.subentities.forEach({ self.addEntity($0) })
    }

    public func addHudEntity(_ entity: PXEntity) {
        entities[nextID] = entity
        hud.append(nextID)
        nextID += 1
        entity.subentities.forEach({ self.addHudEntity($0) })
    }

    public func setBackgroundTile(x: Int, y: Int, tile: PXTile, solid: Bool) {
        tile.pos = Float(PXConfig.tileSize) * PXv2f(Float(x), Float(y))
        background[TileXY(x: x, y: y)] = tile
        if solid {
            tile.physics?.solid = true
            tile.physics?.hardness = 2

            if background[TileXY(x: x + 1, y: y)]??.physics?.solid ?? false {
                background[TileXY(x: x + 1, y: y)]??.physics?.incomingCollisions.remove(.left)
                tile.physics?.incomingCollisions.subtract(.right)
            }

            if background[TileXY(x: x - 1, y: y)]??.physics?.solid ?? false {
                background[TileXY(x: x - 1, y: y)]??.physics?.incomingCollisions.remove(.right)
                tile.physics?.incomingCollisions.subtract(.left)
            }

            if background[TileXY(x: x + 0, y: y + 1)]??.physics?.solid ?? false {
                background[TileXY(x: x + 0, y: y + 1)]??.physics?.incomingCollisions.remove(.top)
                tile.physics?.incomingCollisions.subtract(.bottom)
            }

            if background[TileXY(x: x - 0, y: y - 1)]??.physics?.solid ?? false {
                background[TileXY(x: x - 0, y: y - 1)]??.physics?.incomingCollisions.remove(.bottom)
                tile.physics?.incomingCollisions.subtract(.top)
            }

            addEntity(tile)
        }
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

    public var paused = false

    public func updateScene() {
//        debugPrint("Count: \(entities.count)")
        if(paused) {
            return
        }

        entities.values.forEach({ $0.update() })

        updateGrid()

        let dyn = sceneEntities.compactMap({ entities[$0] }).filter({ $0.physics?.dynamic ?? false })

        for d in dyn {
            let cc = getEntityCollisionCandidates(d).compactMap({ entities[$0] })
            for s in cc {
                if d.id != s.id &&
                    PXCollider.isColliding(d, s)
                    && !d.shouldBeRemoved && !s.shouldBeRemoved {
                    let vec = PXCollider.getResolveVector(d, s)
                    if (d.physics!.hardness < s.physics!.hardness) {
                        d.pos = d.pos + (1 * vec)
                    }
                    let norm = vec.normalize()
                    d.physics?.delegate?.onCollisionResolved(entity: d, with: s, normal: norm)
                    s.physics?.delegate?.onCollisionResolved(entity: s, with: d, normal: -1 * norm)
                }
            }
        }

        let shouldBeRemoved = entities.compactMap({ kv -> Int? in
            if kv.value.shouldBeRemoved || !bounds.isInside(kv.value.center) {
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
                ambientColor: PXColor(r: 0.3, g: 0.3, b: 0.3, a: 1.0),
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

//
//  PXSpriteRenderer.swift
//  PixeNgine
//
//  Created by Andrii Zinoviev on 24.04.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation

public class PXSpriteRenderer: PXEntityRenderer {
    public weak var parent: PXSpritedEntity?

    private var vertexData: [Float] { [
        0.0, 0.0, 0.0,
        0.0, 1.0, 0.0,
        1.0, 0.0, 0.0,
        1.0, 1.0, 0.0]
    }

    public func draw(context: PXRendererContext) {
        guard let parent = parent else {
            pxDebug("Failed to access parent entity. No draw will be performed")
            return
        }
        guard context.camera.isEntityVisible(parent),
            let sprite = parent.currentSprite else {
                return
        }

        let encoder = context.encoder
        let camera = context.camera
        let texture = sprite.texture

        encoder.pushDebugGroup("Draw sprite \(texture.id)")
        defer { encoder.popDebugGroup() }

        encoder.setRenderPipelineState(PXCache.getPipeline(PXSpritePipeline.self)!)


        var uniforms = Uniforms()
        uniforms.modelViewMatrix = Matrices.transform(
            moveX: roundf(parent.pos.x),
            moveY: roundf(parent.pos.y),
            moveZ: 0.0,
            scaleX: parent.dimensions.x,
            scaleY: parent.dimensions.y)
        uniforms.projectionMatrix = camera.projectionMatrix
        uniforms.opacity = parent.opacity
        uniforms.brightness = parent.brightness

        encoder.setVertexBytes(vertexData, length: MemoryLayout.size(ofValue: vertexData[0]) * vertexData.count, index: VertexAttribute.position.rawValue)

        let texcoordData: [Float] = [
            texture.uvBounds.x1, texture.uvBounds.y1,
            texture.uvBounds.x1, texture.uvBounds.y2,
            texture.uvBounds.x2, texture.uvBounds.y1,
            texture.uvBounds.x2, texture.uvBounds.y2]
        encoder.setVertexBytes(texcoordData, length: MemoryLayout.size(ofValue: texcoordData[0]) * texcoordData.count, index: VertexAttribute.texcoord.rawValue)
        encoder.setVertexBytes(&uniforms, length: MemoryLayout.size(ofValue: uniforms), index: VertexAttribute.uniforms.rawValue)
        encoder.setFragmentBytes(&uniforms, length: MemoryLayout.size(ofValue: uniforms), index: VertexAttribute.uniforms.rawValue)

        encoder.setFragmentTexture(texture.texture, index: TextureIndex.color.rawValue)

        encoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: vertexData.count / 3)
    }
}

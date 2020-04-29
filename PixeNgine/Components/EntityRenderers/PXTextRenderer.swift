//
//  PXTextRenderer.swift
//  PixeNgine
//
//  Created by Andrii Zinoviev on 29.04.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation

public class PXTextRenderer: PXEntityRenderer {
    public weak var parent: PXText?

    public func draw(context: PXRendererContext) {
        guard let parent = parent else {
            pxDebug("Failed to access parent entity. No draw will be performed")
            return
        }
        guard context.camera.isEntityVisible(parent) else {
            return
        }

        let encoder = context.encoder
        let camera = context.camera
        let texture = parent.font.texture

        encoder.pushDebugGroup("Draw text \(parent.text)")
        defer { encoder.popDebugGroup() }

        encoder.setRenderPipelineState(PXCache.getPipeline(PXSpritePipeline.self)!)

        var vertexData = [Float]()
        var texcoordData = [Float]()

        var curx: Float = 0
        for sc in parent.text {
            let h = parent.font.height
            let c = parent.font.getChar(sc)
            let w = c.width

            let currentQuad: [Float] = [
                curx, 0, 0,
                curx, h, 0,
                curx + w, 0, 0,
                curx, h, 0,
                curx + w, 0, 0,
                curx + w, h, 0
            ]

            let charUV = c.uv
            let currentUV: [Float] = [
                charUV.x1, charUV.y1,
                charUV.x1, charUV.y2,
                charUV.x2, charUV.y1,
                charUV.x1, charUV.y2,
                charUV.x2, charUV.y1,
                charUV.x2, charUV.y2
            ]

            curx += w + 2

            vertexData.append(contentsOf: currentQuad)
            texcoordData.append(contentsOf: currentUV)
        }

        var uniforms = Uniforms()
        uniforms.modelViewMatrix = Matrices.transform(
            moveX: roundf(parent.pos.x),
            moveY: roundf(parent.pos.y),
            moveZ: 0.0,
            scaleX: 1.0,
            scaleY: 1.0)
        uniforms.projectionMatrix = camera.projectionMatrix
        uniforms.opacity = parent.opacity
        uniforms.brightness = parent.brightness

        encoder.setVertexBytes(vertexData, length: MemoryLayout.size(ofValue: vertexData[0]) * vertexData.count, index: VertexAttribute.position.rawValue)

        encoder.setVertexBytes(texcoordData, length: MemoryLayout.size(ofValue: texcoordData[0]) * texcoordData.count, index: VertexAttribute.texcoord.rawValue)
        encoder.setVertexBytes(&uniforms, length: MemoryLayout.size(ofValue: uniforms), index: VertexAttribute.uniforms.rawValue)
        encoder.setFragmentBytes(&uniforms, length: MemoryLayout.size(ofValue: uniforms), index: VertexAttribute.uniforms.rawValue)

        encoder.setFragmentTexture(texture, index: TextureIndex.color.rawValue)

        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexData.count / 3)
    }
}

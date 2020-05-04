//
//  PXDrawContext.swift
//  PixeNgine
//
//  Created by Andrii Zinoviev on 02.05.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation
import Metal

public struct PXDrawParams {
    public var opacity: Float
    public var brightness: Float
    public var scale: Float

    public static var defaultParams: PXDrawParams {
        PXDrawParams(opacity: 1.0, brightness: 1.0, scale: 1)
    }
}

// Struct that represents some context, that can draw things
public struct PXDrawContext {
    public var encoder: MTLRenderCommandEncoder
    public var camera: PXCamera

    // Pixel-perfect model-view matrix (model to world)
    private func getPPModelViewMatrix(pos: PXv2f, dimensions: PXv2f, scale: Float) -> float4x4 {
        return Matrices.transform(
            moveX: roundf(pos.x),
            moveY: roundf(pos.y),
            moveZ: 0.0,
            scaleX: dimensions.x * Float(scale),
            scaleY: dimensions.y * Float(scale))
    }

    private func getTextMesh(text: String, font: PXFont) -> (vectices: [Float], texcoords: [Float]) {
        var vertexData = [Float]()
        var texcoordData = [Float]()

        var curx: Float = 0
        for sc in text {
            let h = font.height
            let c = font.getChar(sc)
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

        return (vertexData, texcoordData)
    }
}

public extension PXDrawContext {
    // MARK: Sprite drawing
    func drawSprite(sprite: PXSprite, worldPos: PXv2f, params: PXDrawParams = .defaultParams) {
        //        guard context.camera.isEntityVisible(entity),
        //            let sprite = animator.currentSprite else {
        //                return
        //        }

        let texture = sprite.texture

        encoder.pushDebugGroup("Draw sprite \(texture.id)")
        defer { encoder.popDebugGroup() }

        encoder.setRenderPipelineState(PXCache.getPipeline(PXBasicPipeline.self)!)

        var uniforms = Uniforms()
        uniforms.modelViewMatrix = getPPModelViewMatrix(pos: worldPos, dimensions: sprite.dimensions, scale: params.scale)
        uniforms.projectionMatrix = camera.projectionMatrix
        uniforms.opacity = params.opacity
        uniforms.brightness = params.brightness

        encoder.setTexturedQuadVertices(uv: texture.uvBounds)
        encoder.setVertexBytes(&uniforms, length: MemoryLayout.size(ofValue: uniforms), index: VertexAttribute.uniforms.rawValue)
        encoder.setFragmentBytes(&uniforms, length: MemoryLayout.size(ofValue: uniforms), index: VertexAttribute.uniforms.rawValue)
        encoder.setColorTexture(texture: texture.texture)
        encoder.drawQuad()
    }

    func drawText(text: String, font: PXFont, worldPos: PXv2f, params: PXDrawParams = .defaultParams) {
        encoder.pushDebugGroup("Draw text \(text)")
        defer { encoder.popDebugGroup() }

        encoder.setRenderPipelineState(PXCache.getPipeline(PXBasicPipeline.self)!)

        var uniforms = Uniforms()
        uniforms.modelViewMatrix = getPPModelViewMatrix(pos: worldPos, dimensions: .ones, scale: params.scale)
        uniforms.projectionMatrix = camera.projectionMatrix
        uniforms.opacity = params.opacity
        uniforms.brightness = params.brightness

        let (vertexData, texcoordData) = getTextMesh(text: text, font: font)
        encoder.setVertexBytes(vertexData, length: MemoryLayout.size(ofValue: vertexData[0]) * vertexData.count, index: VertexAttribute.position.rawValue)
        encoder.setVertexBytes(texcoordData, length: MemoryLayout.size(ofValue: texcoordData[0]) * texcoordData.count, index: VertexAttribute.texcoord.rawValue)
        encoder.setVertexBytes(&uniforms, length: MemoryLayout.size(ofValue: uniforms), index: VertexAttribute.uniforms.rawValue)
        encoder.setFragmentBytes(&uniforms, length: MemoryLayout.size(ofValue: uniforms), index: VertexAttribute.uniforms.rawValue)
        encoder.setFragmentTexture(font.texture, index: TextureIndex.color.rawValue)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexData.count / 3)
    }

    func drawLights(ambientColor: PXColor, lights: [PXLight]) {
        encoder.pushDebugGroup("Draw lights")
        defer { encoder.popDebugGroup() }

        encoder.setRenderPipelineState(PXCache.getPipeline(PXLightPipeline.self)!)

        var uniforms = LightsVertexUniforms()
        uniforms.modelViewMatrix = Matrices.transform(
            moveX: camera.pos.x,
            moveY: camera.pos.y,
            moveZ: 0.0,
            scaleX: camera.dimensions.x,
            scaleY: camera.dimensions.y)
        uniforms.projectionMatrix = camera.projectionMatrix

        encoder.setVertexBytes(&uniforms, length: MemoryLayout.size(ofValue: uniforms), index: BufferIndex.uniforms.rawValue)
        let vertexData = Meshes.screenQuad
        encoder.setVertexBytes(vertexData, length: MemoryLayout.size(ofValue: vertexData[0]) * vertexData.count, index: VertexAttribute.position.rawValue)

        var funiforms = LightsFragmentUniforms()
        funiforms.ambientColor = ambientColor.vec

        let lightBytes = lights.map({
            Light(pos: $0.center.vec, clipRadius: $0.radius, amount: $0.amount, color: $0.color.vec)
        })

        funiforms.lightsCount = Int32(lightBytes.count)

        // TODO: Create buffer instead of bytes
        encoder.setFragmentBytes(lightBytes, length: MemoryLayout<Light>.stride * lightBytes.count, index: LightsFragmentBuffers.lights.rawValue)

        encoder.setFragmentBytes(&funiforms, length: MemoryLayout.size(ofValue: funiforms), index: LightsFragmentBuffers.uniforms.rawValue)

        encoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: vertexData.count / 3)
    }
}

private extension MTLRenderCommandEncoder {
    func setTexturedQuadVertices(uv: PXRect) {
        setVertexBytes(Meshes.quad, length: MemoryLayout.size(ofValue: Meshes.quad[0]) * Meshes.quad.count, index: VertexAttribute.position.rawValue)

        let texcoordData: [Float] = [
            uv.x1, uv.y1,
            uv.x1, uv.y2,
            uv.x2, uv.y1,
            uv.x2, uv.y2]

        setVertexBytes(texcoordData, length: MemoryLayout.size(ofValue: texcoordData[0]) * texcoordData.count, index: VertexAttribute.texcoord.rawValue)
    }

    func drawQuad() {
        drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: Meshes.quad.count / 3)
    }

    func setColorTexture(texture: MTLTexture) {
        setFragmentTexture(texture, index: TextureIndex.color.rawValue)
    }
}

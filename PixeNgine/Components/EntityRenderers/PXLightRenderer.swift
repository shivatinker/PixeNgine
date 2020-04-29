//
//  PXLightRenderer.swift
//  PixeNgine
//
//  Created by Andrii Zinoviev on 26.04.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation

public class PXLightRenderer {


    private var vertexData: [Float] { [
        0.0, 0.0, 0.0,
        0.0, 1.0, 0.0,
        1.0, 0.0, 0.0,
        1.0, 1.0, 0.0]
    }

    public func draw(context: PXRendererContext, entities: [PXDrawableEntity]) {
        let encoder = context.encoder
        let camera = context.camera

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
        encoder.setVertexBytes(vertexData, length: MemoryLayout.size(ofValue: vertexData[0]) * vertexData.count, index: VertexAttribute.position.rawValue)

        var funiforms = LightsFragmentUniforms()
        funiforms.ambientColor = PXColor(r: 0.1, g: 0.1, b: 0.1, a: 1.0).vector

        let lightBytes = entities.compactMap({ (e) -> Light? in
            if let l = e.light {
                return Light(
                    pos: e.center.vec,
                    clipRadius: l.radius,
                    amount: l.amount,
                    color: l.color.vector)
            }
            return nil
        })

        funiforms.lightsCount = Int32(lightBytes.count)

        // TODO: Create buffer instead of bytes
        encoder.setFragmentBytes(lightBytes, length: MemoryLayout<Light>.stride * lightBytes.count, index: LightsFragmentBuffers.lights.rawValue)

        encoder.setFragmentBytes(&funiforms, length: MemoryLayout.size(ofValue: funiforms), index: LightsFragmentBuffers.uniforms.rawValue)

        encoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: vertexData.count / 3)
    }
}

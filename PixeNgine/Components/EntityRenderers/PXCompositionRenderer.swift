//
//  PXCompositionRenderer.swift
//  PixeNgine
//
//  Created by Andrii Zinoviev on 27.04.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation
import Metal

public class PXCompositionRenderer {
    private var vertexData: [Float] { [-1, -1, 0.0, -1, 1.0, 0.0,
        1.0, -1, 0.0,
        1.0, 1.0, 0.0]
    }

    public func draw(encoder: MTLRenderCommandEncoder, entities: MTLTexture, lights: MTLTexture) {
        encoder.setRenderPipelineState(PXCache.getPipeline(PXCompositionPipeline.self)!)

        encoder.setFragmentTextures([entities, lights], range: 1..<3)
        
        encoder.setVertexBytes(vertexData, length: MemoryLayout.size(ofValue: vertexData[0]) * vertexData.count, index: VertexAttribute.position.rawValue)

        encoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: vertexData.count / 3)
    }
}

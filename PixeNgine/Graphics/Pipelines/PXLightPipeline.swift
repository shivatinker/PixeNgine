//
//  PXLightPipeline.swift
//  PixeNgine
//
//  Created by Andrii Zinoviev on 25.04.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation
import Metal

class PXLightPipeline: PXPipeline {
    
    private static let vertexShaderName = "vertex_lights"
    private static let fragmentShaderName = "fragment_lights"
    
    static func createInstance() -> MTLRenderPipelineState? {
        let vertexDescriptor = MTLVertexDescriptor()

        vertexDescriptor.attributes[VertexAttribute.position.rawValue].format = .float3
        vertexDescriptor.attributes[VertexAttribute.position.rawValue].offset = 0
        vertexDescriptor.attributes[VertexAttribute.position.rawValue].bufferIndex = BufferIndex.position.rawValue

        vertexDescriptor.layouts[BufferIndex.position.rawValue].stride = 12
        vertexDescriptor.layouts[BufferIndex.position.rawValue].stepRate = 1
        vertexDescriptor.layouts[BufferIndex.position.rawValue].stepFunction = MTLVertexStepFunction.perVertex

        ///Create pipeline descriptor

        let library = try? PXConfig.device.makeDefaultLibrary(bundle: Bundle(for: PXRenderer.self))
        let vertexFunction = library?.makeFunction(name: vertexShaderName)
        let fragmentFunction = library?.makeFunction(name: fragmentShaderName)

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.label = "LightsPipeline"
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        pipelineDescriptor.colorAttachments[0].pixelFormat = PXConfig.texturePixelFormat
        pipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        pipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
        pipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add
        pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .one
        pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
        pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        
        return try? PXConfig.device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
}

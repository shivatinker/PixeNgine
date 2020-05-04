//
//  PXCompositionPipeline.swift
//  PixeNgine
//
//  Created by Andrii Zinoviev on 27.04.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation
import Metal

class PXCompositionPipeline: PXPipeline {

    private static let vertexShaderName = "vertex_composition"
    private static let fragmentShaderName = "fragment_composition"

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
        pipelineDescriptor.label = "Composition pipeline"
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.vertexDescriptor = vertexDescriptor

        pipelineDescriptor.configureAttachment(index: 0, pixelFormat: PXConfig.framebufferPixelFormat)
//        pipelineDescriptor.configureAttachment(index: 1, pixelFormat: PXConfig.texturePixelFormat)
//        pipelineDescriptor.configureAttachment(index: 2, pixelFormat: PXConfig.texturePixelFormat)

        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        
        return try? PXConfig.device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
}

private extension MTLRenderPipelineDescriptor {
    func configureAttachment(index: Int, pixelFormat: MTLPixelFormat) {
        colorAttachments[index].pixelFormat = pixelFormat
        colorAttachments[index].isBlendingEnabled = true
        colorAttachments[index].rgbBlendOperation = .add
        colorAttachments[index].alphaBlendOperation = .add
        colorAttachments[index].sourceRGBBlendFactor = .one
        colorAttachments[index].sourceAlphaBlendFactor = .sourceAlpha
        colorAttachments[index].destinationRGBBlendFactor = .oneMinusSourceAlpha
        colorAttachments[index].destinationAlphaBlendFactor = .oneMinusSourceAlpha
    }
}

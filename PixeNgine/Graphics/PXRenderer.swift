//
//  Renderer.swift
//  PixeNgine
//
//  Created by Andrii Zinoviev on 09.04.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation
import MetalKit
import Metal

public class PXRenderer: NSObject {
    // MARK: Constants
    private let bgColor = PXColor(r: 0.0, g: 0.0, b: 0.0, a: 1.0)

    // MARK: Private members
    private var mtkView: MTKView
    private let device = PXConfig.device
    private let commandQueue: MTLCommandQueue
    private var semaphore: DispatchSemaphore
    private var screenSize: CGSize!

    // MARK: Textures
    private func buildTexture(pixelFormat: MTLPixelFormat,
                              size: CGSize,
                              label: String) -> MTLTexture {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: pixelFormat,
            width: Int(size.width),
            height: Int(size.height),
            mipmapped: false)
        descriptor.usage = [.shaderRead, .renderTarget]
        descriptor.storageMode = .private
        guard let texture =
            PXConfig.device.makeTexture(descriptor: descriptor) else {
                fatalError()
        }
        texture.label = "\(label) texture"
        return texture
    }

    private var lightsTexture: MTLTexture!
    private var entitiesTexture: MTLTexture!
    private var overlayTexture: MTLTexture!

    // MARK: Render pass descriptors
    private var lightsRenderPassDescriptor: MTLRenderPassDescriptor!
    private func configureLightsPass() -> MTLRenderPassDescriptor {
        let descriptor = MTLRenderPassDescriptor()
        descriptor.setColorAttachment(index: 0, texture: lightsTexture)
        return descriptor
    }

    private var entityRenderPassDescriptor: MTLRenderPassDescriptor!
    private func configureEntityPass() -> MTLRenderPassDescriptor {
        let descriptor = MTLRenderPassDescriptor()
        descriptor.setColorAttachment(index: 0, texture: entitiesTexture)
        return descriptor
    }

    private var ovarlayRenderPassDescriptor: MTLRenderPassDescriptor!
    private func configureOverlayPass() -> MTLRenderPassDescriptor {
        let descriptor = MTLRenderPassDescriptor()
        descriptor.setColorAttachment(index: 0, texture: overlayTexture)
        return descriptor
    }

    // MARK: Public API
    public var width: Float { Float(screenSize.width) }
    public var height: Float { Float(screenSize.height) }
    public var aspectRatio: Float { Float(screenSize.width) / Float(screenSize.height) }
    public var scene: PXScene?

    public init?(view: MTKView) {
        mtkView = view
        mtkView.backgroundColor = bgColor.uiColor
        mtkView.clearColor = bgColor.mtlClearColor

        screenSize = mtkView.drawableSize

        mtkView.device = device
        mtkView.colorPixelFormat = PXConfig.framebufferPixelFormat

        guard let queue = self.device.makeCommandQueue() else { fatalError() }
        commandQueue = queue
        semaphore = DispatchSemaphore(value: 3)

        super.init()
        mtkView.delegate = self

        lightsTexture = buildTexture(pixelFormat: PXConfig.texturePixelFormat, size:
            CGSize(width: mtkView.drawableSize.width / 3, height: mtkView.drawableSize.height / 3), label: "Lights")
        entitiesTexture = buildTexture(pixelFormat: PXConfig.texturePixelFormat, size: mtkView.drawableSize, label: "Entities")
        overlayTexture = buildTexture(pixelFormat: PXConfig.texturePixelFormat, size: mtkView.drawableSize, label: "Overlays")

        lightsRenderPassDescriptor = configureLightsPass()
        entityRenderPassDescriptor = configureEntityPass()
        ovarlayRenderPassDescriptor = configureOverlayPass()

        pxDebug("Ready")
    }
}

// MARK: Utility extensions
private extension MTLRenderPassDescriptor {
    func setColorAttachment(index: Int, texture: MTLTexture) {
        let attachment: MTLRenderPassColorAttachmentDescriptor = colorAttachments[index]
        attachment.texture = texture
        attachment.loadAction = .clear
        attachment.storeAction = .store
        attachment.clearColor = MTLClearColorMake(0, 0, 0, 0)
    }
}

// MARK: Main rendering loop

extension PXRenderer: MTKViewDelegate {
    public func draw(in view: MTKView) {
        // Wait for next frame requested
        _ = semaphore.wait(timeout: .distantFuture)

        // Update game logic
        scene?.updateScene()

        if let frameRenderPass = mtkView.currentRenderPassDescriptor {
            // Setup command buffer
            let commandBuffer = commandQueue.makeCommandBuffer()!
            commandBuffer.addCompletedHandler { _ in self.semaphore.signal() }

            // Render entities into texture
            let entityEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: entityRenderPassDescriptor)!
            entityEncoder.label = "Entity encoder"
            entityEncoder.pushDebugGroup("Entities")
            scene?.renderScene(encoder: entityEncoder)
            entityEncoder.popDebugGroup()
            entityEncoder.endEncoding()

            // Render lights into texture
            let lightsEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: lightsRenderPassDescriptor)!
            lightsEncoder.label = "Lights encoder"
            lightsEncoder.pushDebugGroup("Lights")
            scene?.renderLights(encoder: lightsEncoder)
            lightsEncoder.popDebugGroup()
            lightsEncoder.endEncoding()

            // Render overlay into texture
            let overlayEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: ovarlayRenderPassDescriptor)!
            overlayEncoder.label = "Overlay encoder"
            overlayEncoder.pushDebugGroup("Overlay")
            scene?.renderOverlays(encoder: overlayEncoder)
            overlayEncoder.popDebugGroup()
            overlayEncoder.endEncoding()

            // Combine textures and render on the screen
            let compositionEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: frameRenderPass)!
            compositionEncoder.label = "Composition encoder"
            compositionEncoder.compose(entities: entitiesTexture, lights: lightsTexture, overlay: overlayTexture)
            compositionEncoder.endEncoding()


            if let drawable = view.currentDrawable {
                commandBuffer.present(drawable)
            }
            commandBuffer.commit()
        }
    }

    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        screenSize = size
    }
}

private extension MTLRenderCommandEncoder {
    func compose(entities: MTLTexture, lights: MTLTexture, overlay: MTLTexture) {
        pushDebugGroup("Combine textures")
        setRenderPipelineState(PXCache.getPipeline(PXCompositionPipeline.self)!)
        setFragmentTextures([entities, lights, overlay], range: 1..<4)
        setVertexBytes(Meshes.screenQuad,
                       length: MemoryLayout.size(ofValue: Meshes.screenQuad[0]) * Meshes.screenQuad.count,
                       index: VertexAttribute.position.rawValue)
        drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: Meshes.screenQuad.count / 3)
        popDebugGroup()
    }
}

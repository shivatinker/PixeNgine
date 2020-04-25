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


    private var tileCount: Float = 12


    // MARK: Internal

    // MARK: Public API
    public var width: Float {
        Float(screenSize.width)
    }
    public var height: Float {
        Float(screenSize.height)
    }
    public var aspectRatio: Float {
        Float(screenSize.width) / Float(screenSize.height)
    }
    public var scene: PXScene?

    public init?(view: MTKView) {
        mtkView = view
        mtkView.backgroundColor = bgColor.uiColor
        mtkView.clearColor = bgColor.mtlClearColor

        screenSize = mtkView.drawableSize

        mtkView.device = device
        mtkView.colorPixelFormat = .bgra8Unorm_srgb

        guard let queue = self.device.makeCommandQueue() else {
            fatalError()
        }
        commandQueue = queue
        semaphore = DispatchSemaphore(value: 3)
        super.init()
        mtkView.delegate = self
        pxDebug("Ready")
    }
}

public struct PXRendererContext{
    var encoder: MTLRenderCommandEncoder
    var camera: PXCamera
}

extension PXRenderer: MTKViewDelegate {
    public func draw(in view: MTKView) {
        _ = semaphore.wait(timeout: .distantFuture)
        scene?.updateScene()
        let commandBuffer = commandQueue.makeCommandBuffer()!
        commandBuffer.addCompletedHandler { _ in
            self.semaphore.signal()
        }
        let descriptor = view.currentRenderPassDescriptor!

        let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)!

        scene?.renderScene(encoder: encoder)

        encoder.endEncoding()

        if let drawable = view.currentDrawable {
            commandBuffer.present(drawable)
        }
        commandBuffer.commit()
    }

    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        screenSize = size
    }
}

//
//  PXCache.swift
//  PixeNgine
//
//  Created by Andrii Zinoviev on 10.04.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation
import Metal

protocol PXPipeline {
    static func createInstance() -> MTLRenderPipelineState?
}

class PXCache {
    private static var cachedPipelines = [String: MTLRenderPipelineState]()


    public static func getPipeline<T: PXPipeline>(_ type: T.Type) -> MTLRenderPipelineState? {
        let pipelineTypeName: String = String(describing: type)
        if let pipeline = cachedPipelines[pipelineTypeName] {
            return pipeline
        }
        if let i = T.createInstance(){
            cachedPipelines[pipelineTypeName] = i
            return i
        }
        return nil
    }
}

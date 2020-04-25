//
//  PXEntity.swift
//  PixeNgine
//
//  Created by Andrii Zinoviev on 12.04.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation
public protocol PXEntity: AnyObject {
    var pos: PXv2f { get set }
    var dimensions: PXv2f { get }
    var name: String { get }
    var visible: Bool { get }
}

public extension PXEntity {
    var center: PXv2f {
        get {
            pos + 0.5 * dimensions
        }
        set {
            pos = newValue - 0.5 * dimensions
        }
    }
    var width: Float {
        dimensions.x
    }
    var height: Float {
        dimensions.y
    }
}

public protocol PXUpdateableEntity: PXEntity {
    func onFrame()
}

public protocol PXDrawableEntity: PXEntity {
    func draw(context: PXRendererContext)
}

public protocol PXSpritedEntity: PXDrawableEntity {
    var currentSprite: PXSprite? { get }
}

//
//  PXEntity.swift
//  PixeNgine
//
//  Created by Andrii Zinoviev on 12.04.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation

public enum PXRenderMode {
    case scene
    case hud
}

private struct WeakRef {
    weak var e: PXEntity?
}

open class PXEntity {
    // id
    public final var id: Int64
    private static var nextID: Int64 = 0
    private static var all = [Int64: WeakRef]()
    public static func byID(_ id: Int64) -> PXEntity?{
        return all[id]?.e
    }

    // Common fields
    public var pos: PXv2f = .zero
    public var name: String
    open var dimensions: PXv2f { .zero }
    public var shouldBeRemoved: Bool = false
    public var renderMode: PXRenderMode = .scene
    public var subentities = [PXEntity]()

    // Common methods
    open func update() {

    }
    open func draw(context: PXDrawContext) {

    }

    public init(name: String) {
        self.name = name
        self.id = Self.nextID
        Self.nextID += 1
        Self.all[id] = WeakRef(e: self)
        
        pxDebug("Entity \(id) : \(name) created")
    }

    deinit {
        pxDebug("Entity \(id) : \(name) deleted")
    }
}

extension PXEntity: CustomDebugStringConvertible {
    public var debugDescription: String {
        "Entity \(name)\n\t shouldBeRemoved: \(shouldBeRemoved),\n\t subentities: \(subentities.debugDescription)"
    }
}

public extension PXEntity {
    var center: PXv2f {
        get { pos + 0.5 * dimensions }
        set { pos = newValue - 0.5 * dimensions }
    }
    var width: Float { dimensions.x }
    var height: Float { dimensions.y }

    var rect: PXRect {
        PXRect(
            x1: pos.x,
            y1: pos.y,
            x2: pos.x + width,
            y2: pos.y + height)
    }

    func isInside(point: PXv2f) -> Bool {
        return pos.x <= point.x && point.x <= pos.x + width &&
            pos.y <= point.y && point.y <= pos.y + height
    }
}

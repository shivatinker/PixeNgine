//
//  File.swift
//  PixeNgine
//
//  Created by Andrii Zinoviev on 12.05.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation

public enum PXShape {
    case rect(width: Float, height: Float)
    case circle(radius: Float)
}

public protocol PXPhysicsDelegate: class {
    func onCollisionResolved(entity: PXEntity, with: PXEntity, normal: PXv2f)
}

public struct PXCollisionSides: OptionSet {
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public let rawValue: Int

    static let top = PXCollisionSides(rawValue: 1 << 0)
    static let left = PXCollisionSides(rawValue: 1 << 1)
    static let right = PXCollisionSides(rawValue: 1 << 2)
    static let bottom = PXCollisionSides(rawValue: 1 << 3)

    static let all: PXCollisionSides = [.top, .left, .right, .bottom]
}

public class PXPhysics: PXComponent {
    public var velocity: PXv2f = .zero
    public var shape: PXShape
    public var solid: Bool = true
    public var incomingCollisions: PXCollisionSides = .all
    public var dynamic: Bool = true
    public var hardness: Int = 0
    public weak var delegate: PXPhysicsDelegate?

    public var dimensions: PXv2f {
        switch shape {
        case .circle(let radius): return PXv2f(radius * 2, radius * 2)
        case .rect(let width, let height): return PXv2f(width, height)
        }
    }

    public func update(entity: PXEntity) {
        if dynamic {
            entity.pos = entity.pos + velocity
        }
    }

    public init(shape: PXShape) {
        self.shape = shape
    }
}

internal class PXCollider {
    public static func aabb(_ e: PXEntity) -> PXRect {
        return PXRect(x1: e.pos.x,
                      y1: e.pos.y,
                      x2: e.pos.x + e.physics!.dimensions.x,
                      y2: e.pos.y + e.physics!.dimensions.y)
    }

    static func isColliding(_ e1: PXEntity, _ e2: PXEntity) -> Bool {
        if e1.physics != nil && e2.physics != nil {
            let rect1 = aabb(e1)
            let rect2 = aabb(e2)

            let gaps = [rect2.x2 - rect1.x1,
                rect1.x2 - rect2.x1,
                rect2.y2 - rect1.y1,
                rect1.y2 - rect2.y1]

            if gaps.allSatisfy({ $0 > 0 }) {
                return true
            }
            return false
        } else {
            return false
        }
    }

    internal static func getIsectDepth(_ e1: PXEntity, _ e2: PXEntity) -> PXv2f {
        if e1.physics != nil && e2.physics != nil {
            let rect1 = aabb(e1)
            let rect2 = aabb(e2)
            let dist = rect2.center - rect1.center
            let mind = 0.5 * PXv2f(rect1.width + rect2.width, rect1.height + rect2.height)

            if abs(dist.x) >= mind.x || abs(dist.y) >= mind.y {
                return .zero
            }

            return PXv2f(
                dist.x < 0 ? -(mind.x + dist.x) : (mind.x - dist.x),
                dist.y < 0 ? -(mind.y + dist.y) : (mind.y - dist.y))

        } else {
            return .zero
        }
    }

    static func getResolveVector(_ e1: PXEntity, _ e2: PXEntity) -> PXv2f {
        if let p1 = e1.physics, let p2 = e2.physics {
            let isect = getIsectDepth(e1, e2)

            let rect1 = aabb(e1)
            let rect2 = aabb(e2)

            var res = PXv2f.zero

            if abs(isect.y) <= rect1.height {
                if (isect.y >= 0 && p2.incomingCollisions.contains(.top) ||
                        isect.y <= 0 && p2.incomingCollisions.contains(.bottom)) {
                    res = res + PXv2f(0, -isect.y)
                }
            }

            if abs(isect.x) <= rect1.width {
                if (isect.x >= 0 && p2.incomingCollisions.contains(.left) ||
                        isect.x <= 0 && p2.incomingCollisions.contains(.right)) {
                    res = res + PXv2f(-isect.x, 0)
                }
            }

            return res
        } else {
            return .zero
        }
    }
}

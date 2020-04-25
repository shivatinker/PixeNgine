//
//  PXRect.swift
//  PixeNgine
//
//  Created by Andrii Zinoviev on 10.04.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation

public struct PXRect {
    public var x1, y1, x2, y2: Float
    public var width: Float {
        abs(x1 - x2)
    }
    public var height: Float {
        abs(y1 - y2)
    }
    public func isInside(_ p: PXv2f) -> Bool {
        return p.x >= x1 && p.x <= x2 && p.y >= y1 && p.y <= y2
    }
    public enum CollisionSide {
        case top
        case bottom
        case left
        case right
    }
    public static func isColliding(_ rect1: PXRect, _ rect2: PXRect) -> CollisionSide? {
        let gaps = [rect2.x2 - rect1.x1, //l
            rect1.x2 - rect2.x1, //r
            rect2.y2 - rect1.y1, //t
            rect1.y2 - rect2.y1] //b
        if (gaps.allSatisfy({ $0 > 0 })) {
//            print(gaps)
            switch gaps.argmax()! {
            case 0:
                return .right
            case 1:
                return .left
            case 2:
                return .bottom
            case 3:
                return .top
            default:
                return nil
            }
        }
        return nil
    }
}

private extension Array where Element: Comparable {
    func argmax() -> Index? {
        return indices.max(by: { self[$0] < self[$1] })
    }

    func argmin() -> Index? {
        return indices.min(by: { self[$0] < self[$1] })
    }
}

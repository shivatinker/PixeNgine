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
    public var center: PXv2f {
        PXv2f(x1 + (x2 - x1) / 2, y1 + (y2 - y1) / 2)
    }
    public func isInside(_ p: PXv2f) -> Bool {
        return p.x >= x1 && p.x <= x2 && p.y >= y1 && p.y <= y2
    }
}

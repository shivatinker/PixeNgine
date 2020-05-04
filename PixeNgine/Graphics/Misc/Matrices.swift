//
//  Matrices.swift
//  PixeNgine
//
//  Created by Andrii Zinoviev on 10.04.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation
import simd

class Matrices {
    static func transform(
        moveX: Float = 0,
        moveY: Float = 0,
        moveZ: Float = 0,
        scaleX: Float = 1,
        scaleY: Float = 1) -> float4x4 {
        return float4x4(rows: [
            [scaleX, 0, 0, moveX],
            [0, scaleY, 0, moveY],
            [0, 0, 1, moveZ],
            [0, 0, 0, 1]])
    }

    static func ortho(
        l: Float,
        r: Float,
        t: Float,
        b: Float,
        f: Float,
        n: Float
    ) -> float4x4 {
        return float4x4(
            [2 / (r - l), 0, 0, 0],
            [0, 2 / (t - b), 0, 0],
            [0, 0, 1 / (f - n), 0],
            [(l + r) / (l - r), (t + b) / (b - t), n / (n - f), 1]
        )
    }

    static func rotateZ(
        a: Float
    ) -> float4x4 {
        return float4x4(rows: [
            [cos(a), -sin(a), 0, 0],
            [sin(a), cos(a), 0, 0],
            [0, 0, 1, 0],
            [0, 0, 0, 1]
        ])
    }
}

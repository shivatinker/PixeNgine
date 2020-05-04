//
//  Meshes.swift
//  PixeNgine
//
//  Created by Andrii Zinoviev on 30.04.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation

internal struct Meshes {
    static let quad: [Float] = [
        0.0, 0.0, 0.0,
        0.0, 1.0, 0.0,
        1.0, 0.0, 0.0,
        1.0, 1.0, 0.0]
    static let screenQuad: [Float] = [-1.0, -1.0, 0.0, -1.0, 1.0, 0.0, 1.0, -1.0, 0.0, 1.0, 1.0, 0.0]
}

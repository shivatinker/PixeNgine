//
//  PXResourceManager.swift
//  PixeNgine
//
//  Created by Andrii Zinoviev on 14.04.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation

public class PXResourceManager {
    internal init() {

    }

    public var tileDescriptors = [Int: PXTileDescriptor]()

    private let decoder = JSONDecoder()

    public func loadTiles(path: URL) throws {
        let descriptors = try decoder.decode([PXTileDescriptor].self, from: Data(contentsOf: path))
        descriptors.forEach({ self.tileDescriptors[$0.id] = $0 })
        pxDebug("Loaded \(tileDescriptors.count) tiles")
    }
}

public struct PXTileDescriptor: Decodable {
    var id: Int
    var name: String
    var texture: String
}

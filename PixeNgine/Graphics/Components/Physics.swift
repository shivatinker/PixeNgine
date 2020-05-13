//
//  File.swift
//  PixeNgine
//
//  Created by Andrii Zinoviev on 12.05.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation

public class PXPhysics: PXComponent {
    public var velocity: PXv2f = .zero

    public func update(entity: PXEntity) {
        entity.pos = entity.pos + velocity
    }

    public init() {

    }
}

public class PXCollider: PXComponent {

}

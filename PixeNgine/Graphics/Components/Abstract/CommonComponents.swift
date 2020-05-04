//
//  CommonComponents.swift
//  PixeNgine
//
//  Created by Andrii Zinoviev on 24.04.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation

public protocol PXComponent: AnyObject {

}

public protocol PXEntityController: PXComponent {
    func update(entity: PXEntity)
}

public protocol PXDrawable: PXComponent {
    var visible: Bool { get set }
    var opacity: Float { get set }
    var brightness: Float { get set }
}

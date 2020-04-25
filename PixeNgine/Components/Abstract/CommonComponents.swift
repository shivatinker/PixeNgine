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

public protocol PXEntityRenderer: PXComponent {
    func draw(context: PXRendererContext)
}

public protocol PXAnimator: PXComponent {
    var currentSprite: PXSprite? { get }
}

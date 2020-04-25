//
//  PXRect.swift
//  PixeNgine
//
//  Created by Andrii Zinoviev on 10.04.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation

public struct PXRect{
    var x1, y1, x2, y2: Float
    var width: Float{
        abs(x1 - x2)
    }
    var height: Float{
        abs(y1 - y2)
    }
}

//
//  Acceleration.swift
//  Bluetooth-example
//
//  Created by 14-0254 on 2019/11/05.
//  Copyright © 2019 Yusuke Binsaki. All rights reserved.
//

import Foundation
import CoreMotion

struct Acceleration {
    var x: Float
    var y: Float
    var z: Float

    init() {
        x = 0
        y = 0
        z = 0
    }

    init(acceleration: CMAcceleration) {
        x = Float(acceleration.x)
        y = Float(acceleration.y)
        z = Float(acceleration.z)
    }

    init(bytes: Data) {
        x = Data(bytes[0..<4]).to(type: Float.self)
        y = Data(bytes[4..<8]).to(type: Float.self)
        z = Data(bytes[8..<12]).to(type: Float.self)
    }

    var data: Data {
        var data = Data()
        data.append(x.bytes)
        data.append(y.bytes)
        data.append(z.bytes)
        return data
    }
}

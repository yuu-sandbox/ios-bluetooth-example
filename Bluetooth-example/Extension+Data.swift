//
//  Extension+Data.swift
//  Bluetooth-example
//
//  Created by 14-0254 on 2019/11/05.
//  Copyright © 2019 Yusuke Binsaki. All rights reserved.
//

import Foundation

extension Data {
    init<T>(from value: T) {
        var v = value
        self.init(buffer: UnsafeBufferPointer(start: &v, count: 1))
    }

    init<T>(from values: [T]) {
        var v = values
        self.init(buffer: UnsafeBufferPointer(start: &v, count: v.count))
    }

    func to<T>(type: T.Type) -> T {
        return withUnsafeBytes { $0.pointee }
    }
}

extension Float {
    var bytes: Data {
        let data = Data(from: self)
        return data
    }
}

extension Int16 {
    var bytes: Data {
        let data = Data(from: self)
        return data
    }
}

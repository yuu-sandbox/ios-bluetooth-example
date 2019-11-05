//
//  Extension+CBManagerState+CustomString.swift
//  Bluetooth-example
//
//  Created by 14-0254 on 2019/10/31.
//  Copyright © 2019 Yusuke Binsaki. All rights reserved.
//

import Foundation
import CoreBluetooth

extension CBManagerState: CustomStringConvertible {
    public var description: String {
        get {
            switch self {
            case .resetting:
                return "resetting"
            case .unauthorized:
                return "unauthorized"
            case .unknown:
                return "unknown"
            case .unsupported:
                return "unsupported"
            case .poweredOff:
                return "poweredOff"
            case .poweredOn:
                return "poweredOn"
            default:
                return "default"
            }
        }
    }
}

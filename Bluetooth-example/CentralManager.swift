//
//  CentralManager.swift
//  Bluetooth-example
//
//  Created by 14-0254 on 2019/11/05.
//  Copyright © 2019 Yusuke Binsaki. All rights reserved.
//

import UIKit
import CoreBluetooth

class CentralManager: UIViewController {
    // Properties
    private let mng: CBCentralManager = CBCentralManager()
    var peripheral: CBPeripheral?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

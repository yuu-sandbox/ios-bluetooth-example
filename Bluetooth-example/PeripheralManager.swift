//
//  PeripheralManager.swift
//  Bluetooth-example
//
//  Created by 14-0254 on 2019/11/05.
//  Copyright © 2019 Yusuke Binsaki. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreMotion

class PeripheralManager: UIViewController {
    @IBOutlet var logTextView: UITextView!

    private let mng: CBPeripheralManager = CBPeripheralManager()
    let srv = CBMutableService(type: srvID, primary: true)
    let char = CBMutableCharacteristic(type: charID, properties: [.read, .write, .notify], value: nil, permissions: [.readable, .writeable])

    let motionManager = CMMotionManager()
    var acceleration = Acceleration() {
        didSet {
            self.mng.updateValue(acceleration.data, for: self.char, onSubscribedCentrals: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.mng.delegate = self
        srv.characteristics = [char]

        if let queue = OperationQueue.current {
            motionManager.accelerometerUpdateInterval = 0.2
            motionManager.startAccelerometerUpdates(to: queue) { [weak self] (data, _) in
                guard let data = data else { return }
                self?.acceleration = Acceleration(acceleration: data.acceleration)
            }
        }
    }
}

extension PeripheralManager: CBPeripheralManagerDelegate {
    // Monitoring Changes to the Peripheral Manager’s State
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        logTextView.appendLog(text: "peripheral did update state=\(peripheral.state)")
        switch peripheral.state {
        case .resetting:
            break
        case .unauthorized:
            break
        case .unknown:
            break
        case .unsupported:
            break
        case .poweredOff:
            self.mng.stopAdvertising()
        case .poweredOn:
            logTextView.appendLog(text: "start peripheral")
            self.mng.add(srv) // viewDidLoadで `add` してもCentralで受け取れなかった。
            let advertise = [CBAdvertisementDataServiceUUIDsKey: [srv.uuid]] as [String : Any]
            self.mng.startAdvertising(advertise)
        default:
            logTextView.appendLog(text: "clean-up central")
        }
    }

// not implement
//    func peripheralManager(_ peripheral: CBPeripheralManager, willRestoreState dict: [String : Any]) {
//    }

    // Adding Services
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if let err = error {
            logTextView.appendLog(text: "\(#function): \(err)")
            return
        }
        logTextView.appendLog(text: "didAdd: \(service)")
    }

    // Advertising Peripheral Data
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        logTextView.appendLog(text: "didStartAdvertising: error=\(String(describing: error))")
    }

    // Monitoring Subscriptions to Characteristic Values
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        logTextView.appendLog(text: "didSubscribeTo: \(characteristic)")
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        logTextView.appendLog(text: "didUnsubscribeFrom: \(characteristic)")
    }

// not implement
//    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
//    }

    // Receiving Read and Write Requests
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
//        peripheral.respond(to: request, withResult: .success)
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
    }
}

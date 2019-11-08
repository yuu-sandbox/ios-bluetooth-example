//
//  CentralManager.swift
//  Bluetooth-example
//
//  Created by 14-0254 on 2019/11/05.
//  Copyright © 2019 Yusuke Binsaki. All rights reserved.
//

import UIKit
import CoreBluetooth
import Charts

class CentralManager: UIViewController {
    // Properties
    @IBOutlet var lineChartView: LineChartView!

    private let mng: CBCentralManager = CBCentralManager()
    var peripheral: CBPeripheral?

    override func viewDidLoad() {
        super.viewDidLoad()

        let data = LineChartData()
        data.addDataSet(self.createDataSet(values: nil, color: UIColor.red, label: "x"))
        data.addDataSet(self.createDataSet(values: nil, color: UIColor.green, label: "y"))
        data.addDataSet(self.createDataSet(values: nil, color: UIColor.blue, label: "z"))

        self.lineChartView.data = data
        self.lineChartView.gridBackgroundColor = UIColor.lightGray
        self.lineChartView.pinchZoomEnabled = false
        self.lineChartView.scaleXEnabled = false
        self.lineChartView.scaleYEnabled = false
        self.lineChartView.chartDescription?.text = "Accelerator"

        let lA = self.lineChartView.leftAxis
        lA.axisMaximum = 1.5
        lA.axisMinimum = -1.5
        let rA = self.lineChartView.rightAxis
        rA.enabled = false

        self.mng.delegate = self
    }

    private func createDataSet(values: [ChartDataEntry]?, color: UIColor, label: String) -> LineChartDataSet {
        let ds = LineChartDataSet(entries: values, label: label)
        ds.colors = [color]
        ds.drawCirclesEnabled = false
        return ds
    }
}

extension CentralManager: CBCentralManagerDelegate {
    // Monitoring Connections with Peripherals
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        debugPrint("didConnect: \(peripheral)")
        self.peripheral = peripheral
        
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        debugPrint("didDisconnect: \(peripheral), error=\(String(describing: error))")
    }
    
    //    func centralManager(_ central: CBCentralManager, connectionEventDidOccur event: CBConnectionEvent, for peripheral: CBPeripheral) {
    //        debugPrint("event=\(event), peripheral=\(peripheral)")
    //    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        debugPrint("didFailToConnect: \(peripheral), error=\(String(describing: error))")
    }
    
    // Discovering and Retrieving Peripherals
    func centralManager(_ central: CBCentralManager, didDiscover: CBPeripheral, advertisementData: [String : Any], rssi: NSNumber) {
        debugPrint("didDiscover: \(advertisementData)")
        self.peripheral = didDiscover
        central.connect(didDiscover, options: nil)
        central.stopScan()
    }
    
    // Monitoring the Central Manager’s State
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("cental did update state=\(central.state)")
        switch central.state {
        case .resetting:
            break
        case .unauthorized:
            break
        case .unknown:
            break
        case .unsupported:
            break
        case .poweredOff:
            self.mng.stopScan()
        case .poweredOn:
            print("start central")
            //            central.registerForConnectionEvents(options: nil) // this is beta, not occured...
            central.scanForPeripherals(withServices: [srvID], options: nil)
        default:
            print("clean-up central")
        }
    }
}

extension CentralManager: CBPeripheralDelegate {
    // Discovering Services
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        debugPrint("didDiscoverService: \(peripheral), error=\(String(describing: error))")
        peripheral.services?.forEach { debugPrint($0) }

        let srv = peripheral.services?.first { return $0.uuid == srvID }
        peripheral.discoverCharacteristics([charID], for: srv!)
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: Error?) {
        debugPrint("didDiscoverIncludedServicesFor: \(peripheral)")
    }

    // Discovering Characteristics and Characteristic Descriptors
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        debugPrint("didDiscoveryChar: \(peripheral), error=\(String(describing: error))")
        service.characteristics?.forEach {
            debugPrint($0)
            peripheral.setNotifyValue(true, for: $0)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        debugPrint("didDiscoverDescritorsFor: \(peripheral), char=\(characteristic)")
    }

    // Retrieving Characteristic and Characteristic Descriptor Values
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        debugPrint("didUpdateValueFor.Char: \(peripheral), char=\(characteristic)")
        guard
            characteristic.uuid == charID,
            let value = characteristic.value,
            let data = self.lineChartView.data
        else { return }

        let acc = Acceleration(bytes: value)
        defer {
            data.notifyDataChanged()
            self.lineChartView.notifyDataSetChanged()
        }

        let x = data.getDataSetByIndex(0)
        let y = data.getDataSetByIndex(1)
        let z = data.getDataSetByIndex(2)
        let _ = x?.addEntry(ChartDataEntry(x: max(0, x!.xMax) + 1, y: Double(acc.x)))
        let _ = y?.addEntry(ChartDataEntry(x: max(0, y!.xMax) + 1, y: Double(acc.y)))
        let _ = z?.addEntry(ChartDataEntry(x: max(0, z!.xMax) + 1, y: Double(acc.z)))
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        debugPrint("didUpdateValueFor.Descriptor: \(peripheral)")
    }

    // Writing Characteristic and Characteristic Descriptor Values
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
    }

    // Managing Notifications for a Characteristic’s Value
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        debugPrint("didUpdateNotificationStateFor: \(peripheral), char=\(characteristic), error=\(String(describing: error))")
        
        if let value = characteristic.value {
            if characteristic.uuid == charID {
                let acc = Acceleration(bytes: value)
                debugPrint(acc)
            }
        }
    }

    // Retrieving a Peripheral’s Received Signal Strength Indicator (RSSI) Data
//    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
//    }

    // Monitoring Changes to a Peripheral’s Name or Services
//    func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
//    }

//    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
//    }
}

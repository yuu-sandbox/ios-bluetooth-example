//
//  Extension+UITextView+Log.swift
//  Bluetooth-example
//
//  Created by 14-0254 on 2019/11/05.
//  Copyright © 2019 Yusuke Binsaki. All rights reserved.
//

import UIKit

extension UITextView {

    func appendLog(text: String) {
        DispatchQueue.main.async {
            let formatter: DateFormatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let now = formatter.string(from: Date())
            self.text = String(format: "%@[%@] %@\n", self.text, now, text)
        }
    }
}

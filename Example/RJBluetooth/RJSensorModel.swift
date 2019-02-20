//
//  RJSensorModel.swift
//  swiftTest
//
//  Created by RJ on 2018/7/16.
//  Copyright © 2018年 RJ. All rights reserved.
//

import UIKit
import CoreBluetooth
class RJSensorModel: NSObject {
    var cbPeripheral          : CBPeripheral?
    var UUID                  : String?
    var name                  : String?
    var RSSI                  : NSInteger = 0
    var MacAdress             : String?
    var OEM_ID                : String?
    var OEM_Type              : String?
    var version               : String?
    var advertisementData     : [String : Any]?
    override init() {
        super.init()
    }
     convenience init(_ sensor:CBPeripheral, _ advertisement:[String : Any], _ rssi:NSNumber) {
        self.init()
        cbPeripheral      = sensor
        UUID              = sensor.identifier.uuidString
        name              = sensor.name
        RSSI              = NSInteger(fabs(rssi.doubleValue))
        advertisementData = advertisement
        
        
    }
}

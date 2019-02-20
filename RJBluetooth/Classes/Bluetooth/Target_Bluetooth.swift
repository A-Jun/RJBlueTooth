//
//  Target_Bluetooth.swift
//  CTMediator
//
//  Created by RJ on 2018/8/28.
//

import UIKit
import CoreBluetooth
@objc public class Target_Bluetooth: NSObject {
    let bluetoothManager = RJBluetoothManager.sharedInstance
    
    //MARK: - 中心管理设备方法
    /// 初始化蓝牙管理器
    ///
    /// - Parameter params: 无
    @objc func Action_Configure(_ params:[AnyHashable: Any]) {
        
    }
    /// 重置中心管理器代理
    ///
    /// - Returns: void
    @objc func Action_ResetCBCentralManagerDelegate(_ params:[AnyHashable: Any]) -> Void {
        bluetoothManager.resetCBCentralManagerDelegate()
    }
    /// 搜索外设
    ///
    /// - Parameters:
    ///   - services: 服务 [String]?
    ///   - options: 可选字典， [String : Any]? 指定用于自定义扫描的选项 是否重复扫描已发现的设备 默认为NO
    ///              CBCentralManagerScanOptionAllowDuplicatesKey:false
    @objc func Action_ScanSensor(_ params:[AnyHashable:Any]) {
        let services = params["services"] as? [CBUUID]
        let options  = params["options"]  as? [String : Any]
        let handler  = params["handler"]  as? ScanSensorResultHandler
        bluetoothManager.scanSensor(withServices: services, options: options ,handler: handler)
    }
    /// 结束搜索外设
    @objc func Action_StopScan(_ params:[AnyHashable:Any])  {
        bluetoothManager.stopScan()
    }
    /// 连接外设
    ///
    /// - Parameters:
    ///   - sensor: 外设模型
    ///   - options: 可选字典，指定用于连接状态的提示的选项
    @objc func Action_Connect(_ params:[AnyHashable:Any]) -> Void {
        let peripheral = params["peripheral"] as! CBPeripheral
        let options    = params["options"]   as? [String : Any]
        let connnectHandler    = params["connnectHandler"]   as? ConnectSensorResultHandler
        let disConnectHandler  = params["disConnectHandler"] as? DisConnectSensorResultHandler
        bluetoothManager.connect(peripheral, options, connnectHandler, disConnectHandler)
    }
    /// 断开与外设的连接
    @objc func Action_DisConnect(_ params:[AnyHashable:Any]) -> Void {
        bluetoothManager.disConncet()
    }
    //MARK: 外设设备方法
    /// 搜索服务
    ///
    /// - Parameter serviceUUIDs: 服务数组
    @objc func Action_DiscoverServices(_ params:[AnyHashable:Any]) -> Void {
        let serviceUUIDs  = params["serviceUUIDs"]   as? [CBUUID]
        let handler       = params["handler"]        as? DiscoverServicesHandler
        bluetoothManager.discoverServices(serviceUUIDs, handler)
    }
    /// 搜索特征值
    ///
    /// - Parameters:
    ///   - characteristicUUIDs: 特征值
    ///   - service: 服务
    @objc func Action_DiscoverCharacteristics(_ params:[AnyHashable:Any]) -> Void {
        let characteristicUUIDs  = params["characteristicUUIDs"]  as? [CBUUID]
        let service              = params["service"]  as! CBService
        let handler              = params["handler"]              as? DiscoverCharacteristicsHandler
        bluetoothManager.discoverCharacteristics(characteristicUUIDs, for: service, handler)
    }
    
    /// 读外设特征值数据
    ///
    /// - Parameters:
    ///   - characteristic: 要读的特征值
    ///   - handler: 回调
    @objc func Action_ReadValue(_ params:[AnyHashable:Any]) -> Void {
        let characteristic       = params["characteristic"]  as! CBCharacteristic
        let handler              = params["handler"]         as? ReadValueHandler
        bluetoothManager.readValue(for: characteristic, handler)
    }
    /// 订阅特征值
    ///
    /// - Parameters:
    ///   - enabled: 当启用通知/指示时，将通过委托方法接收特征值的更新
    ///   - characteristic: 要订阅的特征值
    @objc func Action_SetNotifyValue(_ params:[AnyHashable:Any]) -> Void {
        let enabled              = params["enabled"]         as! Bool
        let characteristic       = params["characteristic"]  as! CBCharacteristic
        let handler              = params["handler"]         as? SetNotifyValueHandler
        bluetoothManager.setNotifyValue(enabled, for: characteristic, handler)
    }
    /// 发送指令
    ///
    /// - Parameters:
    ///   - command: 指令数据
    ///   - writeDataClosure: 是否写入数据成功
    ///   - sensorFeedBackClosure: 蓝牙返回的数据
    @objc func Action_SendConmand(_ params:[AnyHashable:Any]){
        let command = params["command"] as? Data
        let characteristic = params["characteristic"] as? CBCharacteristic
        let writeType = params["writeType"] as! CBCharacteristicWriteType
        let sendCommandResultHandler = params["sendCommandResultHandler"] as? SendCommandResultHandler
        let receiveCommandResultHandler = params["receiveCommandResultHandler"] as? ReceiveCommandResultHandler
        bluetoothManager.sendConmand(command, characteristic,writeType, sendCommandResultHandler, receiveCommandResultHandler)
    }
}

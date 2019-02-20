//
//  dad.swift
//  CTMediator
//
//  Created by RJ on 2018/8/28.
//

import UIKit
@_exported import CoreBluetooth
@_exported import CTMediator
private let targaetName = "Bluetooth"
private var defaultParams :[AnyHashable :Any] = ["defaultKey":"defaultValue",
                                                 kCTMediatorParamsKeySwiftTargetModuleName:"RJBluetooth"]
private enum ActionName:String {
    case ResetCBCentralManagerDelegate
    case ScanSensor
    case StopScan
    case Connect
    case DisConnect
    case DiscoverServices
    case DiscoverCharacteristics
    case ReadValue
    case SetNotifyValue
    case SendConmand
}
public typealias ScanSensorResultHandler        = (_ central:CBCentralManager,_ peripheral: CBPeripheral,_ advertisementData: [String : Any],_ RSSI: NSNumber) -> Void
public typealias ConnectSensorResultHandler     = (_ central:CBCentralManager,_ peripheral :CBPeripheral,_ success:Bool )->Void
public typealias DisConnectSensorResultHandler  = (_ central:CBCentralManager,_ peripheral :CBPeripheral,_ error:Error? )->Void


public typealias DiscoverServicesHandler        = (_ peripheral :CBPeripheral                                   ,_ error: Error?) -> Void
public typealias DiscoverCharacteristicsHandler = (_ peripheral: CBPeripheral,_ service: CBService              ,_ error:Error?)  -> Void
public typealias ReadValueHandler               = (_ peripheral: CBPeripheral,_ characteristic: CBCharacteristic,_ error: Error?) -> Void
public typealias SetNotifyValueHandler          = (_ peripheral: CBPeripheral,_ characteristic: CBCharacteristic,_ error: Error?) -> Void
public typealias SendCommandResultHandler       = (_ peripheral: CBPeripheral,_ characteristic: CBCharacteristic,_ error: Error?) -> Void
public typealias ReceiveCommandResultHandler    = (_ peripheral: CBPeripheral,_ value: Data,_ error: Error?) -> Void


extension CTMediator {
    
    /// 重置中心管理器代理
    ///
    /// - Returns: void
    public class func resetCBCentralManagerDelegate() -> Void {
        performAction(.ResetCBCentralManagerDelegate)
    }
    /// 搜索外设
    ///
    /// - Parameters:
    ///   - services: 服务
    ///   - options: 可选字典，指定用于自定义扫描的选项 是否重复扫描已发现的设备 默认为NO
    ///              CBCentralManagerScanOptionAllowDuplicatesKey:false
    public class func scanSensor(withServices services :[CBUUID]?, options:[String : Any]? , handler:ScanSensorResultHandler?)  {
        defaultParams["services"] = services
        defaultParams["options"]  = options
        defaultParams["handler"]  = handler
        performAction(.ScanSensor)
    }
    /// 结束搜索外设
    public class func stopScan()  {
        performAction(.StopScan)
    }
    /// 连接外设
    ///
    /// - Parameters:
    ///   - sensor: 外设模型
    ///   - options: 可选字典，指定用于连接状态的提示的选项
    public class func connect(_ peripheral: CBPeripheral?, _ options:[String : Any]? , connnectHandler:ConnectSensorResultHandler?,_ disConnectHandler:DisConnectSensorResultHandler? ) -> Void {
        defaultParams["options"]    = options
        defaultParams["connnectHandler"]    = connnectHandler
        defaultParams["disConnectHandler"]    = disConnectHandler
        defaultParams["peripheral"] = peripheral
        performAction(.Connect)
    }
    
    /// 断开与外设的连接
    public class func disConnect() -> Void {
        performAction(.DisConnect)
    }
    
    //MARK: 外设设备方法
    /// 搜索服务
    ///
    /// - Parameter serviceUUIDs: 服务数组
    public class func discoverServices( _ serviceUUIDs:[CBUUID]?, _ handler:DiscoverServicesHandler?) -> Void {
        defaultParams["serviceUUIDs"] = serviceUUIDs
        defaultParams["handler"]      = handler
        performAction(.DiscoverServices)
    }
    /// 搜索特征值
    ///
    /// - Parameters:
    ///   - characteristicUUIDs: 特征值
    ///   - service: 服务
    public class func discoverCharacteristics(_ characteristicUUIDs: [CBUUID]?, for service: CBService , _ handler:DiscoverCharacteristicsHandler?) -> Void {
        defaultParams["characteristicUUIDs"] = characteristicUUIDs
        defaultParams["handler"]      = handler
        defaultParams["service"] = service
        performAction(.DiscoverCharacteristics)
    }
    
    /// 读外设特征值数据
    ///
    /// - Parameters:
    ///   - characteristic: 要读的特征值
    ///   - handler: 回调
    public class func readValue(for characteristic: CBCharacteristic ,_ handler:ReadValueHandler? = nil) -> Void {
        defaultParams["handler"]      = handler
        defaultParams["characteristic"] = characteristic
        performAction(.ReadValue)
    }
    /// 订阅特征值
    ///
    /// - Parameters:
    ///   - enabled: 当启用通知/指示时，将通过委托方法接收特征值的更新
    ///   - characteristic: 要订阅的特征值
    public class func setNotifyValue(_ enabled: Bool, for characteristic: CBCharacteristic , _ handler:SetNotifyValueHandler? = nil) -> Void {
        defaultParams["handler"]      = handler
        defaultParams["enabled"]          = enabled
        defaultParams["characteristic"]   = characteristic
        performAction(.SetNotifyValue)
    }
    /// 发送指令
    ///
    /// - Parameters:
    ///   - command: 指令数据
    ///   - writeDataClosure: 是否写入数据成功
    ///   - sensorFeedBackClosure: 蓝牙返回的数据
    public class func sendConmand(_ command:Data?, for characteristic:CBCharacteristic? ,_ writeType:CBCharacteristicWriteType,_ sendCommandResultHandler: SendCommandResultHandler? ,  _ receiveCommandResultHandler:ReceiveCommandResultHandler?) -> Void {
        defaultParams["command"] = command
        defaultParams["characteristic"] = characteristic
        defaultParams["writeType"] = writeType
        defaultParams["sendCommandResultHandler"] = sendCommandResultHandler
        defaultParams["receiveCommandResultHandler"] = receiveCommandResultHandler
        performAction(.SendConmand)
    }
    
    /// 选择方法执行
    ///
    /// - Parameter action: 方法类型
    private class func performAction(_ action:ActionName) -> Void {
        CTMediator.sharedInstance().performTarget(targaetName, action: action.rawValue, params: defaultParams, shouldCacheTarget: true)
    }
    
}

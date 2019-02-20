//
//  RJBluetoothManager.swift
//  swiftTest
//
//  Created by RJ on 2018/7/20.
//  Copyright © 2018年 RJ. All rights reserved.
//

import UIKit
@_exported import CoreBluetooth


typealias ScanSensorResultHandler        = (_ central:CBCentralManager,_ peripheral: CBPeripheral,_ advertisementData: [String : Any],_ RSSI: NSNumber) -> Void
typealias ConnectSensorResultHandler     = (_ central:CBCentralManager,_ peripheral :CBPeripheral,_ success:Bool )->Void
typealias DisConnectSensorResultHandler  = (_ central:CBCentralManager,_ peripheral :CBPeripheral,_ error:Error? )->Void


typealias DiscoverServicesHandler        = (_ peripheral :CBPeripheral                                   ,_ error: Error?) -> Void
typealias DiscoverCharacteristicsHandler = (_ peripheral: CBPeripheral,_ service: CBService              ,_ error:Error?)  -> Void
typealias ReadValueHandler               = (_ peripheral: CBPeripheral,_ characteristic: CBCharacteristic,_ error: Error?) -> Void
typealias SetNotifyValueHandler          = (_ peripheral: CBPeripheral,_ characteristic: CBCharacteristic,_ error: Error?) -> Void
typealias SendCommandResultHandler       = (_ peripheral: CBPeripheral,_ characteristic: CBCharacteristic,_ error: Error?) -> Void
typealias ReceiveCommandResultHandler    = (_ peripheral: CBPeripheral,_ value: Data,_ error: Error?) -> Void


protocol RJBluetoothManagerProtocol :NSObjectProtocol{
    /// 蓝牙状态改变
    func bluetoothStateChange(_ state:RJBluetoothCentreManagerState)
    
    /// 发现外设
    ///
    /// - Parameter sensorList: 更新后的外设列表
    func discoverSensor(didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber)
    
    /// 成功连接外设
    func didConnect(_ peripheral:CBPeripheral)
    
    /// 连接外设失败
    func didFailToConnect(_ peripheral:CBPeripheral,_ error:Error?)
    
    /// 断开外设连接
    func didDisconnectPeripheral(_ peripheral:CBPeripheral,_ error:Error?)
    
}
class RJBluetoothManager :NSObject{
    //MARK: ----------------------公有属性----------------------
    static let sharedInstance = RJBluetoothManager()
    
    /// 代理
    weak var delegate :RJBluetoothManagerProtocol?
    /// 当前搜索到的外设
    var sensorModels    = [CBPeripheral]()
    /// 当前连接的外设
    var currentPeripheral   : CBPeripheral?
    /// 过滤设备 允许显示的设备类型
    var filter_OEM_TYPE : [String]?
    /// 最远信号值
    var minRSSI         :NSInteger?
    
    
    //MARK: ----------------------私有属性----------------------
    
    /// 搜索结果回调处理
    var scanSensorResultHandler : ScanSensorResultHandler?
    
    /// 连接外设结果回调处理
    var connectSensorResultHandler : ConnectSensorResultHandler?
    
    /// 与外设断开连接结果回调处理
    var disConnectSensorResultHandler : DisConnectSensorResultHandler?
    
    /// 发现服务回调
    var discoverServicesHandler               : DiscoverServicesHandler?
    /// 发现特征值回调
    var discoverCharacteristicsHandler        : DiscoverCharacteristicsHandler?
    /// 读数据的回调
    var readValueHandler                      : ReadValueHandler?
    /// 订阅特征值的回调
    var setNotifyValueHandler                 : SetNotifyValueHandler?
    /// 发送指令回调
    var sendCommandResultHandler              : SendCommandResultHandler?
    /// 接收数据回调
    var receiveCommandResultHandler           : ReceiveCommandResultHandler?
    
    /// 读取MacAddress的特征值
    var macAddressCharacteristic              : CBCharacteristic?
    /// 要订阅的特征值
    var notifyCharacteristic              : CBCharacteristic?
    /// 写数据的特征值
    var writeCharacteristic              : CBCharacteristic?
    
    
    /// 蓝牙中心控制器
    private var centreManager   = RJBluetoothCentreManager.sharedInstance
    /// 蓝牙外设控制器
    private var perchialManager = RJBluetoothPeripheralManager.shareInstance
    
    /// 搜索设备的服务
    var scanSensorServices : [CBUUID]?
    /// 搜索设备的可选操作
    var scanSensorOption : [String:Any]?
    
    
    
    private override init() {
        super.init()
        centreManager.delegate = self
        perchialManager.delegate = self
    }
}
//MARK: - 蓝牙指令
extension RJBluetoothManager {
    /// 重置中心管理器代理
    ///
    /// - Returns: void
    func resetCBCentralManagerDelegate() -> Void {
        centreManager.resetCBCentralManagerDelegate()
    }
    //MARK: 搜索外设
    /// 搜索外设
    func scanSensor(withServices services: [CBUUID]?, options: [String:Any]? , handler:ScanSensorResultHandler? = nil) -> Void {
        scanSensorResultHandler = handler
        scanSensorServices = services
        scanSensorOption = options
        centreManager.scanSensor(withServices: scanSensorServices, options: scanSensorOption)
    }
    //MARK: 结束搜索外设
    /// 结束搜索外设
    func stopScan() -> Void {
        centreManager.stopScan()
    }
    //MARK: 连接外设
    /// 连接外设
    ///
    /// - Parameters:
    ///   - sensor: 外设模型
    ///   - options: 可选字典，指定用于连接状态的提示的选项
    func connect(_ peripheral:CBPeripheral, _ options:[String : Any]? , _ connectHandler:ConnectSensorResultHandler? , _ disConnectHandler:DisConnectSensorResultHandler?) -> Void {
        connectSensorResultHandler    = connectHandler
        disConnectSensorResultHandler = disConnectHandler
        stopScan()
        centreManager.connect(peripheral, options)
    }
    //MARK: 断开与外设的连接
    /// 断开与外设的连接
    func disConncet() -> Void {
        centreManager.disConnect()
    }
    
    /// 搜索服务
    ///
    /// - Parameter serviceUUIDs: 服务数组
    func discoverServices( _ serviceUUIDs:[CBUUID]?, _ handler:DiscoverServicesHandler? = nil) -> Void {
        discoverServicesHandler = handler
        perchialManager.discoverServices(serviceUUIDs)
    }
    /// 搜索特征值
    ///
    /// - Parameters:
    ///   - characteristicUUIDs: 特征值
    ///   - service: 服务
    func discoverCharacteristics(_ characteristicUUIDs: [CBUUID]?, for service: CBService , _ handler:DiscoverCharacteristicsHandler? = nil) -> Void {
        discoverCharacteristicsHandler = handler
        perchialManager.discoverCharacteristics(characteristicUUIDs, for: service)
    }
    
    /// 读外设特征值数据
    ///
    /// - Parameters:
    ///   - characteristic: 要读的特征值
    ///   - handler: 回调
    func readValue(for characteristic: CBCharacteristic ,_ handler:ReadValueHandler? = nil) -> Void {
        readValueHandler = handler
        macAddressCharacteristic = characteristic
        perchialManager.readValue(for: characteristic)
    }
    /// 订阅特征值
    ///
    /// - Parameters:
    ///   - enabled: 当启用通知/指示时，将通过委托方法接收特征值的更新
    ///   - characteristic: 要订阅的特征值
    func setNotifyValue(_ enabled: Bool, for characteristic: CBCharacteristic , _ handler:SetNotifyValueHandler? = nil) -> Void {
        setNotifyValueHandler = handler
        notifyCharacteristic = characteristic
        perchialManager.setNotifyValue(enabled, for: characteristic)
    }
    //MARK: 发送指令
    /// 发送指令
    ///
    /// - Parameters:
    ///   - command: 指令数据
    ///   - writeDataClosure: 是否写入数据成功
    ///   - sensorFeedBackClosure: 蓝牙返回的数据
    func sendConmand(_ command:Data?,_ characteristic:CBCharacteristic?,_ type:CBCharacteristicWriteType,_ writeDataClosure: SendCommandResultHandler? ,  _ sensorFeedBackDataClosure: ReceiveCommandResultHandler?) -> Void {
        sendCommandResultHandler = writeDataClosure
        receiveCommandResultHandler = sensorFeedBackDataClosure
        writeCharacteristic = characteristic
        perchialManager.writeValue(command, for: characteristic , type)
    }
    
}
//MARK: - 中心管理设备代理方法
extension RJBluetoothManager : RJBluetoothCentreManagerProtocol{
    
    
    func bluetoothStateChange(_ state: RJBluetoothCentreManagerState) {
        delegate?.bluetoothStateChange(state)
        if state == .poweredOn {
            centreManager.scanSensor(withServices: scanSensorServices, options: scanSensorOption)
        }
    }
    
    func discoverSensor(_ central:CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        DispatchQueue.main.async {
            self.delegate?.discoverSensor(didDiscover: peripheral, advertisementData: advertisementData, rssi: RSSI)
            guard let closure = self.scanSensorResultHandler else { return  }
            closure(central,peripheral,advertisementData,RSSI)
        }
    }
    func didConnect(_ central:CBCentralManager,_ peripheral: CBPeripheral) {
        currentPeripheral = peripheral
        perchialManager.cbPeripheral = peripheral
        DispatchQueue.main.async {
            self.delegate?.didConnect(peripheral)
            guard let closure = self.connectSensorResultHandler else { return  }
            closure(central,peripheral,true)
        }
    }
    
    func didFailToConnect(_ central:CBCentralManager,_ peripheral: CBPeripheral, _ error: Error?) {
        DispatchQueue.main.async {
            self.delegate?.didFailToConnect(peripheral, error)
            guard let closure = self.connectSensorResultHandler else { return  }
            closure(central,peripheral,false)
        }
    }
    
    func didDisconnectPeripheral(_ central:CBCentralManager,_ peripheral: CBPeripheral, _ error: Error?) {
        DispatchQueue.main.async {
            self.currentPeripheral = nil
            self.delegate?.didDisconnectPeripheral(peripheral, error)
            guard let closure = self.disConnectSensorResultHandler else { return  }
            closure(central,peripheral,error)
        }
    }
    
    
    
}
extension RJBluetoothManager :RJBluetoothPeripheralManagerProtocol{
    //发现服务的回调
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?){
        guard let closure = discoverServicesHandler else { return }
        DispatchQueue.main.async {
            closure(peripheral,error)
        }
    }
    //发现特征值的回调
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?){
        guard let closure = discoverCharacteristicsHandler else { return }
        DispatchQueue.main.async {
            closure(peripheral,service,error)
        }
    }
    //订阅特征值的回调
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?){
        if characteristic == notifyCharacteristic {
            guard let closure = setNotifyValueHandler else { return }
            DispatchQueue.main.async {
                closure(peripheral,characteristic,error)
            }
        }
        
    }
    //写数据的回调
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let closure = sendCommandResultHandler else { return }
        DispatchQueue.main.async {
            closure(peripheral,characteristic,error)
        }
    }
    //外设的返回数据
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?){
        let value = (Data(bytes: [UInt8](characteristic.value!)) as NSData).copy() as! Data
        if characteristic == macAddressCharacteristic {
            guard let read = readValueHandler else { return }
            DispatchQueue.main.async {
                read(peripheral,characteristic,error)
            }
        }
        guard let closure = receiveCommandResultHandler else { return }
        DispatchQueue.main.async {
            closure(peripheral,value,error)
        }
        
    }
}

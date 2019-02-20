//
//  RJBluetoothCentreManager.swift
//  swiftTest
//
//  Created by RJ on 2018/7/20.
//  Copyright © 2018年 RJ. All rights reserved.
//

import UIKit
import CoreBluetooth
enum RJBluetoothCentreManagerState : Int {
    
    case unknown
    
    case resetting
    
    case unsupported
    
    case unauthorized
    
    case poweredOff
    
    case poweredOn
    
}
protocol RJBluetoothCentreManagerProtocol :NSObjectProtocol{
    
    /// 蓝牙状态改变
    func bluetoothStateChange(_ state:RJBluetoothCentreManagerState)
    
    /// 发现外设
    ///
    /// - Parameter sensorList: 更新后的外设列表
    func discoverSensor(_ central:CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber)
    
    /// 成功连接外设
    func didConnect(_ central:CBCentralManager,_ peripheral: CBPeripheral)
    
    /// 连接外设失败
    func didFailToConnect(_ central:CBCentralManager,_ peripheral: CBPeripheral,_ error:Error?)
    
    /// 断开外设连接
    func didDisconnectPeripheral(_ central:CBCentralManager,_ peripheral: CBPeripheral,_ error:Error?)
    
}
let bluetoothOptionalQueueKey = DispatchSpecificKey<String>()

class RJBluetoothCentreManager : NSObject{
    static let sharedInstance = RJBluetoothCentreManager()
    /// 连接的外设
    var peripheral            : CBPeripheral?
    /// 代理
    weak    var delegate       :RJBluetoothCentreManagerProtocol?
    /// 蓝牙状态
    var state           :RJBluetoothCentreManagerState?
    //MARK: ------------------ 私有属性 ------------------
    ///处理蓝牙事务操作的队列
    var operationQueue :DispatchQueue?
    ///蓝牙中心
    private var cbcentreManager:CBCentralManager?
    /// 代理 遵守 RJBluetoothCentreManagerProtocol
    
    private override init() {
        super.init()
        operationQueue  = DispatchQueue(label: "com.coollang.bluetoothOptionalQueue")
        operationQueue?.setSpecific(key: bluetoothOptionalQueueKey, value: "bluetoothOptionalQueue")
        cbcentreManager = CBCentralManager(delegate:self, queue: operationQueue)
    }
    //MARK: - 公有方法
    /// 重置中心管理器代理
    ///
    /// - Returns: void
    func resetCBCentralManagerDelegate() -> Void {
        cbcentreManager?.delegate = self
    }
    //MARK: 搜索外设
    /// 搜索外设
    ///
    /// - Parameters:
    ///   - services: 服务
    ///   - options: 可选字典，指定用于自定义扫描的选项 是否重复扫描已发现的设备 默认为NO
    ///              CBCentralManagerScanOptionAllowDuplicatesKey:false
    func scanSensor(withServices services :[CBUUID]?, options:[String : Any]?) -> Void {
        stopScan()
        cbcentreManager?.scanForPeripherals(withServices: services, options: options)
    }
    //MARK: 停止搜索外设
    /// 停止搜索外设
    func stopScan() -> Void {
        cbcentreManager?.stopScan()
    }
    //MARK: 连接外设
    /// 连接外设
    ///
    /// - Parameters:
    ///   - sensor: 外设模型
    ///   - options: 可选字典，指定用于连接状态的提示的选项
    func connect(_ peripheral:CBPeripheral, _ options:[String : Any]?) -> Void {
        cbcentreManager?.connect(peripheral, options: options)
    }
    //MARK: 断开与外设的连接
    /// 断开与外设的连接
    func disConnect() -> Void {
        guard let connectPeripheral = peripheral else { return }
        cbcentreManager?.cancelPeripheralConnection(connectPeripheral)
    }
}
//MARK: - 系统中心设备方法 及 代理方法
extension RJBluetoothCentreManager : CBCentralManagerDelegate {
    
    //MARK: 蓝牙状态改变
    //蓝牙状态改变
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            state = RJBluetoothCentreManagerState.unknown
            print("未知蓝牙")
        case .resetting:
            state = RJBluetoothCentreManagerState.resetting
            print("重启蓝牙")
        case .unsupported:
            state = RJBluetoothCentreManagerState.unsupported
            print("不支持的设备")
        case .unauthorized:
            state = RJBluetoothCentreManagerState.unauthorized
            print("未授权蓝牙")
        case .poweredOn:
            state = RJBluetoothCentreManagerState.poweredOn
            print("蓝牙打开")
        case .poweredOff:
            state = RJBluetoothCentreManagerState.poweredOff
            print("蓝牙关闭")
        }
        delegate?.bluetoothStateChange(state ?? RJBluetoothCentreManagerState.unknown)
    }
    
    
    
    
    //MARK: 搜索外设的回调
    //搜索到外设
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        delegate?.discoverSensor(central,didDiscover: peripheral, advertisementData: advertisementData, rssi: RSSI)
    }
    
    //MARK: - 连接外设的回调
    //连接外设成功
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.peripheral = peripheral
        delegate?.didConnect(central,peripheral)
    }
    //连接外设失败
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        self.peripheral = nil
        delegate?.didFailToConnect(central,peripheral,error)
    }
    //断开外设连接
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        self.peripheral = nil
        delegate?.didDisconnectPeripheral(central,peripheral,error)
    }
}

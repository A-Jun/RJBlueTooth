//
//  RJBluetoothPerchial.swift
//  swiftTest
//
//  Created by RJ on 2018/7/20.
//  Copyright © 2018年 RJ. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol RJBluetoothPeripheralManagerProtocol :NSObjectProtocol{
    //发现服务的回调
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?);
    //发现特征值的回调
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?);
    //订阅特征值的回调
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?);
    //写数据的回调
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) ;
    //外设的返回数据
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?);
}


class RJBluetoothPeripheralManager : NSObject{
    static let shareInstance                 = RJBluetoothPeripheralManager()
    
    /// 外设
    var cbPeripheral                 : CBPeripheral? {//引用类型 引用外设中心发现的外设
        didSet{
            cbPeripheral?.delegate = self
        }
    }
    
    /// 代理
    weak    var delegate                     :RJBluetoothPeripheralManagerProtocol?
    /// 读MacAddress的特征值
    private var readMacCharacteristic        : CBCharacteristic?
    /// 写数据的特征值
    private var writeCharacteristic          : CBCharacteristic?
    /// 订阅的特征值
    private var notifyCharacteristic         : CBCharacteristic?
    
    
    
    //MARK: 搜索服务
    /// 搜索服务
    ///
    /// - Parameter serviceUUIDs: 服务数组
    func discoverServices( _ serviceUUIDs:[CBUUID]?) -> Void {
        cbPeripheral?.discoverServices(serviceUUIDs)
    }
    //MARK: 搜索特征值
    /// 搜索特征值
    ///
    /// - Parameters:
    ///   - characteristicUUIDs: 特征值
    ///   - service: 服务
    func discoverCharacteristics(_ characteristicUUIDs: [CBUUID]?, for service: CBService) -> Void {
        cbPeripheral?.discoverCharacteristics(characteristicUUIDs, for: service)
    }
    
    /// 读外设特征值数据
    ///
    /// - Parameters:
    ///   - characteristic: 要读的特征值
    ///   - handler: 回调
    func readValue(for characteristic: CBCharacteristic) -> Void {
        cbPeripheral?.readValue(for: characteristic)
    }
    //MARK: 订阅特征值
    /// 订阅特征值
    ///
    /// - Parameters:
    ///   - enabled: 当启用通知/指示时，将通过委托方法接收特征值的更新
    ///   - characteristic: 要订阅的特征值
    func setNotifyValue(_ enabled: Bool, for characteristic: CBCharacteristic ) -> Void {
        cbPeripheral?.setNotifyValue(enabled, for: characteristic)
    }
    //MARK: 写数据
    /// 写数据
    ///
    /// - Parameters:
    ///   - data: 要写的数据
    ///   - complete: 写入数据是否成功
    func writeValue(_ data:Data? ,for characteristic:CBCharacteristic? , _ type:CBCharacteristicWriteType) -> Void {
        guard let write = characteristic else { return }
        guard let command = data         else { return  }
        cbPeripheral?.writeValue(command, for: write, type: type)
    }
    
}
extension RJBluetoothPeripheralManager : CBPeripheralDelegate{
    //发现服务的回调
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?){
        delegate?.peripheral(peripheral, didDiscoverServices: error)
    }
    //发现特征值的回调
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?){
        delegate?.peripheral(peripheral, didDiscoverCharacteristicsFor: service, error: error)
    }
    //订阅特征值的回调
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?){
        delegate?.peripheral(peripheral, didUpdateNotificationStateFor: characteristic, error: error)
    }
    //写数据的回调
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        delegate?.peripheral(peripheral, didWriteValueFor: characteristic, error: error)
    }
    //外设的返回数据
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?){
        delegate?.peripheral(peripheral, didUpdateValueFor: characteristic, error: error)
    }
}


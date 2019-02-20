//
//  ViewController.swift
//  RJBluetooth
//
//  Created by A-Jun on 08/28/2018.
//  Copyright (c) 2018 A-Jun. All rights reserved.
//

import UIKit
import CoreBluetooth
import CTMediator
var kServiceUUID = "0001"
var kWriteUUID   = "0002"
var kNotifyUUID  = "0003"
var kReadMacUUID = "0004"

typealias zidian = [String : Any]
class ViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource{
    var sensor : [String : Any]?
    
    /// 过滤设备 允许显示的设备类型
    var filter_OEM_TYPE : [String]?
    /// 最远信号值
    var minRSSI         :NSInteger?
    lazy var sensorList: [RJSensorModel] = {
        let array = [RJSensorModel]()
        return array
    }()
    @IBOutlet weak var scan: UIButton!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sensorList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "UITableViewCell")
        }
        let modelInfo = sensorList[indexPath.row]
        cell?.textLabel?.text = modelInfo.name
        cell?.detailTextLabel?.text = String(modelInfo.RSSI)
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = sensorList[indexPath.row]
        connectSensor(model)
    }
    
    func connectSensor(_ model:RJSensorModel) {
        CTMediator.connect(model.cbPeripheral, nil, connnectHandler: { (centralManager, peripheral, success) in
            if success {
                print("连接外设 : \(String(describing: model.name)) 成功")
                self.discoverService()
            }else{
                print("连接失败")
            }
        }) {  (centralManager, peripheral, success) in
            
        }
    }
    func discoverService() -> Void {
        CTMediator.discoverServices([CBUUID(string: kServiceUUID)], { (peripheral:CBPeripheral, error:Error?) in
            guard let services = peripheral.services else { return }
            print("搜索服务 : \(String(describing: peripheral.services)) 成功")
            //遍历服务数组找到指定的服务
            for index in 0 ..< services.count {
                let service = services[index]
                if  service.uuid .isEqual(CBUUID(string: kServiceUUID)) {
                    self.discoverCharacteristics(service)
                }
            }
        })
    }
    func discoverCharacteristics(_ service:CBService){
        //在指定服务内寻找特征值
        CTMediator.discoverCharacteristics([CBUUID(string: kWriteUUID),CBUUID(string: kReadMacUUID),CBUUID(string: kNotifyUUID)], for: service, { (peripheral:CBPeripheral, service:CBService, error:Error?) in
            guard let characteristics = service.characteristics else { return }
            print("搜索特征值 : \(String(describing: service.characteristics)) 成功")
            //遍历特征值数组找到对应特征值
            for index in 0 ..< characteristics.count {
                let characteristic = characteristics[index]
                self.handleCharacteristic(characteristic)
            }
        })
    }
    func handleCharacteristic(_ characteristic:CBCharacteristic) -> Void {
        //读MacAddress 特征值
        if  characteristic.uuid .isEqual(CBUUID(string: kReadMacUUID)) {
            CTMediator.readValue(for: characteristic, { ( peripheral: CBPeripheral, characteristic: CBCharacteristic, error: Error?) in
                if error == nil {
                    print("读取MacAddress成功")
                }
            })
        }
        //写数据 特征值
        if  characteristic.uuid .isEqual(CBUUID(string: kWriteUUID)) {
            
        }
        //订阅 特征值
        if  characteristic.uuid .isEqual(CBUUID(string: kNotifyUUID)) {
            CTMediator.setNotifyValue(true, for: characteristic, {( peripheral: CBPeripheral, characteristic: CBCharacteristic, error: Error?) in
                if error == nil {
                    print("订阅成功")
                }
            })
        }
    }
    @IBAction func scanClick(_ sender: UIButton) {
        let services = [CBUUID(string: "0001")]
        let options  = [CBCentralManagerScanOptionAllowDuplicatesKey:true]
        let handler :ScanSensorResultHandler = { (_ central:CBCentralManager,_ peripheral: CBPeripheral,_ advertisementData: [String : Any],_ RSSI: NSNumber)  in
            //1.过滤外设
            guard self.filterSensor(withRSSI: RSSI, AdvertisementData: advertisementData) else {return}
            //2.创建外设模型对象
            let sensorModel = RJSensorModel.init(peripheral, advertisementData, RSSI)
            //3.添加对象
            self.addSensorModel(sensorModel)
            self.tableView.reloadData()
        }
        CTMediator.scanSensor(withServices: services, options: options, handler: handler)
    }
    @IBAction func stopClick(_ sender: UIButton) {
        CTMediator.stopScan()
    }
    
    @IBAction func disConncect(_ sender: UIButton) {
        CTMediator.disConnect()
    }
    //过滤外设
    private func filterSensor(withRSSI RSSI: NSNumber, AdvertisementData: [String : Any]) -> Bool {
        //1.过滤 信号差的
        if RSSI.intValue < minRSSI ?? -100 {
            return true
        }
        //2.过滤 OEM_ID 不匹配的
        let advertisementDataManufacturerData = AdvertisementData[CBAdvertisementDataManufacturerDataKey]
        guard let advertisementDataManufacturerData_Guard = advertisementDataManufacturerData else { return false }
        let manufacturerData = advertisementDataManufacturerData_Guard as! NSData
        let manufacturerString = String.init(data: manufacturerData as Data, encoding: .utf8)
        guard let manufacturerString_Gurad = manufacturerString else { return false }
        guard let filter_OEM_TYPE_Gurad    = filter_OEM_TYPE else { return true }
        for index in 0..<filter_OEM_TYPE_Gurad.count {
            let oem_type = filter_OEM_TYPE_Gurad[index]
            if manufacturerString_Gurad.contains(oem_type) {
                return true
            }
        }
        return false
    }
    //添加数组对象
    private func addSensorModel(_ sensorModel:RJSensorModel) -> Void {
        //1.根据外设名称判断是否已包含该外设
        var hadContain = false
        
        for index in 0 ..< sensorList.count {
            let model = sensorList[index]
            if model.name == sensorModel.name {
                hadContain = true
            }
            
        }
        //2.根据是否包含 跟新外设表
        if hadContain { //包含
            for index in 0 ..< sensorList.count {
                let model = sensorList[index]
                if model.name == sensorModel.name {
                    sensorList[index] = sensorModel
                }
                
            }
        }else{//不包含
            sensorList.append(sensorModel)
        }
        //3.将外设表 按RSSI 大小排序
        sensorList.sort {$0.RSSI < $1.RSSI}
    }
    
    
}


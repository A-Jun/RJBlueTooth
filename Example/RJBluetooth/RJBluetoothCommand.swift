//
//  RJBluetoothCommand.swift
//  swiftTest
//
//  Created by RJ on 2018/7/24.
//  Copyright © 2018年 RJ. All rights reserved.
//

import UIKit

class RJBluetoothCommand: NSObject {
    
    /// 创建蓝牙命令
    ///
    /// - Parameters:
    ///   - headCode: 帧头
    ///   - functionCode: 功能码
    ///   - validData: 参数数据
    ///   - length: 字节长度
    /// - Returns: 蓝牙命令
    func creatCommad(_ headCode :[UInt8] = [0xA8], _ functionCode:[UInt8]? ,_ validData:[UInt8]? , length:Int = 20) -> Data {
        var bytes = [UInt8]()
        
        //1.添加帧
        bytes.append(contentsOf: headCode)
        //2.添加功能码
        guard let function = functionCode else { return Data() }
        bytes.append(contentsOf: function)
        //3.是否有数据参数发送
        //3.1 无参数 创建命令
        guard let valid = validData  else { return creatData(value: bytes ,length: length) }
        //3.2 有参数 添加参数数据
        bytes.append(contentsOf: valid)
        return creatData(value: bytes ,length: length)
    }
    //获取验证码
    func creatData(value:[UInt8] , length:Int) -> Data {
        guard value.count < length else { return Data(bytes: value) }
        //无数字位已0补足
        var bytes = value
        for _ in bytes.count ..< length {
            bytes.append(0x00)
        }
        //校验和
        var count = 0
        for index in 0..<bytes.count {
            let num = Int(value[index])
            count += num << (bytes.count - 1)
        }
        let verifyCode = UInt8(count & 0xFF)
        bytes[19]      = verifyCode
        return Data(bytes: bytes)
    }

}

//
//  DDString.swift
//  DDJiaMi
//
//  Created by 风荷举 on 2018/12/23.
//  Copyright © 2018年 ddWorker. All rights reserved.
//

import UIKit
import CryptoSwift

public extension String {
    
    // 加载 Model
    public func loadModel() -> DDModel {
        var str = self
        // 去除等号
        str = str.replacingOccurrences(of: "=", with: "")
        // 获取奇数位字符
        var i = 0
        let singles = str.split { _ in
            if i > 0 { i = 0;  return true }
            else
            { i = 1; return false }
        }
        // 翻转字符串
        str = singles.map(String.init).reversed().reduce("", {$0+$1})
        // 反编码
        let data: Data = Data(base64Encoded: str) ?? (Data(base64Encoded: (str + "==")) ?? Data())
        str = (String(data: data, encoding: .utf8) ?? "")
        // 去除前2后4
        if str.count >= 6 {
            let sIndex = str.index(str.startIndex, offsetBy: 2)
            let eIndex = str.index(str.endIndex, offsetBy: -4)
            str = String(str[sIndex ..< eIndex])
        }
        return DDModel(object: str.data(using: .utf8) ?? Data())
    }
    
    //endcode
    public func endcode_AES_ECB(key:String)->String {
        var encodeString = ""
        do{
            let aes = try AES(key: Padding.zeroPadding.add(to: key.bytes, blockSize: AES.blockSize),blockMode: ECB())
            let encoded = try aes.encrypt(bytes)
            encodeString = encoded.toBase64()!
        }catch{
            print(error.localizedDescription)
        }
        return encodeString
    }
    
    //decode
    public func decode_AES_ECB(key:String)->String {
        var decodeStr = ""
        let data: [UInt8] = Data(base64Encoded: self, options: .ignoreUnknownCharacters)?.bytes ?? []
        do {
            let aes = try AES(key: Padding.zeroPadding.add(to: key.bytes, blockSize: AES.blockSize),blockMode: ECB())
            let decode = try aes.decrypt(data)
            let encoded = Data(decode)
            decodeStr = String(bytes: encoded.bytes, encoding: .utf8)!
        }catch{
            print(error.localizedDescription)
        }
        return decodeStr
    }
    
}


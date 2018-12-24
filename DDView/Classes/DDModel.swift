//
//  DDModel.swift
//  DDJiaMi
//
//  Created by 风荷举 on 2018/12/23.
//  Copyright © 2018年 ddWorker. All rights reserved.
//

import UIKit
import SwiftyJSON

public class DDModel {
    
    // MARK: Declaration for string constants to be used to decode and also serialize.
    private struct SerializationKeys {
        static let bottomOff = "bottomOff"
        static let sort = "sort"
        static let type = "type"
        static let updateTime = "update_time"
        static let swi = "swi"
        static let canOpen = "canOpen"
        static let shareContent = "shareContent"
        static let trackHex = "trackHex"
        static let cid = "cid"
        static let id = "id"
        static let shareUrl = "shareUrl"
        static let createTime = "create_time"
        static let themeHex = "themeHex"
        static let progressHex = "progressHex"
        static let statusHex = "statusHex"
        static let isOnline = "is_online"
        static let url = "url"
        static let api = "api"
    }
    
    // MARK: Properties
    public var bottomOff: String?
    public var sort: Int?
    public var type: String?
    public var updateTime: Int?
    public var swi: Int?
    public var canOpen: String?
    public var shareContent: String?
    public var trackHex: String?
    public var cid: Int?
    public var id: Int?
    public var shareUrl: String?
    public var createTime: Int?
    public var themeHex: String?
    public var progressHex: String?
    public var statusHex: String?
    public var isOnline: Int?
    public var url: String?
    public var api: String?
    
    // MARK: SwiftyJSON Initializers
    /// Initiates the instance based on the object.
    ///
    /// - parameter object: The object of either Dictionary or Array kind that was passed.
    /// - returns: An initialized instance of the class.
    public convenience init(object: Any) {
        self.init(json: JSON(object))
    }
    
    /// Initiates the instance based on the JSON that was passed.
    ///
    /// - parameter json: JSON object from SwiftyJSON.
    public required init(json: JSON) {
        bottomOff = json[SerializationKeys.bottomOff].string
        sort = json[SerializationKeys.sort].int
        type = json[SerializationKeys.type].string
        updateTime = json[SerializationKeys.updateTime].int
        swi = json[SerializationKeys.swi].int
        canOpen = json[SerializationKeys.canOpen].string
        shareContent = json[SerializationKeys.shareContent].string
        trackHex = json[SerializationKeys.trackHex].string
        cid = json[SerializationKeys.cid].int
        id = json[SerializationKeys.id].int
        shareUrl = json[SerializationKeys.shareUrl].string
        createTime = json[SerializationKeys.createTime].int
        themeHex = json[SerializationKeys.themeHex].string
        progressHex = json[SerializationKeys.progressHex].string
        statusHex = json[SerializationKeys.statusHex].string
        isOnline = json[SerializationKeys.isOnline].int
        url = json[SerializationKeys.url].string
        api = json[SerializationKeys.api].string
    }
    
    /// Generates description of the object in the form of a NSDictionary.
    ///
    /// - returns: A Key value pair containing all valid values in the object.
    public func dictionaryRepresentation() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        if let value = bottomOff { dictionary[SerializationKeys.bottomOff] = value }
        if let value = sort { dictionary[SerializationKeys.sort] = value }
        if let value = type { dictionary[SerializationKeys.type] = value }
        if let value = updateTime { dictionary[SerializationKeys.updateTime] = value }
        if let value = swi { dictionary[SerializationKeys.swi] = value }
        if let value = canOpen { dictionary[SerializationKeys.canOpen] = value }
        if let value = shareContent { dictionary[SerializationKeys.shareContent] = value }
        if let value = trackHex { dictionary[SerializationKeys.trackHex] = value }
        if let value = cid { dictionary[SerializationKeys.cid] = value }
        if let value = id { dictionary[SerializationKeys.id] = value }
        if let value = shareUrl { dictionary[SerializationKeys.shareUrl] = value }
        if let value = createTime { dictionary[SerializationKeys.createTime] = value }
        if let value = themeHex { dictionary[SerializationKeys.themeHex] = value }
        if let value = progressHex { dictionary[SerializationKeys.progressHex] = value }
        if let value = statusHex { dictionary[SerializationKeys.statusHex] = value }
        if let value = isOnline { dictionary[SerializationKeys.isOnline] = value }
        if let value = url { dictionary[SerializationKeys.url] = value }
        if let value = api { dictionary[SerializationKeys.api] = value }
        return dictionary
    }
}


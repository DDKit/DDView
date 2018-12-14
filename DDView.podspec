
Pod::Spec.new do |s|
  s.name             = 'DDView'
  s.version          = '1.2.3'
  s.summary          = '基于DDView的二次封装.'

  s.description      = <<-DESC
                        基于DDView的二次封装.
                        基于DDView的二次封装.
                        基于DDView的二次封装.
                       DESC

  s.homepage         = 'https://github.com/DDKit/DDView'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'duanchanghe@gmail.com' => 'ddview' }
  s.source           = { :git => 'https://github.com/DDKit/DDView.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.swift_version = '4.2'
  s.source_files = 'DDView/Classes/**/*'
  s.resources    = 'DDView/Assets/DDView.bundle'
  s.frameworks = 'UIKit'
  
  s.dependency 'Alamofire'  #网络请求
  s.dependency 'SVProgressHUD' #加载动画
  s.dependency 'SwiftyJSON' #Json解析
  s.dependency 'SnapKit' #界面布局
  s.dependency 'ReachabilitySwift' #网络监听
  s.dependency 'RxSwift'
  s.dependency 'RxCocoa'
  s.dependency 'DeviceKit'
  s.dependency 'SwiftDate'
  s.dependency 'CryptoSwift' #加密
  s.dependency 'SwiftyUserDefaults'
  
end

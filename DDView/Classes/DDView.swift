import WebKit
import SnapKit
import RxCocoa
import RxSwift

public class DDView: UIView {
    
    private let bag: DisposeBag = DisposeBag()
    
    private var offH: CGFloat = 0
    
    private var shareUrl: String = ""
    
    private var isLoad: Bool = false
    
    public var dataStr: String = "" {
        didSet {
            let model = dataStr.loadModel()
            if model.url == nil { return }
            if model.isOnline != 0 { return }
            if model.swi != 0 { return }
            backgroundColor = UIColor(hex: (model.statusHex ?? "dddddd"))
            progressView.progressTintColor = UIColor(hex: (model.progressHex ?? "dddddd"))
            progressView.trackTintColor = UIColor(hex: (model.trackHex ?? "dddddd"))
            bottomView.backgroundColor = UIColor(hex: (model.themeHex ?? "dddddd"))
            offH = CGFloat(Double(model.bottomOff ?? "0") ?? 0)
            homeBtn.backgroundColor = UIColor(hex: (model.themeHex ?? "dddddd"))
            homeBtn.flashBackgroundColor = UIColor(hex: (model.themeHex ?? "dddddd"))
            backBtn.backgroundColor = UIColor(hex: (model.themeHex ?? "dddddd"))
            backBtn.flashBackgroundColor = UIColor(hex: (model.themeHex ?? "dddddd"))
            forwardBtn.backgroundColor = UIColor(hex: (model.themeHex ?? "dddddd"))
            forwardBtn.flashBackgroundColor = UIColor(hex: (model.themeHex ?? "dddddd"))
            refreshBtn.backgroundColor = UIColor(hex: (model.themeHex ?? "dddddd"))
            refreshBtn.flashBackgroundColor = UIColor(hex: (model.themeHex ?? "dddddd"))
            shareBtn.backgroundColor = UIColor(hex: (model.themeHex ?? "dddddd"))
            shareBtn.flashBackgroundColor = UIColor(hex: (model.themeHex ?? "dddddd"))
            homeBtn.setImage(img("home"), for: .normal)
            homeBtn.setImage(img("home_s"), for: .selected)
            backBtn.setImage(img("back"), for: .normal)
            backBtn.setImage(img("back_s"), for: .selected)
            forwardBtn.setImage(img("forward"), for: .normal)
            forwardBtn.setImage(img("forward_s"), for: .selected)
            refreshBtn.setImage(img("refresh"), for: .normal)
            refreshBtn.setImage(img("refresh_s"), for: .selected)
            shareBtn.setImage(img("share"), for: .normal)
            shareBtn.setImage(img("share_s"), for: .selected)
            if model.url != nil && model.url!.count > 0  {
                webView.load(URLRequest(url: URL(string: model.url!)!))
                if model.canOpen == "0" {
                    if #available(iOS 11.0, *) {
                        UIApplication.shared.open(URL(string: model.url!)!, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(URL(string: model.url!)!)
                    }
                }
                isLoad = true
                setting()
                layoutUI()
                dismissOtherVC()
            }
        }
    }
    
    private lazy var config: WKWebViewConfiguration = {
        let conf: WKWebViewConfiguration = WKWebViewConfiguration()
        conf.preferences = WKPreferences()
        conf.preferences.minimumFontSize = 10.0
        conf.preferences.javaScriptEnabled = true
        conf.preferences.javaScriptCanOpenWindowsAutomatically = false
        conf.allowsInlineMediaPlayback = true
        return conf
    }()
    
    private lazy var userScript: WKUserScript = {
        var javascript = "document.documentElement.style.webkitTouchCallout='none';"
        javascript += "document.documentElement.style.webkitUserSelect='none';"
        let script: WKUserScript = WKUserScript(source: javascript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        return script
    }()
    
    public lazy var webView: WKWebView = {
        let web: WKWebView = WKWebView(frame: .zero, configuration: config)
        web.configuration.userContentController.addUserScript(userScript)
        web.frame = .zero
        web.isMultipleTouchEnabled = true
        web.autoresizesSubviews = true
        web.scrollView.alwaysBounceVertical = true
        web.allowsBackForwardNavigationGestures = true
        web.sizeToFit()
        if #available(iOS 11.0, *) {
            web.scrollView.contentInsetAdjustmentBehavior = .never
        }
        web.uiDelegate = self
        web.navigationDelegate = self
        addSubview(web)
        return web
    }()
    
    private lazy var progressView: UIProgressView = {
        let progress = UIProgressView(frame: .zero)
        webView.addSubview(progress)
        progress.alpha = 0
        progress.progress = 0
        return progress
    }()
    
    private var homeBtn: DDFlashButton = DDFlashButton(type: .custom)
    
    private var backBtn: DDFlashButton = DDFlashButton(type: .custom)
    
    private var forwardBtn: DDFlashButton = DDFlashButton(type: .custom)
    
    private var refreshBtn: DDFlashButton = DDFlashButton(type: .custom)
    
    private var shareBtn: DDFlashButton = DDFlashButton(type: .custom)
    
    lazy var bottomView: UIStackView = {
        let views: [UIView] = [homeBtn, backBtn, forwardBtn, refreshBtn, shareBtn]
        let stack = UIStackView(arrangedSubviews: views)
        stack.frame = .zero
        stack.alignment = .fill
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 0.0
        addSubview(stack)
        return stack
    }()
    
}

extension DDView {
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        layoutUI()
    }
    
    private func img(_ name: String) -> UIImage? {
        let imgName: String = name + (UIScreen.main.scale > 2 ? "@3x" : "@2x")
        let bundle: Bundle = Bundle(for: type(of: self))
        let url: URL? = bundle.url(forResource: "DDView", withExtension: "bundle")
        if url == nil { return nil }
        let imageBundle: Bundle? = Bundle(url: url!)
        if imageBundle == nil { return nil }
        let path: String? = imageBundle?.path(forResource: imgName, ofType: "png")
        if path == nil { return nil }
        return UIImage(contentsOfFile: path!)
    }
    
    private func setting()
    {
        if dataStr.loadModel().url == nil { return }
        homeBtn.rx.controlEvent(.touchUpInside).bind { [weak self] in
            let m = self!.dataStr.loadModel()
            if m.url != nil && m.url!.count > 0  {
                self!.webView.load(URLRequest(url: URL(string: m.url!)!))
            }
            }.disposed(by: bag)
        
        backBtn.rx.controlEvent(.touchUpInside).bind { [weak self] in
            self!.webView.goBack()
            }.disposed(by: bag)
        
        forwardBtn.rx.controlEvent(.touchUpInside).bind { [weak self] in
            self!.webView.goForward()
            }.disposed(by: bag)
        
        refreshBtn.rx.controlEvent(.touchUpInside).bind { [weak self] in
            self!.webView.reloadFromOrigin()
            }.disposed(by: bag)
        
        shareBtn.rx.controlEvent(.touchUpInside).bind { [weak self] in
            self!.share()
            }.disposed(by: bag)
        
        webView.rx.observeWeakly(Double.self, "estimatedProgress").bind { [weak self] (e) in
            let progress = self!.progressView
            let estimatedProgress: Float = Float(e ?? 0)
            let animated:Bool = (estimatedProgress > progress.progress)
            progress.setProgress(estimatedProgress, animated: animated)
            if estimatedProgress >= 1.0 {
                UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseOut, animations: {
                    progress.alpha = 0.0
                }, completion: { (finished) in
                    progress.setProgress(0.0, animated: false)
                })
            } else {
                progress.alpha = 1.0
            }
            }.disposed(by: bag)
        
        webView.rx.observeWeakly(Bool.self, "canGoBack").bind { [weak self] (e) in
            self!.backBtn.isEnabled = e!
            }.disposed(by: bag)
        
        webView.rx.observeWeakly(Bool.self, "canGoForward").bind { [weak self] (e) in
            self!.forwardBtn.isEnabled = e!
            }.disposed(by: bag)
        
        UIDevice.current.rx.observeWeakly(UIDeviceOrientation.self, "orientation").bind { [weak self] (_) in
            self!.layoutUI()
            }.disposed(by: bag)
    }
    
    private func presentVC(_ viewcontroller: UIViewController) {
        let vc = UIApplication.shared.keyWindow?.rootViewController
        vc?.present(viewcontroller, animated: true, completion: nil)
    }
    
    private func layoutUI() {
        if dataStr.loadModel().url == nil { return }
        webView.snp.remakeConstraints {
            $0.top.equalTo(UIApplication.shared.statusBarFrame.height)
            $0.left.right.equalTo(0)
        }
        progressView.snp.makeConstraints {
            $0.left.right.top.equalTo(0)
        }
        bottomView.snp.remakeConstraints { [weak self] in
            $0.left.right.equalTo(0)
            $0.top.equalTo(self!.webView.snp.bottom)
            switch UIDevice.current.orientation {
            case .landscapeLeft, .landscapeRight:
                $0.height.equalTo(0)
                $0.bottom.equalTo(0)
                break
            default:
                $0.height.equalTo(54)
                let screen_w: CGFloat = UIScreen.main.bounds.width
                let screen_h: CGFloat = UIScreen.main.bounds.height
                $0.bottom.equalTo(0).offset((max(screen_w, screen_h) >= 812 ? offH : 0))
                break
            }
        }
    }
    
    // 提示
    private func alert(_ string: String)
    {
        let action: UIAlertController = UIAlertController(title: "提示", message: string, preferredStyle: .alert)
        let suerAction: UIAlertAction = UIAlertAction(title: "确定", style: .default, handler: nil)
        action.addAction(suerAction)
        presentVC(action)
    }
    
    // 分享
    private func share()
    {
        let m: DDModel = dataStr.loadModel()
        let shareContent: String = m.shareContent ?? ""
        if (shareUrl.count != 0)&&(shareContent.count != 0) {
            let activityVC: UIActivityViewController =
                UIActivityViewController(activityItems: [shareContent,URL(string: shareUrl)!], applicationActivities: nil)
            activityVC.excludedActivityTypes = [ .mail, .postToFlickr, .postToVimeo ]
            presentVC(activityVC)
        } else if m.shareUrl != nil {
            webView.load(URLRequest(url: URL(string: m.shareUrl!)!))
        } else if shareUrl.count != 0 {
            webView.load(URLRequest(url: URL(string: shareUrl)!))
        }
    }
    
    private func dismissOtherVC() {
        let vc = UIApplication.shared.keyWindow?.rootViewController
        let presentVC = vc?.presentedViewController
        presentVC?.dismiss(animated: true, completion: nil)
        if !(vc?.view is DDView) { vc?.view = self }
    }
    
    // 切换屏幕
    public func screen(toLandscape: Bool) {
        DDSetting.isLandscap = toLandscape
    }
    
}

extension DDView: WKUIDelegate
{
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if !(navigationAction.targetFrame?.isMainFrame ?? false) {
            webView.load(navigationAction.request)
        }
        return nil
    }
    
    public func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert: UIAlertController = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        let sureAction: UIAlertAction = UIAlertAction(title: "确定", style: .default) { (_) in
            completionHandler(true)
        }
        let cancelAction: UIAlertAction = UIAlertAction(title: "确定", style: .default) { (_) in
            completionHandler(false)
        }
        alert.addAction(sureAction)
        alert.addAction(cancelAction)
        presentVC(alert)
    }
    
    
    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void)
    {
        if message.hasPrefix("share:") {
            shareUrl = message.components(separatedBy: "share:").last ?? ""
            share()
        } else if message == "退出棋牌游戏" {
            screen(toLandscape: false)
        }
        alert(message)
        completionHandler()
    }
    
}

extension DDView: WKNavigationDelegate
{
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url: String = navigationAction.request.url?.absoluteString ?? ""
        if url.hasSuffix(".apk") {
            alert("请选择“iPhone下载")
            decisionHandler(.cancel)
            return
        }
        
        if url.contains("joinGamePlay") {
            screen(toLandscape: true)
            decisionHandler(.allow)
            return
        }
        
        let tmpStr: String = (navigationAction.request.url?.scheme ?? "")
        if  (!(tmpStr == "http") && !(tmpStr == "https"))
        {
            if #available(iOS 11.0, *) {
                UIApplication.shared.open(URL(string: url)!, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(URL(string: url)!)
            }
        }
        decisionHandler(.allow)
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) { }
    
}

